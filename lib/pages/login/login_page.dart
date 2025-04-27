import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/pages/debug_page.dart';

class LoginLoading extends StatelessWidget {
  final String state;

  const LoginLoading(this.state);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const CircularProgressIndicator(),
      const SizedBox(height: 16),
      Text(translate(context, state))
    ]));
  }
}

class LoginFooter extends StatelessWidget {
  const LoginFooter();

  @override
  Widget build(BuildContext context) {
    return TextButtonTheme(
        data: TextButtonThemeData(
            style: Theme.of(context)
                .textButtonTheme
                .style!
                .copyWith(minimumSize: WidgetStateProperty.all<Size>(const Size(48, 48)))),
        child: const VersionTile.login());
  }
}
