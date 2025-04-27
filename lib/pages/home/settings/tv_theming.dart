import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/base/border.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/theme.dart';

class ThemePickerTV extends StatefulWidget {
  final String? initTheme;

  const ThemePickerTV(this.initTheme);

  @override
  _ThemePickerTVState createState() {
    return _ThemePickerTVState();
  }
}

class _ThemePickerTVState extends State<ThemePickerTV> {
  static const THEME_TITLES = [TR_LIGHT, TR_DARK, TR_BLACK];
  static const THEME_IDS = [LIGHT_THEME_ID, DARK_THEME_ID, BLACK_THEME_ID];

  String themeGroupValue = LIGHT_THEME_ID;
  final _buttonFocus =
      List<FocusNode>.generate(THEME_TITLES.length, (index) => FocusNode(), growable: false);

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    themeGroupValue = widget.initTheme ?? settings.themeID() ?? LIGHT_THEME_ID;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          THEME_IDS.length,
          (index) => _dialogItem(THEME_TITLES[index], THEME_IDS[index], _buttonFocus[index]),
        ),
      ),
    );
  }

  Widget _dialogItem(String text, String themeId, FocusNode _node) {
    return Focus(
        canRequestFocus: false,
        focusNode: _node,
        child: FocusBorder(
            focus: _node,
            child: RadioListTile<String>(
                activeColor: Theme.of(context).colorScheme.secondary,
                title: Text(translate(context, text), style: const TextStyle(fontSize: 20)),
                value: themeId,
                groupValue: themeGroupValue,
                onChanged: _update)));
  }

  void _update(String? themeId) {
    setState(() {
      final newThemeId = themeId ?? themeGroupValue;
      themeGroupValue = newThemeId;
      Theming.of(context).setTheme(newThemeId);
    });
  }

  @override
  void dispose() {
    for (var action in _buttonFocus) {
      action.dispose();
    }
    super.dispose();
  }
}
