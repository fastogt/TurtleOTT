import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/extension.dart';

class AgeSelector extends StatefulWidget {
  final String passwordHash;

  const AgeSelector(this.passwordHash);

  @override
  _AgeSelectorState createState() {
    return _AgeSelectorState();
  }
}

class _AgeSelectorState extends State<AgeSelector> {
  int age = IARC_DEFAULT_AGE;
  static const ITEM_HEIGHT = 48.0;
  TextEditingController passwordController = TextEditingController();
  bool authorized = false;
  bool validatePassword = true;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    age = settings.ageRating();
    passwordController.text = '';
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  String? _errorText() {
    if (validatePassword) {
      return null;
    }

    if (passwordController.text.isEmpty) {
      return tryTranslate(context, TR_ERROR_FORM);
    } else if (context.generateMd5(passwordController.text) != widget.passwordHash) {
      return tryTranslate(context, TR_INCORRECT_PASSWORD);
    }
    return null;
  }

  bool _validate() {
    return passwordController.text.isNotEmpty &&
        widget.passwordHash == context.generateMd5(passwordController.text);
  }

  Widget _passwordField() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
              controller: passwordController,
              obscureText: true,
              onChanged: (String text) {
                validatePassword = _validate();
              },
              onFieldSubmitted: (term) {
                validatePassword = _validate();
              },
              decoration: InputDecoration(
                  fillColor: Colors.amber,
                  focusColor: Colors.amber,
                  labelStyle: const TextStyle(color: Color(0xFF424242)),
                  hintText: tryTranslate(context, TR_PASSWORD),
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  errorText: _errorText()))
        ]);
  }

  Widget _picker() {
    final scrollBehavior = const MaterialScrollBehavior()
        .copyWith(dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch});
    return Stack(children: <Widget>[
      Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ScrollConfiguration(
              behavior: scrollBehavior,
              child: NumberPicker(
                  itemHeight: ITEM_HEIGHT,
                  value: age,
                  minValue: 0,
                  maxValue: IARC_DEFAULT_AGE,
                  onChanged: (value) {
                    setState(() {
                      age = value;
                    });
                  }),
            )
          ]),
      const SizedBox(
          height: ITEM_HEIGHT * 3,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[Spacer(), Divider(), Spacer(), Divider(), Spacer()]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(!authorized
                ? translate(context, TR_PARENTAL_CONTROL)
                : translate(context, TR_AGE_RESTRICTION)),
          ],
        ),
        content: !authorized ? _passwordField() : _picker(),
        contentPadding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0.0),
        actions: <Widget>[
          TextButtonEx(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: translate(context, TR_CANCEL)),
          TextButtonEx(
              onPressed: () {
                if (!authorized) {
                  setState(() {
                    validatePassword = _validate();
                  });
                  if (validatePassword) {
                    setState(() {
                      authorized = true;
                    });
                  }
                } else {
                  Navigator.of(context).pop(age.toInt());
                }
              },
              text: translate(context, TR_SUBMIT))
        ]);
  }
}

class CheckPassword extends StatefulWidget {
  final dynamic route;

  const CheckPassword({this.route, Key? key}) : super(key: key);

  @override
  State<CheckPassword> createState() => _CheckPasswordState();
}

class _CheckPasswordState extends State<CheckPassword> {
  String? password;
  TextEditingController passwordController = TextEditingController();
  bool validatePassword = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(translate(context, TR_PARENTAL_CONTROL)),
        content: _passwordField(),
        contentPadding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0.0),
        actions: <Widget>[
          TextButtonEx(
              onPressed: () {
                Navigator.of(context).pop(validatePassword);
              },
              text: translate(context, TR_CANCEL)),
          TextButtonEx(
              onPressed: () {
                setState(() {
                  validatePassword = _validate();
                });
                if (validatePassword) {
                  Navigator.pop(context, validatePassword);
                  if (widget.route != null) {
                    Navigator.push(context, widget.route!);
                  }
                }
              },
              text: translate(context, TR_SUBMIT))
        ]);
  }

  Widget _passwordField() {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextFormField(
              controller: passwordController,
              obscureText: true,
              onChanged: (String text) {
                validatePassword = _validate();
              },
              onFieldSubmitted: (term) {
                validatePassword = _validate();
              },
              decoration: InputDecoration(
                  fillColor: Colors.amber,
                  focusColor: Colors.amber,
                  labelStyle: const TextStyle(color: Color(0xFF424242)),
                  hintText: tryTranslate(context, TR_PASSWORD),
                  contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                  errorText: _errorText()))
        ]);
  }

  bool _validate() {
    return passwordController.text.isNotEmpty && password == passwordController.text;
  }

  String? _errorText() {
    if (validatePassword) {
      return null;
    }

    if (passwordController.text.isEmpty) {
      return tryTranslate(context, TR_ERROR_FORM);
    } else if (passwordController.text != password) {
      return tryTranslate(context, TR_INCORRECT_PASSWORD);
    }
    return null;
  }
}
