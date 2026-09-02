import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerFromUrl extends StatefulWidget {
  final String url;

  const VideoPlayerFromUrl({super.key, required this.url});

  @override
  State<VideoPlayerFromUrl> createState() => _VideoPlayerFromUrlState();
}

class _VideoPlayerFromUrlState extends State<VideoPlayerFromUrl> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  Timer? _hideTimer;
  bool _isEnded = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {});
        _startHideTimer(); // mulai timer setelah init agar hilang otomatis jika autoplay
      });

    // Listener untuk update UI & cek ended
    _controller.addListener(_videoListener);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onScreenTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),

          // Tombol Play/Pause (muncul/hide)
          if (_showControls)
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                iconSize: 64,
                color: Colors.white,
                icon: Icon(
                  _isEnded
                      ? Icons.replay_circle_filled
                      : (_controller.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle),
                ),
                onPressed: _onPlayPausePressed,
              ),
            ),

          // Progress bar di bawah
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              padding: const EdgeInsets.only(bottom: 4),
              colors: const VideoProgressColors(
                playedColor: Colors.white,
                backgroundColor: Colors.black38,
                bufferedColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _videoListener() {
    if (!_controller.value.isInitialized) return;

    final position = _controller.value.position;
    final duration = _controller.value.duration;

    // Jika durasi valid dan posisi sudah mencapai akhir (beri toleransi)
    if (duration != null &&
        duration.inMilliseconds > 0 &&
        position >= duration - const Duration(milliseconds: 200)) {
      if (!_isEnded) {
        _isEnded = true;
        _onVideoEnded();
      }
    } else {
      // jika bergerak lagi (mis. seek atau replay), reset ended flag
      if (_isEnded) {
        _isEnded = false;
      }
    }

    // update UI untuk progress bar dll
    if (mounted) setState(() {});
  }

  void _onVideoEnded() {
    // tampilkan kontrol & pause, jangan langsung rewind (user bisa tekan play untuk replay)
    _hideTimer?.cancel();
    setState(() {
      _showControls = true;
    });
    try {
      _controller.pause();
    } catch (_) {}
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  // Tap area behavior:
  // - jika kontrol hidden -> tampilkan + start timer
  // - jika kontrol visible -> reset timer (jangan sembunyikan)
  void _onScreenTap() {
    if (!_controller.value.isInitialized) return;

    if (!_showControls) {
      setState(() => _showControls = true);
      _startHideTimer();
    } else {
      // hanya reset timer agar tidak langsung hilang saat user mengetuk area lain
      _startHideTimer();
    }
  }

  void _onPlayPausePressed() {
    if (!_controller.value.isInitialized) return;

    if (_isEnded) {
      // sudah selesai -> ulang dari awal
      _controller.seekTo(Duration.zero).then((_) {
        _controller.play();
        _startHideTimer();
        setState(() {
          _isEnded = false;
        });
      });
    } else {
      if (_controller.value.isPlaying) {
        _controller.pause();
        // saat pause kita tampilkan kontrol terus (jangan sembunyikan)
        _hideTimer?.cancel();
        setState(() => _showControls = true);
      } else {
        _controller.play();
        _startHideTimer();
        setState(() => _showControls = true);
      }
    }
  }
}
