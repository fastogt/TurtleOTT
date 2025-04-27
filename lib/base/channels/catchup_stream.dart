import 'package:fastotv_dart/commands_info.dart';
import 'package:turtleott/base/channels/istream.dart';

class CatchupStream extends IStream {
  final CatchupInfo _channelInfo;

  CatchupStream(CatchupInfo channel) : _channelInfo = channel;

  @override
  String id() {
    return _channelInfo.id;
  }

  @override
  String? pid() {
    return _channelInfo.pid;
  }

  String epgId() {
    return _channelInfo.epg.id;
  }

  @override
  PlayingUrl primaryUrl() {
    final urls = _channelInfo.urls();
    return urls[0];
  }

  @override
  List<PlayingUrl> get urls {
    return _channelInfo.epg.urls;
  }

  List<Subtitle> get subtitles {
    return _channelInfo.subtitles;
  }

  int start() {
    return _channelInfo.start;
  }

  int stop() {
    return _channelInfo.stop;
  }

  @override
  String displayName() {
    return _channelInfo.displayName();
  }

  @override
  List<String> groups() {
    return _channelInfo.groups;
  }

  @override
  String icon() {
    return _channelInfo.epg.icon;
  }

  PricePack? get price {
    return _channelInfo.price;
  }

  @override
  int iarc() {
    return _channelInfo.iarc;
  }

  @override
  bool favorite() {
    return _channelInfo.favorite();
  }

  @override
  void setFavorite(bool value) {
    _channelInfo.setFavorite(value);
  }

  @override
  int recentTime() {
    return _channelInfo.recentTime();
  }

  @override
  void setRecentTime(int value) {
    _channelInfo.setRecentTime(value);
  }
}

extension CatchupDisplay on CatchupInfo {
  String subtitle() {
    final DateTime startTime = DateTime.fromMillisecondsSinceEpoch(start);
    final DateTime stopTime = DateTime.fromMillisecondsSinceEpoch(stop);

    String formatTime(DateTime time) {
      final int hour = time.hour;
      final int minute = time.minute;
      final String period = hour >= 12 ? 'PM' : 'AM';
      final int formattedHour = hour % 12 == 0 ? 12 : hour % 12;
      final String formattedMinute = minute.toString().padLeft(2, '0');
      return '$formattedHour:$formattedMinute $period';
    }

    String formatDate(DateTime time) {
      return '${time.month}/${time.day}';
    }

    return '${formatDate(startTime)}'
        ' / ${formatTime(startTime)}'
        ' - ${formatTime(stopTime)}';
  }
}
