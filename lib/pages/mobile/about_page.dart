import 'package:fastotv_dart/profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/debug_page.dart';
import 'package:turtleott/pages/profile.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/theme.dart';

class AboutPage extends StatelessWidget {
  final Profile profile;

  const AboutPage(this.profile);

  @override
  Widget build(BuildContext context) {
    return _AboutView(profile);
  }
}

class _AboutView extends StatelessWidget {
  final Profile profile;

  const _AboutView(this.profile);

  bool get hasTouch => locator<RuntimeDevice>().hasTouch;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SubProfile>(
        future: profile.profileWithToken(),
        builder: (BuildContext context, AsyncSnapshot<SubProfile> snapshot) {
          if (snapshot.hasError) {
            //   if (snapshot.error is NeedHelpError) {
            return AlertDialog(
                title: const Text('Token expired'),
                content: const Text('Need to relogin'),
                actions: <Widget>[TextButtonEx(onPressed: Navigator.of(context).pop, text: 'OK')]);
            // }
          }

          if (snapshot.hasData) {
            final SubProfile subs = snapshot.data as SubProfile;

            if (kIsWeb) {
              return Scaffold(
                  appBar: AppBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      iconTheme: IconThemeData(color: Theming.of(context).onPrimary()),
                      title: Text(translate(context, TR_ABOUT),
                          style: TextStyle(color: Theming.of(context).onPrimary()))),
                  body: Column(children: <Widget>[
                    ListHeader(text: translate(context, TR_ACCOUNT)),
                    ..._tiles(subs, context),
                    const Divider(height: 0.0),
                    ListHeader(text: translate(context, TR_APP)),
                    const VersionTile.settings()
                  ]));
            }

            if (hasTouch) {
              return Scaffold(
                  appBar: AppBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      iconTheme: IconThemeData(color: Theming.of(context).onPrimary()),
                      title: Text(
                          translate(
                            context,
                            TR_ABOUT,
                          ),
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary))),
                  body: Column(children: <Widget>[
                    ListHeader(text: translate(context, TR_ACCOUNT)),
                    ..._tiles(subs, context),
                    const Divider(height: 0.0),
                    ListHeader(text: translate(context, TR_APP)),
                    const VersionTile.settings()
                  ]));
            }
            return Column(
                children: <Widget>[..._tiles(subs, context), const VersionTile.settings()]);
          }
          return const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[CircularProgressIndicator(), SizedBox(height: 16)]));
        });
  }

  List<Widget> _tiles(SubProfile sub, BuildContext context) {
    return <Widget>[
      _loginTile(sub.email, context),
      _expDateTile(DateTime.fromMicrosecondsSinceEpoch(sub.expDate * 1000)),
      _deviceIDTile(context)
    ];
  }

  Widget _loginTile(String login, BuildContext context) {
    return _AboutTile(
        icon: Icons.account_box,
        title: TR_LOGIN_ABOUT,
        subtitle: login,
        onTap: () {
          copyInfoSnackbar(context, login, translate(context, TR_LOGIN_ABOUT));
        });
  }

  Widget _expDateTile(DateTime expDate) {
    return _AboutTile(
        icon: Icons.date_range, title: TR_EXPIRATION_DATE, subtitle: expDate.toString());
  }

  Widget _deviceIDTile(BuildContext context) {
    final LocalStorageService settings = locator<LocalStorageService>();
    final String deviceID = settings.device()!;
    return _AboutTile(
        icon: Icons.perm_device_information,
        title: TR_DEVICE_ID,
        subtitle: deviceID,
        onTap: () {
          copyInfoSnackbar(context, deviceID, 'ID');
        });
  }

  void copyInfoSnackbar(BuildContext context, String toCopy, String whatCopied) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    Clipboard.setData(ClipboardData(text: toCopy));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$whatCopied ${translate(context, TR_COPIED)}')))
        .closed;
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final void Function()? onTap;

  const _AboutTile({required this.icon, required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(icon, color: Theming.of(context).onBrightness()),
        title: Text(
          translate(context, title),
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        onTap: onTap);
  }
}
