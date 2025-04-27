import 'dart:math';

import 'package:flutter/material.dart';
import 'package:turtleott/base/focus_listener.dart';

class ScaleWidget extends StatefulWidget {
  static const double SCALE_FACTOR = 1.1;
  static const Duration SCALING_DURATION = Duration(milliseconds: 50);

  final Widget child;
  final double xScale;
  final double yScale;
  final Alignment alignment;
  final bool primaryFocus;

  const ScaleWidget(
      {required this.child,
      this.xScale = SCALE_FACTOR,
      this.yScale = SCALE_FACTOR,
      this.alignment = Alignment.center,
      this.primaryFocus = true,
      Key? key})
      : super(key: key);

  static ScaleWidgetState? of(BuildContext context) {
    return context.findAncestorStateOfType<ScaleWidgetState>();
  }

  @override
  ScaleWidgetState createState() => ScaleWidgetState();
}

class ScaleWidgetState extends State<ScaleWidget> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: ScaleWidget.SCALING_DURATION,
        lowerBound: 1 / max(widget.xScale, widget.yScale),
        vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (_, child) {
          double xScale;
          if (widget.xScale == 1) {
            xScale = 1;
          } else {
            xScale = _controller.value * widget.xScale;
          }
          double yScale;
          if (widget.yScale == 1) {
            yScale = 1;
          } else {
            yScale = _controller.value * widget.yScale;
          }
          return Transform(
              alignment: widget.alignment,
              transform: Matrix4(xScale, 0, 0, 0, 0, yScale, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1),
              child: widget.child);
        });
  }

  void expand() {
    _controller.fling();
  }

  void shrink() {
    _controller.fling(velocity: -1);
  }
}

class AutoScaleWidget extends StatelessWidget {
  final FocusNode node;
  final Widget Function(bool hasFocus) builder;
  final void Function(bool hasFocus)? onChanged;
  final double xScale;
  final double yScale;
  final Alignment alignment;
  final bool primaryFocus;

  const AutoScaleWidget(
      {required this.node,
      required this.builder,
      this.onChanged,
      this.xScale = ScaleWidget.SCALE_FACTOR,
      this.yScale = ScaleWidget.SCALE_FACTOR,
      this.alignment = Alignment.center,
      this.primaryFocus = true,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleWidget(
        alignment: alignment,
        xScale: xScale,
        yScale: yScale,
        child: Builder(builder: (context) {
          return FocusListener(
              primaryFocus: primaryFocus,
              node: node,
              onChanged: (hasFocus) {
                if (hasFocus) {
                  ScaleWidget.of(context)!.expand();
                } else {
                  ScaleWidget.of(context)!.shrink();
                }
                onChanged?.call(hasFocus);
              },
              builder: builder);
        }));
  }
}
