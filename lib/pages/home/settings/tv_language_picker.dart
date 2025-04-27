import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/base/border.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';

class LanguagePickerTV extends StatefulWidget {
  const LanguagePickerTV();

  @override
  _LanguagePickerTVState createState() {
    return _LanguagePickerTVState();
  }
}

class _LanguagePickerTVState extends State<LanguagePickerTV> {
  int _currentSelection = 0;

  List<String>? get supportedLanguages {
    final app = AppLocalizations.of(context);
    if (app == null) {
      return null;
    }

    return app.supportedLanguages;
  }

  List<Locale>? get supportedLocales {
    final app = AppLocalizations.of(context);
    if (app == null) {
      return null;
    }

    return app.supportedLocales;
  }

  final _buttonFocus = List<FocusNode>.generate(6, (index) => FocusNode(), growable: false);

  @override
  Widget build(BuildContext context) {
    _currentSelection = currentLanguageIndex();
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(supportedLanguages!.length,
            (int index) => _dialogItem(supportedLanguages![index], index, _buttonFocus[index])));
  }

  Widget _dialogItem(String text, int itemValue, FocusNode _node) {
    return Focus(
        onKey: (node, event) => _onKey(node, event, itemValue),
        focusNode: _node,
        child: FocusBorder(
            focus: _node,
            child: RadioListTile(
                activeColor: Theme.of(context).colorScheme.secondary,
                title: Text(text, style: const TextStyle(fontSize: 20)),
                value: itemValue,
                groupValue: _currentSelection,
                onChanged: _changeLanguage)));
  }

  void _changeLanguage(int? value) async {
    if (value == null) {
      return;
    }

    _currentSelection = value;
    final selectedLocale = supportedLocales![value];
    AppLocalizations.of(context)!.load(selectedLocale);
    final settings = locator<LocalStorageService>();
    settings.setLangCode(selectedLocale.languageCode);
    settings.setCountryCode(selectedLocale.countryCode);
    setState(() {});
  }

  int currentLanguageIndex() {
    return supportedLocales?.indexOf(AppLocalizations.of(context)!.currentLocale) ?? 0;
  }

  KeyEventResult _onKey(FocusNode node, RawKeyEvent event, int? value) {
    return onKey(event, (keyCode) {
      switch (keyCode) {
        case KeyConstants.KEY_LEFT:
          FocusScope.of(context).focusInDirection(TraversalDirection.left);
          return KeyEventResult.handled;
        case KeyConstants.KEY_RIGHT:
          return KeyEventResult.handled;
        case KeyConstants.KEY_DOWN:
          FocusScope.of(context).focusInDirection(TraversalDirection.down);
          return KeyEventResult.handled;
        case KeyConstants.KEY_UP:
          FocusScope.of(context).focusInDirection(TraversalDirection.up);
          return KeyEventResult.handled;
        case KeyConstants.KEY_CENTER:
          _changeLanguage(value);
          return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    });
  }
}

class LanguagePickerMobileWeb extends StatefulWidget {
  final Function(Locale locale)? onChanged;
  final String? chooseLangKey;
  final String? languageKey;
  final String? languageNameKey;

  const LanguagePickerMobileWeb(this.onChanged,
      {this.languageKey, this.languageNameKey, this.chooseLangKey});

  @override
  _LanguagePickerMobileWebState createState() {
    return _LanguagePickerMobileWebState();
  }
}

class _LanguagePickerMobileWebState extends State<LanguagePickerMobileWeb> {
  final FocusScopeNode _dialogScope = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.language),
        TextButton(
          child: Text(_languageName!),
          onPressed: _showAlertDialog,
        ),
      ],
    );
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
