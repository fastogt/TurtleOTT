import 'package:fastotv_dart/commands_info.dart';
import 'package:turtleott/base/channels/istream.dart';

class LiveStream extends IStream {
  final ChannelInfo _channelInfo;

  LiveStream(ChannelInfo channel) : _channelInfo = channel;

  @override
  bool operator ==(Object other) {
    return (other is LiveStream) &&
        other._channelInfo.id == _channelInfo.id &&
        other._channelInfo.pid == _channelInfo.pid;
  }

  @override
  int get hashCode => Object.hash(_channelInfo.id, _channelInfo.pid);

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

  CatchupInfo? findCatchupByTime(int start, int stop, List<CatchupInfo> catchups) {
    return _channelInfo.findCatchupByTime(start, stop, catchups);
  }

  List<String> parts() {
    return _channelInfo.parts;
  }

  void addPart(String catchupId) {
    _channelInfo.parts.add(catchupId);
  }

  void deletePart(String catchupId) {
    _channelInfo.parts.remove(catchupId);
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
