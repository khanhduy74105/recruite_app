import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoViewerPage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const PhotoViewerPage({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${currentIndex + 1}/${widget.imageUrls.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMenu(context),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.contain, // Ensures full height or width without overflow
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                _downloadImage(
                  widget.imageUrls[currentIndex],
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _downloadImage(String url) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading...')),
    );
    try {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }
    }

    String fileName = url.split('/').last;

    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = "${directory.path}/$fileName";

    Dio dio = Dio();
    await dio.download(url, filePath);

    print("Image saved to: $filePath");
  } catch (e) {
    print("Download error: $e");
  }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
