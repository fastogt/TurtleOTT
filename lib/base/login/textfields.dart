import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/base/scale.dart';
import 'package:turtleott/utils/theme.dart';

const double TEXTFIELD_PADDING = 4;
const double TOTAL_TEXTFIELD_HEIGHT = 64;
const double ERROR_TEXT_HEIGHT = 24;

const String EMAIL = 'Email';
const String PASSWORD = 'Password';
const String SERVER = 'Server';
const String PORT = 'Port';

class LoginTextField extends StatefulWidget {
  final void Function(String term)? onFieldChanged;
  final void Function(String term)? onFieldSubmit;
  final String? init;
  final String? hintText;
  final String? Function(String? term)? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool canBeEmpty;
  final bool obscureText;
  final String? errorText;
  final FocusNode? mainFocus;
  final FocusOnKeyCallback? onKey;
  final bool autoFocus;
  final EdgeInsets padding;

  const LoginTextField(
      {this.onKey,
      this.init,
      this.onFieldSubmit,
      this.onFieldChanged,
      this.mainFocus,
      this.hintText,
      this.validator,
      this.controller,
      this.keyboardType,
      this.obscureText = false,
      this.errorText,
      this.autoFocus = false,
      this.canBeEmpty = false,
      this.padding = const EdgeInsets.all(TEXTFIELD_PADDING),
      Key? key})
      : super(key: key);

  @override
  _LoginTextFieldState createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  bool _validator = true;

  TextEditingController? _controller;

  late FocusNode _main;
  FocusNode? _text = FocusNode(skipTraversal: true);

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.init ?? '');
    _main = widget.mainFocus ?? FocusNode();
    _main.addListener(update);
  }

  @override
  void didUpdateWidget(LoginTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.init != oldWidget.init) {
      _controller = widget.controller ?? TextEditingController(text: widget.init ?? '');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _text?.dispose();
    _main.removeListener(update);
    if (widget.mainFocus == null) {
      _main.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        autofocus: widget.autoFocus,
        focusNode: _main,
        debugLabel: widget.hintText,
        onKey: (node, event) {
          return onKeyArrows(context, event, onEnter: () {
            FocusScope.of(context).requestFocus(_text);
          });
        },
        child: Padding(
            padding: widget.padding,
            child: AutoScaleWidget(
                node: _main,
                builder: (hasFocus) {
                  return TextFormField(
                      validator: _validate,
                      controller: _controller,
                      keyboardType: widget.keyboardType,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      focusNode: _text,
                      obscureText: widget.obscureText,
                      onChanged: _onField,
                      cursorColor: Theming.of(context).theme.colorScheme.secondary,
                      onFieldSubmitted: (term) {
                        widget.onFieldSubmit?.call(term);
                        FocusScope.of(context).requestFocus(_main);
                        _text = null;
                        _text = FocusNode(skipTraversal: true);
                      },
                      decoration: InputDecoration(
                          hintText: widget.hintText,
                          enabledBorder: _border(),
                          focusedBorder: _border(),
                          errorBorder: _errorBorder(),
                          errorStyle: const TextStyle(height: 0),
                          contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0)));
                })));
  }

  void _onField(String term) {
    if (term.isNotEmpty != _validator) {
      setState(() => _validator = term.isNotEmpty);
    }

    widget.onFieldChanged?.call(term);
  }

  String? _validate(String? term) {
    if (widget.canBeEmpty) {
      return null;
    }

    if (widget.validator != null) {
      final _message = widget.validator!(term);
      if (_message != null) {
        return _message;
      }
    }

    if (term!.isEmpty) {
      if (widget.errorText?.isNotEmpty ?? false) {
        return widget.errorText;
      } else {
        return "${widget.hintText} can't be empty.";
      }
    }

    return null;
  }

  OutlineInputBorder _border() {
    if (widget.mainFocus?.hasPrimaryFocus ?? false) {
      return OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 4));
    }
    return OutlineInputBorder(borderSide: BorderSide(color: Theming.of(context).onBrightness()));
  }

  OutlineInputBorder _errorBorder() {
    OutlineInputBorder border = const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
    if (_main.hasPrimaryFocus) {
      border = border.copyWith(borderSide: border.borderSide.copyWith(width: 4));
    }
    return border;
  }

  void onEnter(FocusNode node) {
    FocusScope.of(context).requestFocus(_text);
  }

  void update() {
    setState(() {});
  }
}

class TextControllerListener extends StatefulWidget {
  final List<TextEditingController> controllers;
  final bool Function(String text)? validator;
  final Widget Function(BuildContext context, bool valid) builder;

  const TextControllerListener({required this.controllers, required this.builder, this.validator});

  @override
  _TextControllerListenerState createState() => _TextControllerListenerState();
}

class _TextControllerListenerState extends State<TextControllerListener> {
  bool _valid = false;

  @override
  void initState() {
    super.initState();
    _valid = _validate();
    for (final controller in widget.controllers) {
      controller.addListener(_update);
    }
  }

  @override
  void didUpdateWidget(covariant TextControllerListener oldWidget) {
    for (final controller in oldWidget.controllers) {
      controller.removeListener(_update);
    }
    _valid = _validate();
    for (final controller in widget.controllers) {
      controller.addListener(_update);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    for (final controller in widget.controllers) {
      controller.removeListener(_update);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _valid);
  }

  bool _validate() {
    for (final TextEditingController controller in widget.controllers) {
      if (widget.validator != null) {
        if (!widget.validator!(controller.text)) {
          return false;
        }
      } else if (controller.text.isEmpty) {
        return false;
      }
    }

    return true;
  }

  void _update() {
    final bool validation = _validate();
    if (_valid != validation) {
      setState(() {
        _valid = validation;
      });
    }
  }
}
