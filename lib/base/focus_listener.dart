import 'package:flutter/material.dart';

typedef OnKeyCallback = bool Function(RawKeyEvent event);
typedef FocusListenerCallback = void Function(bool hasFocus);
typedef FocusListenerBuilder = Widget Function(bool hasFocus);

class FocusListener extends StatefulWidget {
  final FocusNode node;
  final FocusListenerBuilder builder;
  final FocusListenerCallback? onChanged;
  final bool primaryFocus;

  const FocusListener(
      {required this.node,
      required this.builder,
      this.onChanged,
      this.primaryFocus = true,
      Key? key})
      : super(key: key);

  @override
  _FocusListenerState createState() => _FocusListenerState();
}

class _FocusListenerState extends State<FocusListener> {
  bool get hasFocus => widget.primaryFocus ? widget.node.hasPrimaryFocus : widget.node.hasFocus;

  @override
  void initState() {
    super.initState();
    widget.node.addListener(_update);
  }

  @override
  void dispose() {
    widget.node.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(hasFocus);
  }

  void _update() {
    widget.onChanged?.call(hasFocus);
    setState(() {});
  }
}
