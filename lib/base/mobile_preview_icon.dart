import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PreviewIcon extends StatelessWidget {
  final String link;
  final double? height;
  final double? width;
  final String? assetLink;

  const PreviewIcon(this.link, {this.height, this.width, this.assetLink});

  String assetsLink() {
    if (assetLink != null) {
      return assetLink!;
    }
    return 'install/assets/unknown_channel.png';
  }

  Widget defaultIcon() {
    return Image.asset(assetsLink(), height: height, width: width);
  }

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
        imageUrl: link,
        placeholder: (context, url) => defaultIcon(),
        errorWidget: (context, url, error) => defaultIcon(),
        height: height,
        width: width,
        fit: BoxFit.cover);
    return image;
  }
}
