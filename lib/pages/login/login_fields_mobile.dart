import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/base/login/textfields_mobile.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/login/login_button.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';

class TextFieldNode {
  final FocusNode main;
  final FocusNode text;

  TextFieldNode({required this.main, required this.text});
}

class LoginFieldsMobile extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController codeController;
  final TextEditingController hostController;
  final VoidCallback onButton;
  final bool isCode;
  final ValueChanged<bool> isLoginCode;
  final bool isDev;

  const LoginFieldsMobile(this.emailController, this.passwordController, this.codeController,
      this.hostController, this.onButton, this.isCode, this.isDev, this.isLoginCode,
      {Key? key})
      : super(key: key);

  @override
  LoginFieldsMobileState createState() {
    return LoginFieldsMobileState();
  }
}

class LoginFieldsMobileState extends State<LoginFieldsMobile> {
  TextFieldNode? _emailNode;
  TextFieldNode? _passwordNode;
  TextFieldNode? _codeNode;
  TextFieldNode? _serverNode;

  TextEditingController get _emailController => widget.emailController;

  TextEditingController get _passwordController => widget.passwordController;

  TextEditingController get _codeController => widget.codeController;

  TextEditingController get _hostController => widget.hostController;

  late bool _isCodeLogin;

  @override
  void initState() {
    super.initState();
    _isCodeLogin = widget.isCode;
    final device = locator<RuntimeDevice>();
    if (!device.hasTouch) {
      _emailNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
      _passwordNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
      _codeNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
      _serverNode = TextFieldNode(main: FocusNode(), text: FocusNode(skipTraversal: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = locator<LocalStorageService>();
    final server = settings.server();
    return Column(children: [
      _userFields(),
      if (widget.isDev && server == null) _devFields(),
      TextControllerListener(
          controllers: _isCodeLogin ? [_codeController] : [_emailController, _passwordController],
          builder: (_, valid) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: LoginButton(TR_NEXT, widget.onButton),
            );
          }),
      TextButton(
          child: _isCodeLogin
              ? Text(translate(context, TR_SIGN_IN_LOGIN))
              : Text(translate(context, TR_SIGN_IN_CODE)),
          onPressed: () {
            widget.isLoginCode(!_isCodeLogin);
            setState(() {
              _isCodeLogin = !_isCodeLogin;
            });
          }),
    ]);
  }

  Widget _devFields() {
    return Padding(
        padding: const EdgeInsets.symmetric(),
        child: _textField(SERVER, _serverNode, _hostController, TextInputType.emailAddress));
  }

  Widget _userFields() {
    return Padding(
        padding: const EdgeInsets.symmetric(),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (_isCodeLogin) ...{
            _textField(TR_CODE, _codeNode, _codeController, TextInputType.number),
          } else ...{
            _textField(TR_EMAIL, _emailNode, _emailController, TextInputType.emailAddress),
            _textField(
                TR_PASSWORD, _passwordNode, _passwordController, TextInputType.visiblePassword),
          }
        ]));
  }

  Widget _textField(String hintText, TextFieldNode? node, TextEditingController controller,
      TextInputType textInputType) {
    return LoginTextFieldMobile(
      // mainFocus: node?.main,
      // autoFocus: hintText == TR_EMAIL,
      controller: controller,
      hintText: tryTranslate(context, hintText),
      obscureText: hintText == TR_PASSWORD,
      key: ValueKey(controller),
      keyboardType: textInputType,
    );
  }
}
