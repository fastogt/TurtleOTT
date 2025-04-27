import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/base/animated_list_section.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/settings/about_section.dart';
import 'package:turtleott/pages/home/settings/tv_language_picker.dart';
import 'package:turtleott/pages/home/settings/tv_theming.dart';
import 'package:turtleott/pages/profile.dart';
import 'package:turtleott/utils/theme.dart';

class SettingsPage extends StatelessWidget {
  final Profile profile;

  const SettingsPage(this.profile);

  @override
  Widget build(BuildContext context) {
    return AnimatedListSection<String>(
        listWidth: 190,
        items: const [TR_ABOUT, TR_LANGUAGE, TR_THEME],
        itemBuilder: (String section) {
          return Text(tryTranslate(context, section));
        },
        contentBuilder: (category) {
          switch (category) {
            //case TR_PARENTAL_CONTROL:
            //  return const ParentalControlPage();
            case TR_ABOUT:
              return AboutPage(profile);
            case TR_LANGUAGE:
              return const LanguagePickerTV();
            case TR_THEME:
              return ThemePickerTV(Theming.of(context).themeId!);
            default:
              return const SizedBox();
          }
        });
  }
}
