import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/localization/translations.dart';

class NoAvaiableChannels extends StatelessWidget {
  final String title;

  const NoAvaiableChannels({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.warning_rounded),
            Text(translate(context, TR_EXIT)),
            Text(translate(context, title)),
            Text(translate(context, TR_YES))
          ],
        ),
      ),
    );
  }
}
