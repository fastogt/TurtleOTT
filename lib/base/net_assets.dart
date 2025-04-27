import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

class NetAssetsIcon extends StatelessWidget {
  final String link;
  final double? width;
  final double? height;

  const NetAssetsIcon(this.link, {this.width, this.height});

  String assetsLink() {
    return 'install/assets/logo.png';
  }

  Widget defaultIcon() {
    return Image.asset(assetsLink(), height: height, width: width);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(child: image());
  }

  Widget image() {
    return NonCacheNetworkImage(
      imageUrl: link,
      height: height,
      width: width,
    );
  }
}

class NonCacheNetworkImage extends StatelessWidget {
  const NonCacheNetworkImage({
    required this.imageUrl,
    required this.height,
    required this.width,
    Key? key,
  }) : super(key: key);

  final String imageUrl;
  final double? width;
  final double? height;

  Future<Uint8List> getImageBytes() async {
    final Response response = await get(Uri.parse(imageUrl));
    return response.bodyBytes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
        future: getImageBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!, height: height, width: width);
          }
          return SizedBox(height: height, width: width);
        });
  }
}
