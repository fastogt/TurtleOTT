import 'package:fastotv_dart/commands_info.dart';

abstract class IStream extends IDisplayContentInfo {
  String id();

  String? pid();

  PlayingUrl primaryUrl();

  List<String> groups();

  int iarc();

  bool favorite();

  void setFavorite(bool value);

  int recentTime();

  void setRecentTime(int value);

  List<PlayingUrl> get urls;
}
