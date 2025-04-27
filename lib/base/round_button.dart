import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/base/scale.dart';

class RoundedButton extends StatefulWidget {
  static const double SIZE = 48;

  final IconData icon;
  final VoidCallback? onTap;
  final KeyEventResult Function(RawKeyEvent event)? onKey;
  final bool autofocus;
  final double cornerRadius;
  final Color? unfocusedColor;

  const RoundedButton(
      {required this.icon,
      this.onTap,
      this.onKey,
      this.autofocus = false,
      this.cornerRadius = SIZE / 2,
      this.unfocusedColor})
      : assert(onTap == null || onKey == null);

  @override
  _RoundedButtonState createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  final FocusNode _node = FocusNode();

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        autofocus: widget.autofocus,
        focusNode: _node,
        onKey: (node, event) {
          if (widget.onKey != null) {
            return widget.onKey!.call(event);
          } else {
            return onKeyArrows(context, event, onEnter: widget.onTap);
          }
        },
        child: AutoScaleWidget(
            node: _node,
            builder: (hasFocus) {
              return ClipRRect(
                  borderRadius: BorderRadius.circular(widget.cornerRadius),
                  child: Container(
                      height: RoundedButton.SIZE,
                      width: RoundedButton.SIZE,
                      color: hasFocus
                          ? Theme.of(context).colorScheme.secondary
                          : (widget.unfocusedColor ?? Theme.of(context).disabledColor),
                      child:
                          Icon(widget.icon, color: Colors.white, size: RoundedButton.SIZE * 0.6)));
            }));
  }
}
