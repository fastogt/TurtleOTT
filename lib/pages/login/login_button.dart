import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';

class LoginButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const LoginButton(this.title, this.onTap);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.maxFinite,
        height: 48,
        child: FlatButtonEx.filled(
            text: translate(context, title),
            onPressed: onTap,
            focusNode: FocusNode(onKey: _onKeyPressed)));
  }

  KeyEventResult _onKeyPressed(FocusNode node, RawKeyEvent event) {
    return onKey(event, (keyCode) {
      switch (keyCode) {
        case KeyConstants.KEY_CENTER:
          onTap?.call();
          return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    });
  }
}
