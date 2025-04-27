import 'package:fastotv_dart/commands_info/types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/base/border.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/utils/theme.dart';

class LockedPackageDialog extends StatelessWidget {
  final VoidCallback onBuyPressed;
  final bool? isTV;
  final double price;
  final Currency currency;

  const LockedPackageDialog(this.onBuyPressed, this.price, this.currency, {this.isTV});

  @override
  Widget build(BuildContext context) {
    if (isTV != null && isTV == true && !kIsWeb)
      return LockedPackageTV(onBuyPressed, price, currency);
    return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
        title: Text(translate(context, TR_ABOUT)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(translate(context, TR_ABOUT)),
          Text(price.toString().padRight(6) + currency.toHumanReadable()),
          TextButton(
              onPressed: onBuyPressed,
              child: RichText(
                  text: TextSpan(children: <TextSpan>[
                TextSpan(
                    text: translate(context, TR_BUY_STREAM),
                    style: TextStyle(
                      color: Theming.of(context).onBrightness(),
                      decoration: TextDecoration.underline,
                    ))
              ]))),
        ]),
        actions: <Widget>[TextButtonEx(onPressed: Navigator.of(context).pop, text: 'OK')]);
  }
}

class LockedPackageTV extends StatelessWidget {
  final VoidCallback onBuyPressed;
  final double price;
  final Currency currency;

  LockedPackageTV(this.onBuyPressed, this.price, this.currency);

  final FocusNode _buttonBuy = FocusNode();
  final FocusNode _buttonClose = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
        title: Text(translate(context, TR_ABOUT)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(translate(context, TR_ABOUT)),
          Text(price.toString().padRight(6) + currency.toHumanReadable()),
          FocusBorder(
            focus: _buttonBuy,
            child: TextButton(
                autofocus: true,
                focusNode: _buttonBuy,
                onPressed: onBuyPressed,
                child: RichText(
                    text: TextSpan(children: <TextSpan>[
                  TextSpan(
                      text: translate(context, TR_BUY_STREAM),
                      style: TextStyle(
                        color: Theming.of(context).onBrightness(),
                        decoration: TextDecoration.underline,
                      ))
                ]))),
          ),
        ]),
        actions: <Widget>[
          Focus(
            focusNode: _buttonClose,
            child: FocusBorder(
                focus: _buttonClose,
                child: TextButtonEx(onPressed: Navigator.of(context).pop, text: 'OK')),
          )
        ]);
  }
}

class LockedStreamDialog extends StatelessWidget {
  final VoidCallback onStreamBuyPressed;
  final bool? isTV;
  final double price;
  final Currency currency;

  const LockedStreamDialog(this.onStreamBuyPressed, this.price, this.currency, {this.isTV});

  @override
  Widget build(BuildContext context) {
    if (isTV != null && isTV == true && !kIsWeb)
      return LockedStreamTV(onStreamBuyPressed, price, currency);
    return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
        title: Text(translate(context, TR_ABOUT)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(translate(context, TR_ABOUT)),
          Text(price.toString().padRight(6) + currency.toHumanReadable()),
          TextButton(
              onPressed: onStreamBuyPressed,
              child: RichText(
                  text: TextSpan(children: <TextSpan>[
                TextSpan(
                    text: translate(context, TR_BUY_CHANNEL),
                    style: TextStyle(
                      color: Theming.of(context).onBrightness(),
                      decoration: TextDecoration.underline,
                    ))
              ]))),
        ]),
        actions: <Widget>[TextButtonEx(onPressed: Navigator.of(context).pop, text: 'OK')]);
  }
}

class LockedStreamTV extends StatelessWidget {
  final VoidCallback onStreamBuyPressed;
  final double price;
  final Currency currency;

  LockedStreamTV(this.onStreamBuyPressed, this.price, this.currency);

  final FocusNode _buttonBuy = FocusNode();
  final FocusNode _buttonClose = FocusNode();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
        title: Text(translate(context, TR_ABOUT)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(translate(context, TR_ABOUT)),
          Text(price.toString().padRight(6) + currency.toHumanReadable()),
          FocusBorder(
            focus: _buttonBuy,
            child: TextButton(
                autofocus: true,
                focusNode: _buttonBuy,
                onPressed: onStreamBuyPressed,
                child: RichText(
                    text: TextSpan(children: <TextSpan>[
                  TextSpan(
                      text: translate(context, TR_BUY_CHANNEL),
                      style: TextStyle(
                        color: Theming.of(context).onBrightness(),
                        decoration: TextDecoration.underline,
                      ))
                ]))),
          ),
        ]),
        actions: <Widget>[
          Focus(
            focusNode: _buttonClose,
            child: FocusBorder(
                focus: _buttonClose,
                child: TextButtonEx(onPressed: Navigator.of(context).pop, text: 'OK')),
          )
        ]);
  }
}
