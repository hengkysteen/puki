import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageCached {
  static Widget network(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      progressIndicatorBuilder: (context, url, download) => SizedBox(
        height: 10,
        width: 10,
        child: Center(child: CircularProgressIndicator(value: download.progress, strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) {
        return Container(
          color: Colors.grey[200],
          child: Center(child: Icon(Icons.broken_image_sharp, color: Colors.grey[400])),
        );
      },
    );
  }

  static ImageProvider networkProvider(String url) {
    return CachedNetworkImageProvider(url);
  }
}
