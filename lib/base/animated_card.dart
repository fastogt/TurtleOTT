import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/base/focus_listener.dart';
import 'package:turtleott/base/scale.dart';

class AnimatedCard extends StatefulWidget {
  final String icon;
  final String title;
  final Widget subtitle;
  final VoidCallback? onTap;
  final OnKeyCallback? onKey;
  final FocusListenerCallback? onFocusChanged;
  final BoxFit imageFit;

  const AnimatedCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      this.onTap,
      this.onKey,
      this.onFocusChanged,
      this.imageFit = BoxFit.fitWidth})
      : assert(onTap != null || onKey != null);

  @override
  _AnimatedCardState createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  final FocusNode node = FocusNode();

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: node,
        onKey: (_, event) => _onKey(event),
        child: AutoScaleWidget(
            node: node,
            onChanged: widget.onFocusChanged?.call,
            builder: (hasFocus) {
              return _Card(
                  imageFit: widget.imageFit,
                  icon: widget.icon,
                  title: widget.title,
                  subtitle: widget.subtitle,
                  hasFocus: hasFocus);
            }));
  }

  KeyEventResult _onKey(RawKeyEvent event) {
    if (widget.onKey != null) {
      final bool handled = widget.onKey!.call(event);
      if (handled) {
        return KeyEventResult.handled;
      }
    }

    return onKeyArrows(context, event, onEnter: widget.onTap);
  }
}

class _Card extends StatelessWidget {
  final String icon;
  final String title;
  final Widget subtitle;
  final bool hasFocus;
  final BoxFit imageFit;

  const _Card(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.hasFocus,
      required this.imageFit});

  @override
  Widget build(BuildContext context) {
    final Color nameColor = hasFocus ? Colors.white : Colors.black;
    return Card(
        clipBehavior: Clip.antiAlias,
        color: hasFocus
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        margin: const EdgeInsets.all(0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Align(
                      alignment: Alignment.topCenter, child: Image.network(icon, fit: imageFit))),
              Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AnimatedText(title, color: nameColor),
                        const SizedBox(height: 4),
                        subtitle
                      ]))
            ]));
  }
}

class _AnimatedText extends AnimatedDefaultTextStyle {
  _AnimatedText(String text, {double fontSize = 14, required Color color})
      : super(
            duration: ScaleWidget.SCALING_DURATION,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: fontSize),
            child: Text(text, style: TextStyle(color: color)));
}
