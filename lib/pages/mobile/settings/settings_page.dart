import 'package:fastotv_dart/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/mobile/settings/age_picker.dart';
import 'package:turtleott/pages/mobile/settings/language_picker_mobile_web.dart';
import 'package:turtleott/pages/profile.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/mobile_color_picker.dart';
import 'package:turtleott/utils/mobile_theme_picker.dart';
import 'package:turtleott/utils/theme.dart';

class SettingsPage extends StatefulWidget {
  final Profile profile;

  const SettingsPage({super.key, required this.profile});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextStyle mainTextStyle = const TextStyle(fontSize: 16);
  bool isSoundAbsolute = true;
  bool isBrightnessAbsolute = true;
  bool saveLastViewed = true;
  int ageRating = IARC_DEFAULT_AGE;

  @override
  void initState() {
    super.initState();
    final settings = locator<LocalStorageService>();
    isSoundAbsolute = settings.soundChange();
    isBrightnessAbsolute = settings.brightnessChange();
    saveLastViewed = settings.saveLastViewed();
    ageRating = settings.ageRating();
  }

  Widget _soundChanging() {
    final color = Theming.of(context).onBrightness();
    return ListTile(
        leading: Icon(Icons.volume_up, color: color),
        title: Text(translate(context, TR_SOUND_CONTROL)),
        subtitle: Text(_controlTR(isSoundAbsolute)),
        onTap: () {
          setState(() {
            final settings = locator<LocalStorageService>();
            isSoundAbsolute = !isSoundAbsolute;
            settings.setSoundChange(isSoundAbsolute);
          });
        });
  }

  Widget _brightnessChanging() {
    final color = Theming.of(context).onBrightness();
    return ListTile(
        leading: Icon(Icons.brightness_1, color: color),
        title: Text(translate(context, TR_BRIGHTNESS_CONTROL)),
        subtitle: Text(_controlTR(isBrightnessAbsolute)),
        onTap: () {
          setState(() {
            final LocalStorageService settings = locator<LocalStorageService>();
            isBrightnessAbsolute = !isBrightnessAbsolute;
            settings.setBrightnessChange(isBrightnessAbsolute);
          });
        });
  }

  String _controlTR(bool isAbs) {
    if (isAbs) {
      return translate(context, TR_ABSOLUTE);
    }
    return translate(context, TR_RELATIVE);
  }

  Widget _lastViewed() {
    final Color color = Theming.of(context).onBrightness();
    return ListTile(
        leading: Icon(saveLastViewed ? Icons.bookmark : Icons.bookmark_border, color: color),
        title: Text(translate(context, TR_LAST_VIEWED),
            style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        subtitle: Text(
          translate(context, TR_LAST_VIEWED_SUB),
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        onTap: () {
          setState(() {
            saveLastViewed = !saveLastViewed;
            final LocalStorageService settings = locator<LocalStorageService>();
            settings.setSaveLastViewed(saveLastViewed);
          });
        },
        trailing: Switch.adaptive(
            activeColor: Theme.of(context).colorScheme.secondary,
            value: saveLastViewed,
            onChanged: (bool value) {
              setState(() {
                saveLastViewed = value;
                final LocalStorageService settings = locator<LocalStorageService>();
                settings.setSaveLastViewed(value);
                if (saveLastViewed == false) {
                  settings.setLastPackage(null);
                  settings.setLastChannel(null);
                }
              });
            }));
  }

  Widget _age() {
    return FutureBuilder(
      future: widget.profile.profileWithToken(),
      builder: (ctx, snap) {
        if (snap.hasError || snap.data == null) {
          return const SizedBox.shrink();
        }
        final subs = snap.data as SubProfile;
        return ListTile(
          leading: Icon(Icons.child_care, color: Theming.of(context).onBrightness()),
          title: Text(
            translate(context, TR_PARENTAL_CONTROL),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          subtitle: Text(
            translate(context, TR_AGE_RESTRICTION),
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () async {
            final LocalStorageService settings = locator<LocalStorageService>();
            await showDialog(
                context: context,
                builder: (BuildContext context) => AgeSelector(subs.password)).then((value) {
              if (value != null) {
                setState(() {
                  ageRating = value;
                });
                settings.setAgeRating(ageRating);
              }
            });
          },
          trailing: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '$ageRating',
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Divider divider = Divider(height: 0.0);
    final Color color = Theme.of(context).colorScheme.onPrimary;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            iconTheme: IconThemeData(color: color),
            title: Text(translate(context, TR_SETTINGS), style: TextStyle(color: color))),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          ListHeader(text: translate(context, TR_ABOUT)),
          _lastViewed(),
          _soundChanging(),
          _brightnessChanging(),
          divider,
          ListHeader(text: translate(context, TR_CONTENT_SETTINGS)),
          _age(),
          divider,
          ListHeader(text: translate(context, TR_THEME)),
          const ThemePicker(),
          const ColorPicker.primary(),
          const ColorPicker.accent(),
          divider,
          ListHeader(text: translate(context, TR_LANGUAGE)),
          LanguagePickerMobileWeb.settings((Locale locale) {
            final LocalStorageService settings = locator<LocalStorageService>();
            settings.setLangCode(locale.languageCode);
            settings.setCountryCode(locale.countryCode);
          })
        ])));
  }
}
