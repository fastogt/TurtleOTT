import 'package:fastotv_dart/commands_info/types.dart';
import 'package:flutter/material.dart';

enum BuildType { DEV, BRAND }

class AppConfig extends InheritedWidget {
  const AppConfig(
      {required this.buildType,
      this.canRequest = true,
      this.hasMultiscreen = true,
      this.wsMode = WsMode.OTT,
      required Widget child})
      : super(child: child);

  final BuildType buildType;
  final bool canRequest;
  final bool hasMultiscreen;
  final WsMode wsMode;

  static AppConfig of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<AppConfig>()!;
  }

  bool get isOTT {
    return wsMode == WsMode.OTT;
  }

  bool get isDev {
    return buildType == BuildType.DEV;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
