import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/localization/translations.dart';

class ErrorDialog extends StatelessWidget {
  final String message;

  const ErrorDialog(this.message);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(title: const Text('Error'), content: Text(message), actions: <Widget>[
      TextButtonEx(onPressed: Navigator.of(context).pop, text: translate(context, TR_CLOSE))
    ]);
  }
}
