import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/localization/translations.dart';

enum DialogType { SETTINGS, LOGIN }

class LanguagePickerMobileWeb extends StatefulWidget {
  final Function(Locale locale)? onChanged;
  final String? chooseLangKey;
  final String? languageKey;
  final String? languageNameKey;
  final DialogType _type;

  const LanguagePickerMobileWeb.settings(this.onChanged,
      {this.languageKey, this.languageNameKey, this.chooseLangKey})
      : _type = DialogType.SETTINGS;

  const LanguagePickerMobileWeb.login(this.onChanged,
      {this.languageKey, this.languageNameKey, this.chooseLangKey})
      : _type = DialogType.LOGIN;

  @override
  _LanguagePickerMobileWebState createState() {
    return _LanguagePickerMobileWebState();
  }
}

class _LanguagePickerMobileWebState extends State<LanguagePickerMobileWeb> {
  final FocusScopeNode _dialogScope = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    if (widget._type == DialogType.SETTINGS) {
      return _settings();
    } else if (widget._type == DialogType.LOGIN) {
      return _login();
    }
    return const SizedBox();
  }

  void _showAlertDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return FocusScope(
              node: _dialogScope,
              child: SimpleDialog(
                  contentPadding: const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 0.0),
                  title: Text(_chooseLanguage!),
                  children: <Widget>[
                    SingleChildScrollView(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List<Widget>.generate(supportedLocales.length, _dialogItem)))
                  ]));
        });
  }

  Widget _dialogItem(int index) {
    final String text = supportedLanguages[index];
    final Locale locale = supportedLocales[index];
    return ListTile(
        autofocus: index == 0,
        leading: _radio(index),
        onTap: () {
          _setLocale(locale);
        },
        title: Text(text, overflow: TextOverflow.ellipsis));
  }

  Widget _radio(int index) {
    final Color _color = Theme.of(context).colorScheme.secondary;
    if (index == currentLanguageIndex()) {
      return Icon(Icons.radio_button_checked, color: _color);
    }
    return const Icon(Icons.radio_button_unchecked);
  }

  Widget _settings() {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(_languageName!),
      onTap: _showAlertDialog,
    );
  }

  Widget _login() {
    return Opacity(
        opacity: 0.5,
        child: TextButton.icon(
            onPressed: _showAlertDialog,
            icon: const Icon(Icons.language),
            label: Text(_languageName!)));
  }

  void _setLocale(Locale locale) {
    AppLocalizations.of(context)!.load(locale);
    widget.onChanged?.call(locale);
    Navigator.of(context).pop();
  }

  List<Locale> get supportedLocales {
    return AppLocalizations.of(context)!.supportedLocales;
  }

  List<String> get supportedLanguages {
    return AppLocalizations.of(context)!.supportedLanguages;
  }

  int currentLanguageIndex() {
    final index = supportedLocales.indexOf(AppLocalizations.of(context)!.currentLocale);
    if (index < 0) {
      return 0;
    } else {
      return index;
    }
  }

  String? get _languageName {
    if (widget.languageNameKey == null) {
      return AppLocalizations.of(context)!.currentLanguage;
    }
    return AppLocalizations.of(context)!.translate(widget.languageNameKey!);
  }

  String? get _chooseLanguage {
    if (widget.chooseLangKey == null) {
      return translate(context, TR_LANGUAGE_CHOOSE);
    }
    return AppLocalizations.of(context)!.translate(widget.chooseLangKey!);
  }
}
