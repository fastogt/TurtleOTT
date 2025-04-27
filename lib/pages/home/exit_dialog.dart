import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/localization/translations.dart';

class ExitDialog extends StatefulWidget {
  @override
  State<ExitDialog> createState() => _ExitDialogState();
}

class _ExitDialogState extends State<ExitDialog> {
  bool opened = false;

  @override
  void initState() {
    super.initState();
    _buttonNo.addListener(_toggle);
    _buttonYes.addListener(_toggle);
  }

  @override
  void dispose() {
    _buttonNo.removeListener(_toggle);
    _buttonYes.removeListener(_toggle);
    super.dispose();
  }

  void _toggle() {
    setState(() {
      opened = _buttonNo.hasFocus || _buttonYes.hasFocus;
    });
  }

  final FocusNode _buttonNo = FocusNode();

  final FocusNode _buttonYes = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      padding: EdgeInsets.only(right: opened ? 84 : 240),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(translate(context, TR_EXIT_MESSAGE)),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Focus(
                  focusNode: _buttonNo,
                  onKey: (node, event) => _onKeyNo(node, event, context),
                  child: TextButtonEx(onPressed: () {}, text: translate(context, TR_NO))),
              Focus(
                  onKey: (node, event) => _onKeyYes(node, event, context),
                  focusNode: _buttonYes,
                  child: TextButtonEx(
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                      text: translate(context, TR_YES)))
            ])
          ]),
    );
  }

  KeyEventResult _onKeyYes(FocusNode node, RawKeyEvent event, BuildContext context) {
    return onKey(event, (keyCode) {
      switch (keyCode) {
        case KeyConstants.BACK:
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        case KeyConstants.KEY_LEFT:
          FocusScope.of(context).focusInDirection(TraversalDirection.left);
          return KeyEventResult.handled;
        case KeyConstants.KEY_CENTER:
          Navigator.of(context).pop();
          SystemNavigator.pop();
          return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    });
  }

  KeyEventResult _onKeyNo(FocusNode node, RawKeyEvent event, BuildContext context) {
    return onKey(event, (keyCode) {
      switch (keyCode) {
        case KeyConstants.BACK:
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        case KeyConstants.KEY_RIGHT:
          FocusScope.of(context).focusInDirection(TraversalDirection.right);
          return KeyEventResult.handled;
        case KeyConstants.KEY_CENTER:
          return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    });
  }
}
