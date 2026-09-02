import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:chat/core/resources/constants/assets.dart';
import 'package:chat/core/routes/router_import.dart';
import 'package:chat/core/routes/router_import.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
// import 'package:absent_apps/core/resources/constants/assets.dart';

@RoutePage()
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    incrementProgress();
  }

  void incrementProgress() {
    int seconds = 0;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds < 5) {
          seconds++;
          _progress += 0.2; // Increase by 20%
        } else {
          timer.cancel();
          context.router.push(const HomeRoute());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Assets.icLauncherApps, // Path to the image
            width: 100, // Optional: specify width
            height: 100, // Optional: specify height
            fit: BoxFit.cover, // Optional: adjust how the image fits the widget
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LinearProgressIndicator(
              value: _progress, // Progress value (0.0 to 1.0)
            ),
          ),
          Text(
            "${(_progress * 100).toStringAsFixed(0)}%", // Display percentage
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
