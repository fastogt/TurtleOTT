import 'package:flutter/material.dart';
import 'package:turtleott/base/scale.dart';

class AnimatedTextButton extends StatefulWidget {
  final bool autofocus;
  final String title;
  final IconData? icon;
  final VoidCallback? onPressed;

  const AnimatedTextButton(
      {required this.title, this.icon, required this.onPressed, this.autofocus = false});

  @override
  AnimatedTextButtonState createState() => AnimatedTextButtonState();
}

class AnimatedTextButtonState extends State<AnimatedTextButton> {
  final FocusNode _node = FocusNode();

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutoScaleWidget(
        node: _node,
        builder: (hasFocus) {
          if (widget.icon != null) {
            return TextButton.icon(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        hasFocus ? Theme.of(context).colorScheme.primary : null)),
                autofocus: widget.autofocus,
                focusNode: _node,
                icon: Icon(widget.icon),
                label: Text(widget.title),
                onPressed: widget.onPressed);
          } else {
            return TextButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        hasFocus ? Theme.of(context).colorScheme.surface : null)),
                autofocus: widget.autofocus,
                focusNode: _node,
                child: Text(widget.title),
                onPressed: widget.onPressed);
          }
        });
  }
}
