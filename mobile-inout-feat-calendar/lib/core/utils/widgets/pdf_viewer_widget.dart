import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mobile_in_out/core/utils/helper/global_utils.dart';

class PdfViewerWidget extends StatefulWidget {
  final String url;

  const PdfViewerWidget({
    super.key,
    required this.url,
  });

  @override
  State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends State<PdfViewerWidget> {
  PDFViewController? _controller;
  int _currentPage = 0;
  int _totalPages = 0;
  File? _cachedFile;
  bool _isLoading = true;
  
  // Static cache to prevent downloading same file multiple times
  static final Map<String, File> _fileCache = {};

  @override
  void initState() {
    super.initState();
    _loadPdfFile();
  }

  Future<void> _loadPdfFile() async {
    try {
      // Check if file is already cached
      if (_fileCache.containsKey(widget.url)) {
        setState(() {
          _cachedFile = _fileCache[widget.url];
          _isLoading = false;
        });
        return;
      }

      final file = await GlobalUtils.downloadFile(widget.url);
      
      // Cache the file
      _fileCache[widget.url] = file;
      
      if (mounted) {
        setState(() {
          _cachedFile = file;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_cachedFile == null) {
      return Center(child: Text("Failed to load PDF"));
    }
    
    return Column(
      children: [
        // Navigation controls
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _currentPage > 0 ? () {
                  _controller?.setPage(_currentPage - 1);
                } : null,
                icon: Icon(Icons.arrow_back, 
                  color: _currentPage > 0 ? Colors.black : Colors.grey),
              ),
              Text(
                'Page ${_currentPage + 1} from $_totalPages',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _currentPage < _totalPages - 1 ? () {
                  _controller?.setPage(_currentPage + 1);
                } : null,
                icon: Icon(Icons.arrow_forward,
                  color: _currentPage < _totalPages - 1 ? Colors.black : Colors.grey),
              ),
            ],
          ),
        ),
        // PDF content
        Expanded(
          child: PDFView(
            filePath: _cachedFile!.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: 0,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onPageChanged: (page, total) {
              if (mounted) {
                setState(() {
                  _currentPage = page ?? 0;
                  _totalPages = total ?? 0;
                });
              }
            },
            onViewCreated: (controller) {
              _controller = controller;
            },
          ),
        ),
      ],
    );
  }
}