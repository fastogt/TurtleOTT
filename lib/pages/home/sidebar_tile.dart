import 'package:flutter/material.dart';
import 'package:turtleott/utils/theme.dart';

class SidebarTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final void Function(bool hasFocus) onFocusChanged;
  final KeyEventResult Function(RawKeyEvent event) onKey;
  final bool selected;

  static const double iconWidth = 84;

  const SidebarTile(
      {required this.icon,
      required this.title,
      required this.onFocusChanged,
      required this.onKey,
      required this.selected});

  @override
  _SidebarTileState createState() => _SidebarTileState();
}

class _SidebarTileState extends State<SidebarTile> {
  late final FocusNode _node = FocusNode();

  @override
  void initState() {
    super.initState();
    _node.addListener(_update);
  }

  @override
  void dispose() {
    _node.removeListener(_update);
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backColor = _node.hasFocus
        ? Theme.of(context).colorScheme.secondary
        : Theming.of(context).themeId == LIGHT_THEME_ID
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).scaffoldBackgroundColor;
    final double size = _node.hasFocus ? 40 : 32;
    final double iconSize = _node.hasFocus ? 24 : 20;
    return Container(
        color: backColor,
        child: Row(children: [
          Focus(
              autofocus: widget.selected,
              focusNode: _node,
              onKey: (_, event) => widget.onKey(event),
              onFocusChange: widget.onFocusChanged,
              child: SizedBox(
                  height: 56,
                  width: SidebarTile.iconWidth,
                  child: Center(
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(size / 2),
                          child: Container(
                              height: size,
                              width: size,
                              color: _node.hasFocus ? Colors.white : Colors.white54,
                              child: Icon(widget.icon,
                                  color: Theming.of(context).themeId == LIGHT_THEME_ID
                                      ? Colors.black
                                      : backColor,
                                  size: iconSize)))))),
          Text(widget.title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color:
                      Theming.of(context).themeId == LIGHT_THEME_ID ? Colors.black : Colors.white,
                  fontWeight: FontWeight.normal))
        ]));
  }

  void _update() {
    setState(() {});
  }
}
