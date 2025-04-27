import 'package:fastotv_dart/commands_info.dart';

class SerialSeasonNameIcon extends IDisplayContentInfo {
  final SeasonInfo _seasonInfo;

  SerialSeasonNameIcon(SeasonInfo serial) : _seasonInfo = serial;

  @override
  String displayName() {
    return _seasonInfo.displayName();
  }

  @override
  String icon() {
    return _seasonInfo.icon();
  }
}

class SerialSeason extends SerialSeasonNameIcon {
  SerialSeason(SeasonInfo channel) : super(channel);

  int get seasonNumber => _seasonInfo.season;

  String? get pid => _seasonInfo.pid;

  String get name => _seasonInfo.name;

  String get description => _seasonInfo.description;

  List<String> get episodesId => _seasonInfo.episodes;

  String get background => _seasonInfo.background;

  String get id => _seasonInfo.id;

  int viewCount() {
    return 0;
  }
}

class SerialNameIcon extends IDisplayContentInfo {
  final SerialInfo _serialInfo;

  SerialNameIcon(SerialInfo serial) : _serialInfo = serial;

  @override
  String displayName() {
    return _serialInfo.displayName();
  }

  @override
  String icon() {
    return _serialInfo.icon();
  }
}

class SerialStream extends SerialNameIcon {
  SerialStream(SerialInfo serial) : super(serial);

  String get id => _serialInfo.id;

  String? get pid => _serialInfo.id;

  String get name => _serialInfo.name;

  String get background => _serialInfo.background;

  List<String> get groups => _serialInfo.groups;

  String get description => _serialInfo.description;

  List<String> get seasonsIds => _serialInfo.seasons;

  PricePack? get price => _serialInfo.price;

  int get iarc => _serialInfo.iarc;

  int get primeDate => _serialInfo.primeDate;

  SerialInfo get serial => _serialInfo;

  bool favorite() {
    return _serialInfo.favorite();
  }

  void setFavorite(bool value) {
    _serialInfo.setFavorite(value);
  }
}
