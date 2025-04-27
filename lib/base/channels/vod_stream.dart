import 'package:fastotv_dart/commands_info.dart';
import 'package:turtleott/base/channels/istream.dart';

class VodStream extends IStream {
  final VodInfo _channelInfo;

  VodStream(VodInfo channel) : _channelInfo = channel;

  @override
  String id() {
    return _channelInfo.id;
  }

  @override
  String? pid() {
    return _channelInfo.pid;
  }

  @override
  PlayingUrl primaryUrl() {
    final urls = _channelInfo.urls();
    return urls[0];
  }

  @override
  List<PlayingUrl> get urls {
    return _channelInfo.vod.urls;
  }

  @override
  String displayName() {
    return _channelInfo.displayName();
  }

  PricePack? get price {
    return _channelInfo.price;
  }

  double userScore() {
    return _channelInfo.userScore();
  }

  int duration() {
    return _channelInfo.duration();
  }

  int primeDate() {
    return _channelInfo.primeDate();
  }

  String trailerUrl() {
    return _channelInfo.trailerUrl();
  }

  String country() {
    return _channelInfo.country();
  }

  @override
  List<String> groups() {
    return _channelInfo.groups;
  }

  String previewIcon() {
    return _channelInfo.vod.previewIcon;
  }

  String background() {
    return _channelInfo.vod.backgroundIcon;
  }

  @override
  String icon() {
    return previewIcon();
  }

  String description() {
    return _channelInfo.vod.description;
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

  int interruptTime() {
    return _channelInfo.interruptTime();
  }

  void setInterruptTime(int value) {
    _channelInfo.setInterruptTime(value);
  }

  @override
  int recentTime() {
    return _channelInfo.recentTime();
  }

  @override
  void setRecentTime(int value) {
    _channelInfo.setRecentTime(value);
  }

  List<Subtitle> get subtitles {
    return _channelInfo.subtitles;
  }

  List<MetaUrl> get meta {
    return _channelInfo.meta;
  }
}
