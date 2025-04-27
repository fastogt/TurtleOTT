import 'package:fastotv_dart/commands_info.dart';
import 'package:turtleott/localization/translations.dart';

(OttPackageInfo, List<OttPackageInfo>) generateIPTVPackages(List<OttPackageInfo> content) {
  final all = OttPackageInfo(
      name: TR_ALL,
      description: 'Fake package',
      backgroundUrl: '',
      streams: [],
      vods: [],
      serials: []);

  final Map<String, OttPackageInfo> _channelsMap = {TR_ALL: all};

  for (final package in content) {
    for (final stream in package.streams) {
      void _savePushChannel(String category, ChannelInfo element) {
        if (category.isEmpty) {
          return;
        }

        if (!_channelsMap.containsKey(category)) {
          _channelsMap[category] = OttPackageInfo(
              name: category,
              description: 'Fake package',
              backgroundUrl: '',
              streams: [],
              vods: [],
              serials: []);
        }
        _channelsMap[category]!.streams.add(element);
      }

      all.streams.add(stream);
      final unique = stream.groups.toSet();
      for (final singleGroup in unique) {
        _savePushChannel(singleGroup, stream);
      }
    }
    for (final vod in package.vods) {
      void _savePushVod(String category, VodInfo element) {
        if (category.isEmpty) {
          return;
        }

        if (!_channelsMap.containsKey(category)) {
          _channelsMap[category] = OttPackageInfo(
              name: category,
              description: 'Fake package',
              backgroundUrl: '',
              streams: [],
              vods: [],
              serials: []);
        }
        _channelsMap[category]!.vods.add(element);
      }

      all.vods.add(vod);
      final unique = vod.groups.toSet();
      for (final singleGroup in unique) {
        _savePushVod(singleGroup, vod);
      }
    }
    for (final serial in package.serials) {
      void _savePushSerial(String category, SerialInfo element) {
        if (category.isEmpty) {
          return;
        }

        if (!_channelsMap.containsKey(category)) {
          _channelsMap[category] = OttPackageInfo(
              name: category,
              description: 'Fake package',
              backgroundUrl: '',
              streams: [],
              vods: [],
              serials: []);
        }
        _channelsMap[category]!.serials.add(element);
      }

      all.serials.add(serial);
      final unique = serial.groups.toSet();
      for (final singleGroup in unique) {
        _savePushSerial(singleGroup, serial);
      }
    }
  }

  final List<OttPackageInfo> result = [];
  _channelsMap.forEach((key, value) {
    result.add(value);
  });

  return (all, result);
}
