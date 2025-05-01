// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:crocott_dart/types.dart';
import 'package:dart_common/dart_common.dart';
import 'package:fastotv_dart/commands_info/device_info.dart';
import 'package:fastotv_dart/commands_info/ott_server_info.dart';
import 'package:fastotv_dart/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/constants.dart';
import 'package:turtleott/epg_manager.dart';
import 'package:turtleott/fetcher.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:url_launcher/url_launcher.dart';

final class ErrorUI extends Error {
  static const int kErrInvalidInputHost = -7000;
  static const int kErrInvalidInputCode = -7001;
  static const int kErrInvalidInputLoginOrPassword = -7002;

  final int code;

  ErrorUI.invalidInputHost() : code = kErrInvalidInputHost;
  ErrorUI.invalidInputCode() : code = kErrInvalidInputCode;
  ErrorUI.invalidInputLoginOrPassword() : code = kErrInvalidInputLoginOrPassword;
}

class AppState {
  const AppState();
}

class RegistiredState extends AppState {}

class UnAuthenticateAppState extends AppState {
  const UnAuthenticateAppState();
}

class LoadingAppState extends AppState {
  final String text;

  const LoadingAppState(this.text);
}

class ErrorAppState extends AppState {
  final dynamic error;

  ErrorAppState(this.error);
}

class LogOutState extends AppState {
  LogOutState();
}

class AuthenticatedAppState extends AppState {
  final String server;
  final String device;

  final OttServerInfo info;

  const AuthenticatedAppState(this.server, this.device, this.info);
}

class AppBloc {
  final _controller = StreamController<AppState>();

  final Fetcher fetcher;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final codeController = TextEditingController();
  final hostController = TextEditingController(text: SERVER_HOST);
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  String get email => emailController.text;

  String get password => passwordController.text;

  String get code => codeController.text;

  String get host => hostController.text;

  String get firstName => firstNameController.text;

  String get lastName => lastNameController.text;

  Stream<AppState> get stream => _controller.stream;

  AppBloc({required this.fetcher});

  void start() {
    final epg = locator<EpgManager>();
    epg.setEpgHandler((cid) {
      return fetcher.getEpg(cid);
    });
  }

  void login(Tokens tokens) {
    final settings = locator<LocalStorageService>();
    settings.setRefreshToken(tokens.refresh);
    settings.setAccessToken(tokens.access);
  }

  void connect({required bool isLoginCode, required BuildContext context}) {
    bool _isUrlValid(String url) {
      try {
        final uri = Uri.parse(url);
        return (uri.isScheme('http') || uri.isScheme('https')) && uri.host.isNotEmpty;
      } catch (e) {
        return false;
      }
    }

    final settings = locator<LocalStorageService>();
    final device = settings.device();
    final accessToken = settings.accessToken();
    final refreshToken = settings.refreshToken();
    if (_isUrlValid(host)) {
      fetcher.setHost(host);
      signUP(accessToken, refreshToken, device, isLoginCode);
    } else {
      _emit(ErrorAppState(ErrorUI.invalidInputHost()));
      return;
    }
  }

  bool registerUser() {
    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      _emit(ErrorAppState(ErrorUI.invalidInputLoginOrPassword()));
      return false;
    }
    _emit(const LoadingAppState(TR_CONNECTION_SIN_UP));
    fetcher.setHost(host);
    fetcher.getLocale().then((locale) {
      fetcher
          .signupClient(SubscriberSignUpFront(
              email: email,
              password: password,
              firstName: firstNameController.text,
              lastName: lastName,
              country: locale.currentCountry,
              language: locale.currentLanguage))
          .then((SubProfile profile) {
        _emit(RegistiredState());
        return true;
      }).catchError((error) {
        _emit(ErrorAppState(error));
        return false;
      });
    });

    return true;
  }

  void logout() {
    final settings = locator<LocalStorageService>();
    settings.setAccessToken(null);
    settings.setRefreshToken(null);
    _emit(LogOutState());
  }

  void signUP(String? accessToken, String? refreshToken, String? device, bool isCode) async {
    if (accessToken != null && refreshToken != null && device != null) {
      final tokens = Tokens(refresh: refreshToken, access: accessToken);
      fetcher.setTokens(tokens);
      final info = await fetcher.getServerInfo();
      _emit(AuthenticatedAppState(fetcher.directHost, device, info));
      start();
      return;
    }

    if (isCode) {
      loginWithCode(device);
    } else {
      loginWithPassword(device);
    }
  }

  void loginWithPassword(String? device) async {
    if (email.isEmpty || password.isEmpty) {
      _emit(ErrorAppState(ErrorHttp(401, TR_ERR_WRONG_LOG_PAS, null)));
      return;
    }

    _emit(const LoadingAppState(TR_CONNECTING));

    if (device == null) {
      _emit(const LoadingAppState(TR_REQUEST_DEVICES));
      List<DeviceInfo> devices = [];
      try {
        devices = await fetcher.getDevices(email, password);
      } catch (error) {
        _emit(ErrorAppState(error));
        return;
      }

      if (devices.isEmpty) {
        _emit(const LoadingAppState(TR_REQUEST_NEW_DEVICE));
        try {
          final hwDevice = locator<RuntimeDevice>();
          final DeviceInfo device = await fetcher.requestDevice(email, password, hwDevice.name);
          devices.add(device);
        } catch (error) {
          _emit(ErrorAppState(error));
          return;
        }
      }

      if (devices.isNotEmpty) {
        device = devices[0].id;
      }
    }

    if (device == null) {
      _emit(ErrorAppState(ErrorHttp(401, TR_PLEASE_CREATE_DEVICE, null)));
      return;
    }

    try {
      _emit(const LoadingAppState(TR_AUTHORIZATION));
      final tokens = await fetcher.login(email, password, device);
      if (tokens == null) {
        _emit(ErrorAppState(ErrorHttp(401, TR_ERR_WRONG_LOG_PAS, null)));
        return;
      }

      final info = await fetcher.getServerInfo();
      _emit(AuthenticatedAppState(fetcher.directHost, device, info));
      start();
    } catch (error) {
      _emit(ErrorAppState(error));
    }
  }

  void loginWithCode(String? device) async {
    if (code.isEmpty) {
      _emit(ErrorAppState(ErrorHttp(401, TR_ERR_WRONG_CODE, null)));
      return;
    }

    _emit(const LoadingAppState(TR_CONNECTING));

    if (device == null) {
      _emit(const LoadingAppState(TR_REQUEST_DEVICES));
      List<DeviceInfo> devices = [];
      try {
        devices = await fetcher.getDevicesByCode(code);
      } catch (error) {
        _emit(ErrorAppState(error));
        return;
      }

      if (devices.isEmpty) {
        _emit(const LoadingAppState(TR_REQUEST_NEW_DEVICE));
        try {
          final hwDevice = locator<RuntimeDevice>();
          final DeviceInfo device = await fetcher.requestDeviceByCode(code, hwDevice.name);
          devices.add(device);
        } catch (error) {
          _emit(ErrorAppState(error));
          return;
        }
      }

      if (devices.isNotEmpty) {
        device = devices[0].id;
      }
    }

    if (device == null) {
      _emit(ErrorAppState(ErrorHttp(401, TR_PLEASE_CREATE_DEVICE, null)));
      return;
    }

    try {
      _emit(const LoadingAppState(TR_AUTHORIZATION));
      final tokens = await fetcher.loginByCode(code, device);
      if (tokens == null) {
        _emit(ErrorAppState(ErrorHttp(401, TR_ERR_WRONG_CODE, null)));
        return;
      }

      final info = await fetcher.getServerInfo();
      _emit(AuthenticatedAppState(fetcher.directHost, device, info));
      start();
    } catch (error) {
      _emit(ErrorAppState(error));
    }
  }

  void launchPolicy(String host) {
    final Uri? url = Uri.tryParse('$host/#/privacy');
    if (url != null) {
      canLaunchUrl(url).then((value) {
        if (value) {
          launchUrl(url);
        }
      });
    }
  }

  void launchTerms(String host) {
    final Uri? url = Uri.tryParse('$host/#/terms');
    if (url != null) {
      canLaunchUrl(url).then((value) {
        if (value) {
          launchUrl(url);
        }
      });
    }
  }

  void _emit(AppState newState) {
    if (!_controller.isClosed) {
      _controller.add(newState);
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    codeController.dispose();
    hostController.dispose();
    _controller.close();
  }
}
