import 'package:flutter/material.dart';
import 'package:flutter_common/src/utils/translate.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/debug_page.dart';
import 'package:turtleott/pages/home/settings/tv_language_picker.dart';
import 'package:turtleott/pages/login/app_root_bloc.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({
    super.key,
    required AppBloc bloc,
  }) : _bloc = bloc;

  final AppBloc _bloc;

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: TextButton(
                onPressed: () => _bloc.launchTerms(_bloc.host),
                child: Text(translate(context, TR_TERMS_AND_CONDITIONS))),
          ),
          Column(children: <Widget>[
            LanguagePickerMobileWeb((locale) {
              final settings = locator<LocalStorageService>();
              settings.setLangCode(locale.languageCode);
              settings.setCountryCode(locale.countryCode);
            }),
            const VersionTile.login()
          ]),
          Expanded(
              child: TextButton(
                  onPressed: () => _bloc.launchPolicy(_bloc.host),
                  child: Text(translate(context, TR_PRIVACY_POLICY))))
        ]);
  }
}
