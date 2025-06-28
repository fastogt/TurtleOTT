import 'dart:async';

import 'package:crocott_dart/types.dart';
import 'package:fastotv_dart/commands_info.dart';
import 'package:fastotv_dart/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_common/flutter_common.dart';

import 'package:turtleott/epg_manager.dart';
import 'package:turtleott/fetcher.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';

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

class UnAuthenticateAppState extends AppState {
  const UnAuthenticateAppState();
}

class RegisteredState extends AppState {}

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
  final String server; // save to settings
  final String device; // save to settings
  final OttServerInfo info;

  const AuthenticatedAppState(this.server, this.device, this.info);
}

class AppBloc {
  final _controller = StreamController<AppState>();

  final Fetcher fetcher;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final codeController = TextEditingController();
  late final hostController = TextEditingController(text: fetcher.directHost);
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  String get email => emailController.text;

  String get password => passwordController.text;

  String get code => codeController.text;

  String get host => hostController.text;

  String get firstName => firstNameController.text;

  String get lastName => lastNameController.text;

  Stream<AppState> get stream => _controller.stream;

  AppBloc({required this.fetcher});

  void _start() {
    final epg = locator<EpgManager>();
    epg.setEpgHandler((cid) {
      return fetcher.getEpg(cid);
    });
  }

  void connect({required bool isLoginCode}) {
    bool isUrlValid(String url) {
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
    if (isUrlValid(host)) {
      fetcher.setHost(host); // setBrand can change host
      loginWith(accessToken, refreshToken, device, isLoginCode);
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

    _emit(const LoadingAppState(TR_CONNECTION_SIGN_UP));
    fetcher.setHost(host);

    final resp = fetcher.getLocale();
    resp.then((locale) {
      final sign = SubscriberSignUpFront(
          email: email,
          password: password,
          firstName: firstNameController.text,
          lastName: lastName,
          country: locale.currentCountry,
          language: locale.currentLanguage);
      fetcher.signupClient(sign).then((SubProfile profile) {
        _emit(RegisteredState());
        return true;
      }, onError: (error) {
        _emit(ErrorAppState(error));
        return false;
      });
    }, onError: (error) {
      _emit(ErrorAppState(error));
      return false;
    });

    return true;
  }

  void login(Tokens tokens) {
    final settings = locator<LocalStorageService>();
    settings.setRefreshToken(tokens.refresh);
    settings.setAccessToken(tokens.access);
  }

  void logout() {
    final settings = locator<LocalStorageService>();
    settings.setAccessToken(null);
    settings.setRefreshToken(null);
    _emit(LogOutState());
  }

  void moveOnHome(String device) {
    _emit(const LoadingAppState(TR_GET_SERVER_INFO));
    final res = fetcher.getServerInfo();
    res.then((info) {
      _emit(AuthenticatedAppState(fetcher.directHost, device, info));
      _start();
    }, onError: (error) {
      _emit(ErrorAppState(error));
    });
  }

  void loginWith(String? accessToken, String? refreshToken, String? device, bool isCode) {
    if (refreshToken != null && device != null) {
      final tokens = Tokens(refresh: refreshToken, access: accessToken);
      fetcher.setTokens(tokens);
      moveOnHome(device);
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
      _emit(ErrorAppState(ErrorUI.invalidInputLoginOrPassword()));
      return;
    }

    _emit(const LoadingAppState(TR_CONNECTING));
    if (device == null) {
      // that's why we need to save device id, not only tokens, for reset command
      _emit(const LoadingAppState(TR_REQUEST_DEVICES));
      try {
        final List<DeviceInfo> devices = await fetcher.getDevices(email, password);
        if (devices.isEmpty) {
          _emit(const LoadingAppState(TR_REQUEST_NEW_DEVICE));
          final hwDevice = locator<RuntimeDevice>();
          final DeviceInfo device = await fetcher.requestDevice(email, password, hwDevice.name);
          devices.add(device);
        }
        device = devices[0].id;
      } catch (error) {
        _emit(ErrorAppState(error));
        return;
      }
    }

    _emit(const LoadingAppState(TR_AUTHORIZATION));
    tryToLoginByEmail(device, 1);
  }

  void tryToLoginByEmail(String device, int redirect) {
    final res = fetcher.login(email, password, device);
    res.then((tokens) {
      if (tokens.origin != null) {
        fetcher.setHost(tokens.origin!);
      }
      moveOnHome(device);
    }, onError: (error) {
      _emit(ErrorAppState(error));
    });
  }

  void loginWithCode(String? device) async {
    if (code.isEmpty) {
      _emit(ErrorAppState(ErrorUI.invalidInputCode()));
      return;
    }

    _emit(const LoadingAppState(TR_CONNECTING));
    if (device == null) {
      _emit(const LoadingAppState(TR_REQUEST_DEVICES));
      try {
        final List<DeviceInfo> devices = await fetcher.getDevicesByCode(code);
        if (devices.isEmpty) {
          _emit(const LoadingAppState(TR_REQUEST_NEW_DEVICE));
          final hwDevice = locator<RuntimeDevice>();
          final DeviceInfo device = await fetcher.requestDeviceByCode(code, hwDevice.name);
          devices.add(device);
        }

        device = devices[0].id;
      } catch (error) {
        _emit(ErrorAppState(error));
        return;
      }
    }

    _emit(const LoadingAppState(TR_AUTHORIZATION));
    tryToLoginByCode(device, 1);
  }

  void tryToLoginByCode(String device, int redirect) {
    final res = fetcher.loginByCode(code, device);
    res.then((tokens) {
      if (tokens.origin != null) {
        fetcher.setHost(tokens.origin!);
      }
      moveOnHome(device);
    }, onError: (error) {
      _emit(ErrorAppState(error));
    });
  }

  void launchPolicy(String host) {
    fetcher.launchPolicy(host);
  }

  void launchTerms(String host) {
    fetcher.launchTerms(host);
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
