import 'package:flutter/material.dart';

class PlayerTimeline extends StatelessWidget {
  static const double dashHeight = 16;
  static const double lineHeight = 8;

  /// from 0 to 1
  final double progress;

  const PlayerTimeline(this.progress);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: PlayerTimeline.dashHeight,
        child: LayoutBuilder(builder: (context, constraints) {
          final dotPosition = progress * constraints.maxWidth - _Dash.width / 2;
          return Stack(fit: StackFit.passthrough, children: <Widget>[
            const _LinearIndicator(1.0, color: Colors.white),
            _LinearIndicator(progress),
            Positioned(left: dotPosition, top: 0, bottom: 0, child: const _Dash())
          ]);
        }));
  }
}

class _LinearIndicator extends StatelessWidget {
  final double value;
  final Color? color;

  const _LinearIndicator(this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    const padding = (PlayerTimeline.dashHeight - PlayerTimeline.lineHeight) / 2;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: padding),
        child: LinearProgressIndicator(
            value: value,
            valueColor:
                AlwaysStoppedAnimation<Color>(color ?? Theme.of(context).colorScheme.secondary),
            backgroundColor: Colors.transparent));
  }
}

class _Dash extends StatelessWidget {
  static const double width = 4;

  const _Dash();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(width / 2), color: Colors.white),
        width: width);
  }
}
