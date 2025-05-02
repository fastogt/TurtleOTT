import 'package:crocott_dart/api.dart';
import 'package:crocott_dart/player.dart';
import 'package:dart_common/types.dart';
import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/service_locator.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CrocOTTImpl extends ICrocOTTPlayer {
  CrocOTTImpl(
      {required String host,
      OnTokenChangedCallback? onTokenChanged,
      OnNeedHelpCallback? onNeedHelp})
      : super(host: host, onTokenChanged: onTokenChanged, onNeedHelp: onNeedHelp);

  @override
  ClientInfo getDeviceInfo(String did) {
    final device = locator<RuntimeDevice>();
    final os = OperationSystemInfo(
        name: PlatformType.fromString(device.platform),
        version: device.version,
        arch: device.arch,
        ramTotal: 0,
        ramFree: 0);
    final project = Project(name: projectName(), version: projectVersion());
    return ClientInfo(id: did, project: project, os: os, cpuBrand: device.cpuBrand);
  }
}

class Fetcher extends CrocOTTAPI {
  Fetcher({required ICrocOTTPlayer impl}) : super(impl: impl);

  Future<bool> launchExternalUrl(String url, {LaunchMode mode = LaunchMode.platformDefault}) {
    return launchUrlString(url, mode: mode);
  }

  void launchPolicy(String host) {
    final url = impl.policyLink(host);
    if (url != null) {
      launchExternalUrl(url);
    }
  }

  void launchTerms(String host) {
    final url = impl.termsLink(host);
    if (url != null) {
      launchExternalUrl(url);
    }
  }
}
