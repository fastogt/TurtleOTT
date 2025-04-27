import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/utils/theme.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker.primary() : color = 0;

  const ColorPicker.accent() : color = 1;

  final int color;

  @override
  _ColorPickerState createState() {
    return _ColorPickerState();
  }
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  Widget build(BuildContext context) {
    if (widget.color == 0) {
      return _primary();
    } else if (widget.color == 1) {
      return _accent();
    }
    return const SizedBox();
  }

  Widget _primary() {
    final String hexColor = Theme.of(context).primaryColor.value.toRadixString(16);
    return ListTile(
        leading: Icon(Icons.format_color_fill, color: Theming.of(context).onBrightness()),
        title: Text(translate(context, TR_PRIMARY_COLOR)),
        subtitle: Text('Color(0x$hexColor)'),
        onTap: () {
          final id = Theming.of(context).themeId;
          if (id == CUSTOM_LIGHT_THEME_ID || id == CUSTOM_DARK_THEME_ID) {
            final future = _openColorPicker();
            future.then((value) {
              if (value != null) {
                Theming.of(context).setPrimaryColor(value);
              }
            });
          }
        },
        trailing: _colorCircle(Theme.of(context).primaryColor));
  }

  Widget _accent() {
    return ListTile(
        leading: Icon(Icons.colorize, color: Theming.of(context).onBrightness()),
        title: Text(translate(context, TR_ACCENT_COLOR)),
        subtitle: Text(Theme.of(context).colorScheme.secondary.toString()),
        onTap: () {
          final id = Theming.of(context).themeId;
          if (id == CUSTOM_LIGHT_THEME_ID || id == CUSTOM_DARK_THEME_ID) {
            final future = _openColorPicker();
            future.then((value) {
              if (value != null) {
                Theming.of(context).setAccentColor(value);
              }
            });
          }
        },
        trailing: _colorCircle(Theme.of(context).colorScheme.secondary));
  }

  Widget _colorCircle(Color color) {
    return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Theming.of(context).onPrimary())));
  }

  Future<Color?> _openColorPicker() async {
    return showDialog(
        context: context,
        builder: (_) => ColorPickerDialog(
            title: translate(context, widget.color == 0 ? TR_PRIMARY_COLOR : TR_ACCENT_COLOR),
            initColor: widget.color == 0
                ? Theme.of(context).primaryColor
                : Theme.of(context).colorScheme.secondary,
            cancel: translate(context, TR_CANCEL),
            submit: translate(context, TR_SUBMIT)));
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
