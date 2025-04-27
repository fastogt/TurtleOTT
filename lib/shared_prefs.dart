import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

const int IARC_DEFAULT_AGE = 21;
const int MAX_IARC_AGE = IARC_DEFAULT_AGE;

class LocalStorageService {
  static LocalStorageService? _instance;
  SharedPreferences? _preferences;

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService();

    _instance!._preferences ??= await SharedPreferences.getInstance();

    return _instance!;
  }

  static const String _ageRatingKey = 'iarc';

  static const String _emailField = 'email';
  static const String _passwordField = 'password';
  static const String _deviceField = 'device';
  static const String _serverField = 'server';
  static const String _accessToken = 'access_token';
  static const String _refreshToken = 'refresh_token';
  static const String _langCodeKey = 'lang_code';
  static const String _countryCodeKey = 'country_code';

  static const String _lockedMessageKey = 'locked_message';

  static const String _themeKey = 'themeKey';
  static const String _accentColorKey = 'accentColor';
  static const String _primaryColorKey = 'primaryColor';

  static const String _lastChannelKey = "last_channel";
  static const String _lastPackageKey = "last_package";
  static const String _isLastSaved = "save_last";
  static const String _soundAbsoluteKey = "sound_abs";
  static const String _brightnessAbsoluteKey = "brightness_abs";

  bool soundChange() {
    return _preferences!.getBool(_soundAbsoluteKey) ?? false;
  }

  bool brightnessChange() {
    return _preferences!.getBool(_brightnessAbsoluteKey) ?? false;
  }

  bool saveLastViewed() {
    return _preferences!.getBool(_isLastSaved) ?? false;
  }

  String? lastPackage() {
    return _preferences!.getString(_lastPackageKey);
  }

  String? lastChannel() {
    return _preferences!.getString(_lastChannelKey);
  }

  void setSoundChange(bool value) {
    _preferences!.setBool(_soundAbsoluteKey, value);
  }

  void setBrightnessChange(bool value) {
    _preferences!.setBool(_brightnessAbsoluteKey, value);
  }

  void setLastPackage(String? url) {
    if (url == null) {
      _preferences!.remove(_lastPackageKey);
    } else {
      _preferences!.setString(_lastPackageKey, url);
    }
  }

  void setLastChannel(String? url) {
    if (url == null) {
      _preferences!.remove(_lastChannelKey);
    } else {
      _preferences!.setString(_lastChannelKey, url);
    }
  }

  void setSaveLastViewed(bool value) {
    _preferences!.setBool(_isLastSaved, value);
  }

  void savePrimaryColor(Color color) {
    _preferences!.setInt(_primaryColorKey, color.value);
  }

  String? email() {
    return _preferences!.getString(_emailField);
  }

  String? password() {
    return _preferences!.getString(_passwordField);
  }

  String? device() {
    return _preferences!.getString(_deviceField);
  }

  String? server() {
    return _preferences!.getString(_serverField);
  }

  String? refreshToken() {
    return _preferences!.getString(_refreshToken);
  }

  String? accessToken() {
    return _preferences!.getString(_accessToken);
  }

  void setDevice(String value) {
    _preferences!.setString(_deviceField, value);
  }

  void setServer(String value) {
    _preferences!.setString(_serverField, value);
  }

  void setRefreshToken(String? value) {
    if (value == null) {
      _preferences!.remove(_refreshToken);
      return;
    }
    _preferences!.setString(_refreshToken, value);
  }

  void setAccessToken(String? value) {
    if (value == null) {
      _preferences!.remove(_accessToken);
      return;
    }

    _preferences!.setString(_accessToken, value);
  }

  int ageRating() {
    return _preferences!.getInt(_ageRatingKey) ?? IARC_DEFAULT_AGE;
  }

  void setAgeRating(int age) {
    _preferences!.setInt(_ageRatingKey, age);
  }

  String lockedMessage() {
    return _preferences!.getString(_lockedMessageKey) ?? '';
  }

  void setLockedMessage(String code) {
    _preferences!.setString(_lockedMessageKey, code);
  }

  String? langCode() {
    return _preferences!.getString(_langCodeKey);
  }

  void setLangCode(String code) {
    _preferences!.setString(_langCodeKey, code);
  }

  String? countryCode() {
    return _preferences!.getString(_countryCodeKey);
  }

  void setCountryCode(String? code) {
    if (code == null) {
      return;
    }
    _preferences!.setString(_countryCodeKey, code);
  }

  void saveAccentColor(Color color) {
    _preferences!.setInt(_accentColorKey, color.value);
  }

  Color? getAccentColor() {
    final _colorValue = _preferences!.getInt(_accentColorKey);
    if (_colorValue == null) {
      return null;
    }
    return Color(_colorValue);
  }

  void saveThemeID(String id) {
    _preferences!.setString(_themeKey, id);
  }

  String? themeID() {
    return _preferences!.getString(_themeKey);
  }

  Color? getPrimaryColor() {
    final _colorValue = _preferences!.getInt(_primaryColorKey);
    if (_colorValue == null) {
      return null;
    }
    return Color(_colorValue);
  }
}
