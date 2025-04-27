import 'package:crocott_dart/errors.dart';
import 'package:fastotv_dart/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/base/animated_list_section.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/profile.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';

class AboutPage extends StatelessWidget {
  final Profile profile;

  const AboutPage(this.profile);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SubProfile>(
        future: profile.profileWithToken(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            if (snapshot.error is NeedHelpError) {
              return AlertDialog(
                  title: const Text('Token expired'),
                  content: const Text('Need to relogin'),
                  actions: [TextButtonEx(onPressed: Navigator.of(context).pop, text: 'OK')]);
            }
          }

          if (snapshot.hasData) {
            final subs = snapshot.data as SubProfile;
            return AnimatedListSection<String>(
                items: const [TR_LOGIN_ABOUT, TR_EXPIRATION_DATE, TR_DEVICE_ID],
                itemBuilder: (String section) => Text(translate(context, section)),
                contentBuilder: (category) {
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                        padding: const EdgeInsets.all(16).add(const EdgeInsets.only(top: 200)),
                        child: Text(info(context, category, subs),
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18)))
                  ]);
                });
          }
          return const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(), SizedBox(height: 16)]));
        });
  }

  String info(BuildContext context, String section, SubProfile sub) {
    switch (section) {
      case TR_LOGIN_ABOUT:
        return sub.email;
      case TR_EXPIRATION_DATE:
        {
          final DateTime dt = sub.expiredDate();
          return dt.toString();
        }
      case TR_DEVICE_ID:
        final settings = locator<LocalStorageService>();
        final deviceID = settings.device()!;
        return deviceID;
      default:
        return '';
    }
  }
}
