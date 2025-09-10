import 'package:flutter_common/flutter_common.dart';
import 'package:get_it/get_it.dart';
import 'package:turtleott/constants.dart';
import 'package:turtleott/epg_manager.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:dart_common/types.dart';

// https://www.filledstacks.com/snippet/shared-preferences-service-in-flutter-for-code-maintainability/

GetIt locator = GetIt.instance;

ProjectAlias projectName() {
  return PROJECT_NAME.toLowerCase();
}

HumanReadableVersion projectVersion() {
  final package = locator<PackageManager>();
  final ver = package.version();
  final build = package.buildNumber();
  final result = '$ver.$build Revision: ffffffff';
  final hm = HumanReadableVersion(result);
  return hm;
}

String projectUserAgent() {
  final proj = projectName();
  final ver = projectVersion();
  final result = '$proj/$ver';
  return result;
}

Future setupLocator() async {
  final device = await RuntimeDevice.getInstance();
  locator.registerSingleton<RuntimeDevice>(device);

  final package = await PackageManager.getInstance();
  locator.registerSingleton<PackageManager>(package);

  final storage = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(storage);

  final time = await TimeManager.getInstance();
  locator.registerSingleton<TimeManager>(time);

  final epg = await EpgManager.getInstance();
  locator.registerSingleton<EpgManager>(epg);
}
