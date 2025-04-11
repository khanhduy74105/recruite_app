import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application/features/home/widgets/photo_viewer_page.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoGrid extends StatefulWidget {
  final int maxImages;
  final List<String> imageUrls;

  const PhotoGrid(
      {super.key, required this.maxImages, required this.imageUrls});

  @override
  createState() => _PhotoGridState();
}

class _PhotoGridState extends State<PhotoGrid> {
  @override
  Widget build(BuildContext context) {
    var images = buildImages();

    return LayoutBuilder(
      builder: (context, constraints) {
        return MasonryGridView.count(
          crossAxisCount: getCrossAxisCount(widget.imageUrls.length),
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: images.length,
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AspectRatio(
              aspectRatio: 1,
              child: images[index],
            ),
          ),
        );
      },
    );
  }

  int getCrossAxisCount(int numImages) {
    if (numImages == 1) return 1;
    if (numImages == 2 || numImages == 3) return 2;
    return 2;
  }

  List<Widget> buildImages() {
    int numImages = widget.imageUrls.length;
    return List<Widget>.generate(min(numImages, widget.maxImages), (index) {
      String imageUrl = widget.imageUrls[index];
      if (index == widget.maxImages - 1) {
        int remaining = numImages - widget.maxImages;

        if (remaining == 0) {
          return GestureDetector(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              memCacheWidth: 250,
              maxWidthDiskCache: 500,
              cacheKey: 'unique-key-$imageUrl',
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoViewerPage(
                  imageUrls: widget.imageUrls,
                  initialIndex: index,
                ),
              ),
            ),
          );
        } else {
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoViewerPage(
                  imageUrls: widget.imageUrls,
                  initialIndex: index,
                ),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  memCacheWidth: 250,
                  maxWidthDiskCache: 500,
                  cacheKey: 'unique-key-$imageUrl',
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.black54,
                    child: Text(
                      '+$remaining',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        return GestureDetector(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            memCacheWidth: 250,
            maxWidthDiskCache: 500,
            cacheKey: 'unique-key-$imageUrl',
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhotoViewerPage(
                imageUrls: widget.imageUrls,
                initialIndex: index,
              ),
            ),
          ),
        );
      }
    });
  }
}
