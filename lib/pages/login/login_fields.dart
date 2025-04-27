import 'dart:async';

import 'package:crocott_dart/crocott_public.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/base/border.dart';
import 'package:turtleott/base/login/textfields.dart';
import 'package:turtleott/constants.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/login/login_button.dart';
import 'package:turtleott/pages/login/login_fields_mobile.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({required this.message, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          message,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ));
  }
}

Widget _textField(BuildContext context, String hintText, TextFieldNode? node,
    TextEditingController controller, TextInputType textTypeKeyboard, bool? autoFocus) {
  return LoginTextField(
      mainFocus: node?.main,
      controller: controller,
      hintText: tryTranslate(context, hintText),
      obscureText: hintText == TR_PASSWORD,
      key: ValueKey(controller),
      keyboardType: textTypeKeyboard);
}

enum AuthMode { signIn, signUp, codeLogin }

class LoginFields extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController codeController;
  final TextEditingController hostController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;

  final bool Function(AuthMode mode) onButton;
  final bool isDev;
  final bool isNeedFocus;
  final String? server;
  final String? errorText;

  const LoginFields.needFocus(
      this.firstNameController,
      this.lastNameController,
      this.emailController,
      this.passwordController,
      this.codeController,
      this.hostController,
      this.onButton,
      this.isDev,
      this.server,
      this.errorText,
      {Key? key})
      : isNeedFocus = true,
        super(key: key);

  const LoginFields.noNeedFocus(
      this.firstNameController,
      this.lastNameController,
      this.emailController,
      this.passwordController,
      this.codeController,
      this.hostController,
      this.onButton,
      this.isDev,
      this.server,
      this.errorText,
      {Key? key})
      : isNeedFocus = false,
        super(key: key);

  @override
  LoginFieldsState createState() {
    return LoginFieldsState();
  }
}

class LoginFieldsState extends State<LoginFields> {
  TextFieldNode? _firstNameNode;
  TextFieldNode? _lastNameNode;
  TextFieldNode? _emailNode;
  TextFieldNode? _passwordNode;
  TextFieldNode? _codeNode;

  AuthMode mode = AuthMode.signIn;

  TextEditingController get _firstNameController => widget.firstNameController;

  TextEditingController get _lastNameController => widget.lastNameController;

  TextEditingController get _emailController => widget.emailController;

  TextEditingController get _passwordController => widget.passwordController;

  TextEditingController get _codeController => widget.codeController;

  String? _errorText;

  @override
  void initState() {
    _errorText = widget.errorText;
    super.initState();
    if (widget.isNeedFocus) {
      _firstNameNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: !kIsWeb));
      _lastNameNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: !kIsWeb));
      _emailNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: !kIsWeb));
      _passwordNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: !kIsWeb));
      _codeNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: !kIsWeb));
    }
  }

  Widget authConfigChanger() {
    return mode != AuthMode.signUp
        ? Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text(translate(context, TR_NO_ACCOUNT),
                style: TextStyle(color: Colors.black.withOpacity(0.3))),
            TextButton(
                onPressed: () {
                  _clearErrorText();
                  setState(() {
                    mode = AuthMode.signUp;
                  });
                },
                child: Text(translate(context, TR_SIGN_UP),
                    style: const TextStyle(fontWeight: FontWeight.bold)))
          ])
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text(translate(context, TR_ALREADY_HAVE_ACCOUNT),
                style: TextStyle(color: Colors.black.withOpacity(0.3))),
            TextButton(
                onPressed: () {
                  _clearErrorText();
                  setState(() {
                    mode = AuthMode.signIn;
                  });
                },
                child: Text(translate(context, TR_SIGN_IN),
                    style: const TextStyle(fontWeight: FontWeight.bold)))
          ]);
  }

  Widget _authHeader(String title) {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 24)),
      const SizedBox(height: 16)
    ]);
  }

  void _clearErrorText() {
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      if (_errorText != null) ErrorMessage(message: _errorText!),
      if (mode == AuthMode.signUp)
        _authHeader(translate(context, TR_SIGN_UP))
      else
        _authHeader(translate(context, TR_SIGN_IN)),
      _userFields(),
      if (widget.isDev && widget.server == null) _devFields(),
      TextControllerListener(
          controllers: mode == AuthMode.codeLogin
              ? [_codeController]
              : [_emailController, _passwordController],
          builder: (_, valid) {
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: LoginButton(
                    TR_NEXT,
                    valid
                        ? () {
                            _clearErrorText();
                            final result = widget.onButton(mode);
                            if (mode == AuthMode.signUp && result) {
                              setState(() {
                                mode = AuthMode.signIn;
                              });
                            }
                          }
                        : null));
          }),
      if (mode != AuthMode.signUp)
        TextButton(
            child: mode == AuthMode.codeLogin
                ? Text(translate(context, TR_SIGN_IN_LOGIN))
                : Text(translate(context, TR_SIGN_IN_CODE)),
            onPressed: () {
              _clearErrorText();
              setState(() {
                mode = mode == AuthMode.codeLogin ? AuthMode.signIn : AuthMode.codeLogin;
              });
            })
      else
        const SizedBox.shrink(),
      const SizedBox(height: 10),
      if (widget.isDev) authConfigChanger(),
    ]);
  }

  Widget _devFields() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child:
                HostField(hostController: widget.hostController, isNeedFocus: widget.isNeedFocus)));
  }

  Widget _userFields() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          if (mode == AuthMode.codeLogin) ...{
            _textField(context, TR_CODE, _codeNode, _codeController, TextInputType.number, true),
          } else ...{
            if (mode == AuthMode.signUp)
              Row(
                children: <Widget>[
                  Expanded(
                      child: _textField(context, translate(context, TR_FIRST_NAME), _firstNameNode,
                          _firstNameController, TextInputType.text, true)),
                  Expanded(
                      child: _textField(context, translate(context, TR_LAST_NAME), _lastNameNode,
                          _lastNameController, TextInputType.text, true))
                ],
              )
            else
              const SizedBox.shrink(),
            _textField(
                context, TR_EMAIL, _emailNode, _emailController, TextInputType.emailAddress, true),
            _textField(context, TR_PASSWORD, _passwordNode, _passwordController,
                TextInputType.visiblePassword, false),
          }
        ]));
  }
}

class HostField extends StatefulWidget {
  final TextEditingController _hostController;
  final bool isNeedFocus;

  const HostField(
      {required TextEditingController hostController, required this.isNeedFocus, super.key})
      : _hostController = hostController;

  @override
  State<HostField> createState() {
    return _HostFieldState();
  }
}

class _HostFieldState extends State<HostField> {
  TextFieldNode? _serverNode;
  final GlobalKey _buttonKey = GlobalKey();

  bool _selectbleBrands = false;
  TextEditingController get _hostController => widget._hostController;

  OttServerInfoEx? _current;
  List<OttServerInfoEx>? _brands;
  late Future<void> _future;
  final _searchFocus = FocusNode();
  final _dropDownFocusNode = FocusNode();

  @override
  void initState() {
    if (widget.isNeedFocus) {
      _serverNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
    }
    _future = _init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      if (!_selectbleBrands) Expanded(child: _hostTextField()) else Expanded(child: _brandMenu()),
      _searchButton()
    ]);
  }

  Future<void> _init() {
    final Completer<void> c = Completer<void>();
    if (_brands == null) {
      final Future<List<OttServerInfoEx>> res = getCrocOTTLineBrands(Uri.parse(LINE_BRANDS));
      res.then((List<OttServerInfoEx> value) {
        if (value.isNotEmpty) {
          _brands = value;
          _current = value[0];
          c.complete();
        } else {
          throw Error();
        }
      }, onError: (error) {
        final pub = CrocOTTPublic(host: SERVER_HOST);
        final resp = pub.getServerInfo();
        resp.then((info) {
          final stab = OttServerInfoEx.info(host: SERVER_HOST, info: info, packages: []);
          _brands = [stab];
          _current = stab;
          c.complete();
        }, onError: (error) {
          _brands = [];
          _current = null;
          c.complete();
        });
      });
    } else {
      c.complete();
    }
    return c.future;
  }

  Widget _brandMenu() {
    return FutureBuilder<void>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasData || _brands != null) {
            final List<DropdownMenuItem<OttServerInfoEx>> items = [];
            for (final brand in _brands!) {
              final drop = DropdownMenuItem<OttServerInfoEx>(
                  value: brand,
                  child: Row(children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CircleAvatar(
                            maxRadius: 16,
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundImage: NetworkImage(brand.brand.logo))),
                    const SizedBox(width: 8),
                    Text(brand.brand.title)
                  ]));
              items.add(drop);
            }

            return _drawContet(items);
          }
          return Row(children: <Widget>[
            const Expanded(flex: 9, child: Center(child: CircularProgressIndicator())),
            Expanded(child: _searchButton())
          ]);
        });
  }

  Widget _drawContet(List<DropdownMenuItem<OttServerInfoEx>> items) {
    void _setBrand(OttServerInfoEx value) {
      setState(() {
        _hostController.text = value.host;
        _current = value;
      });
    }

    if (widget.isNeedFocus) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: <Widget>[
            Expanded(child: StatefulBuilder(builder: (context, setState) {
              return FocusBorder(
                focus: _dropDownFocusNode,
                child: Container(
                  decoration: BoxDecoration(
                      border: BoxBorder.lerp(
                          Border.all(color: Theme.of(context).primaryColor), Border.all(), 1)),
                  child: DropdownButton<OttServerInfoEx>(
                      focusNode: _dropDownFocusNode,
                      value: _current,
                      padding: const EdgeInsets.only(right: 16),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: items,
                      onChanged: (OttServerInfoEx? value) {
                        setState(() {
                          if (value != null) {
                            _setBrand(value);
                          }
                        });
                      }),
                ),
              );
            })),
          ]));
    }

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(children: <Widget>[
          Builder(builder: (context) {
            return Expanded(
                flex: 8,
                child: StatefulBuilder(builder: (context, setState) {
                  return Container(
                      decoration: BoxDecoration(
                          border: BoxBorder.lerp(
                              Border.all(color: Theme.of(context).primaryColor), Border.all(), 1)),
                      child: DropdownButton<OttServerInfoEx>(
                          value: _current,
                          padding: const EdgeInsets.only(right: 16),
                          autofocus: true,
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: items,
                          onChanged: (OttServerInfoEx? value) {
                            setState(() {
                              if (value != null) {
                                _setBrand(value);
                              }
                            });
                          }));
                }));
          })
        ]));
  }

  Row _hostTextField() {
    return Row(children: <Widget>[
      Expanded(
          flex: 8,
          child: _textField(context, SERVER, _serverNode, _hostController, TextInputType.url, true))
    ]);
  }

  Widget _searchButton() {
    if (kIsWeb) {
      return GestureDetector(
          key: _buttonKey,
          onTap: () {
            setState(() {
              _selectbleBrands = !_selectbleBrands;
            });
          },
          child: Card(
              elevation: 3,
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              child: Image.asset('install/assets/globus.png',
                  fit: BoxFit.cover, filterQuality: FilterQuality.high)));
    }

    if (widget.isNeedFocus) {
      return InkWell(
          focusNode: _searchFocus,
          onTap: () {
            setState(() {
              _selectbleBrands = !_selectbleBrands;
            });
          },
          child: const SizedBox(
              height: 50,
              width: 50,
              child: Card(
                  elevation: 3,
                  color: Colors.white,
                  clipBehavior: Clip.antiAlias,
                  child: Icon(Icons.search_outlined, color: Colors.black))));
    }

    return InkWell(
        onTap: () {
          setState(() {
            _selectbleBrands = !_selectbleBrands;
          });
        },
        child: Card(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            child: Image.asset('install/assets/globus.png',
                fit: BoxFit.cover, filterQuality: FilterQuality.high)));
  }
}
