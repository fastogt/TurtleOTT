import 'dart:convert';

import 'package:crocott_dart/error_codes.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/localization/translations.dart';

const String TR_ERR_WRONG_LOG_PAS = 'wrong login or password';
const String TR_ERR_WRONG_CODE = 'wrong code';

const String TR_ERR_CLIENT_NOT_ACTIVE = 'client not active';
const String TR_ERR_ALREADY_SIGHUP = 'already signup';
const String TR_ERR_EXPIRED_ACCOUNT = 'expired account';
const String TR_ERR_MAX_DEVICES_COUNT = 'max count devices';
const String TR_ERR_BANNED_DEVICE = 'banned device';
const String TR_NOT_FOUND_DEVICE = 'not found device';
const String TR_ERR_COUNTRY = 'App is not available in your country';
const String TR_ERR_CONFLICT = 'not available';
const String TR_ERROR = 'Error';

extension Context on BuildContext {
  String errorBackendTextWithoutToken(int code) {
    String text;
    switch (code) {
      case ErrorCodes.kErrInvalidInput:
        text = translate(this, TR_INCORRECT_PASSWORD);
        break;
      case ErrorCodes.kClientErrLoginOrPass:
        text = translate(this, TR_ERR_WRONG_LOG_PAS);
        break;
      case ErrorCodes.kClientErrCode:
        text = translate(this, TR_ERR_WRONG_CODE);
        break;
      case ErrorCodes.kClientErrBannedDevice:
        text = translate(this, TR_ERR_BANNED_DEVICE);
        break;
      case ErrorCodes.kClientErrExpiredAccount:
        text = translate(this, TR_ERR_EXPIRED_ACCOUNT);
        break;
      case ErrorCodes.kClientErrMaxCountDevices:
        text = translate(this, TR_ERR_MAX_DEVICES_COUNT);
        break;
      case ErrorCodes.kClientErrNotActive:
        text = translate(this, TR_ERR_CLIENT_NOT_ACTIVE);
        break;
      case ErrorCodes.kClientErrNotFoundDev:
        text = translate(this, TR_NOT_FOUND_DEVICE);
        break;
      // common errors
      case ErrorCodes.kErrInternal:
        text = translate(this, TR_ERROR);
        break;
      case ErrorCodes.kErrParseResponse:
        text = translate(this, TR_ERROR);
        break;
      case ErrorCodes.kErrForrbiddenByConflict:
        text = translate(this, TR_ERR_CONFLICT);
        break;
      case ErrorCodes.kErrForrbiddenAction:
        text = translate(this, TR_ERR_COUNTRY);
        break;
      default:
        text = translate(this, TR_ERROR);
    }
    return text;
  }

  void nextEditableTextFocus() {
    do {
      FocusScope.of(this).nextFocus();
    } while (FocusScope.of(this).focusedChild!.context == null);
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }
}
