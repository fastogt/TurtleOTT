import 'package:flutter/material.dart';
import 'package:turtleott/base/mobile_preview_icon.dart';

class VodCard extends StatefulWidget {
  final String iconLink;
  double? width;
  double? height;
  final double borderRadius;
  final Function? onPressed;

  bool isHov = false;

  VodCard(
      {required this.iconLink, this.height, this.width, this.borderRadius = 2.0, this.onPressed});

  VodCard.tv({required this.iconLink, this.height, this.borderRadius = 2.0, this.onPressed})
      : width = 128;

  static const CARD_WIDTH = 376.0;
  static const ASPECT_RATIO = 16 / 9;

  @override
  State<VodCard> createState() => _VodCardState();
}

class _VodCardState extends State<VodCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size getSize() {
      if (widget.height != null && widget.width == null) {
        return Size(widget.height! / VodCard.ASPECT_RATIO, widget.height!);
      } else if (widget.height == null && widget.width != null) {
        return Size(widget.width!, widget.width! * VodCard.ASPECT_RATIO);
      } else if (widget.height != null && widget.width != null) {
        return Size(widget.width!, widget.height!);
      }
      return const Size(VodCard.CARD_WIDTH, VodCard.CARD_WIDTH * VodCard.ASPECT_RATIO);
    }

    final size = getSize();

    final border = BorderRadius.circular(widget.borderRadius);
    return SizedBox(
        width: size.width,
        height: size.height,
        child: Card(
            margin: widget.isHov ? const EdgeInsets.all(0) : const EdgeInsets.all(4),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: border),
            child: Stack(children: <Widget>[
              ClipRRect(
                  borderRadius: border,
                  child: PreviewIcon(widget.iconLink, width: size.width, height: size.height)),
              InkWell(onTap: () {
                widget.onPressed?.call();
              })
            ])));
  }
}

class VodCardBadge extends StatelessWidget {
  static const HEIGHT = 36.0;

  final Widget child;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double? width;

  const VodCardBadge(
      {required this.child, this.top, this.bottom, this.left, this.right, this.width});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    final widget = Container(
        decoration: BoxDecoration(
            color: color, borderRadius: const BorderRadius.all(Radius.circular(HEIGHT / 2))),
        height: HEIGHT,
        width: width,
        child: child);
    return Positioned(left: left, top: top, right: right, bottom: bottom, child: widget);
  }
}

class VodsCardGrid<T> extends StatelessWidget {
  static const double EDGE_INSETS = 4.0;

  final List<T> streams;
  final Widget Function(int, T, double, double) tile;
  final int cardsInHorizontal;

  const VodsCardGrid(this.streams, this.tile, {this.cardsInHorizontal = 3});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double padding = 16;
    final maxWidth = size.width - 2 * EDGE_INSETS * cardsInHorizontal;
    final cardWidth = maxWidth / cardsInHorizontal;
    const double aspect = 2 / 3;
    final maxHeight = maxWidth / aspect;
    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: padding),
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: cardWidth + 2 * EDGE_INSETS,
                    crossAxisSpacing: EDGE_INSETS,
                    mainAxisSpacing: EDGE_INSETS,
                    childAspectRatio: aspect),
                itemCount: streams.length,
                itemBuilder: (BuildContext context, int index) {
                  return tile(index, streams[index], maxWidth, maxHeight);
                })));
  }
}
