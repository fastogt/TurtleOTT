import 'package:flutter/material.dart';
import 'package:turtleott/app_config.dart';
import 'package:turtleott/main/main_common.dart';
import 'package:turtleott/utils/theme.dart';

void main() async {
  await mainCommon();
  const configuredApp = AppConfig(buildType: BuildType.DEV, child: Theming(child: MyApp()));
  runApp(configuredApp);
}
