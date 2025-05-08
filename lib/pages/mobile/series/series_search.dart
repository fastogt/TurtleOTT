import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/series_stream.dart';
import 'package:turtleott/base/mobile_custom_search.dart';
import 'package:turtleott/pages/home/types.dart';
import 'package:turtleott/pages/home/vods/mobile_constants.dart';
import 'package:turtleott/pages/home/vods/mobile_vod_card.dart';
import 'package:turtleott/pages/home/vods/mobile_vod_card_views.dart';
import 'package:turtleott/pages/mobile/series/serial_description.dart';
import 'package:turtleott/pages/mobile/settings/age_picker.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';

class SeriesStreamSearch extends CustomSearchDelegate<SerialStream> {
  final OnPackageBuyPressed onPackageBuyPressed;
  final ContentBloc bloc;

  SeriesStreamSearch(List<SerialStream> results, String hint, OttPackageInfo package,
      this.onPackageBuyPressed, this.bloc)
      : super(results, hint, package);

  @override
  Widget list(List<SerialStream> results, BuildContext context, OttPackageInfo package) {
    const double aspect = 2 / 3;
    final Size size = MediaQuery.of(context).size;
    final double maxWidth = size.width - 2 * EDGE_INSETS * 3;
    final double maxHeight = maxWidth / aspect;
    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: CARD_WIDTH + 2 * EDGE_INSETS,
                    crossAxisSpacing: EDGE_INSETS,
                    mainAxisSpacing: EDGE_INSETS,
                    childAspectRatio: 2 / 3),
                itemCount: results.length,
                itemBuilder: (BuildContext context, int index) {
                  final SerialStream channel = results[index];
                  final LocalStorageService settings = locator<LocalStorageService>();
                  final int age = settings.ageRating();
                  bool isAgeAllowed() {
                    return age >= channel.serial.iarc;
                  }

                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EDGE_INSETS, vertical: EDGE_INSETS * 1.5),
                      child: Center(
                          child: Stack(children: <Widget>[
                        VodCard(
                            iconLink: channel.icon(),
                            height: maxHeight,
                            width: maxWidth,
                            onPressed: () async {
                              if (isAgeAllowed()) {
                                final Route route =
                                    MaterialPageRoute(builder: (BuildContext context) {
                                  return MobileSerialDescription(
                                      package: package,
                                      serial: channel.serial,
                                      onPackageBuyPressed: onPackageBuyPressed,
                                      bloc: bloc);
                                });
                                Navigator.push(context, route);
                              } else {
                                showDialog(
                                        context: context,
                                        builder: (BuildContext context) => const CheckPassword())
                                    .then((value) {
                                  if (value == true) {
                                    final Route route =
                                        MaterialPageRoute(builder: (BuildContext context) {
                                      return MobileSerialDescription(
                                          package: package,
                                          serial: channel.serial,
                                          onPackageBuyPressed: onPackageBuyPressed,
                                          bloc: bloc);
                                    });
                                    Navigator.push(context, route);
                                  }
                                });
                              }
                            }),
                        VodCardBadge(
                            left: 5,
                            bottom: 5,
                            child: isAgeAllowed()
                                ? _getViewCount(package, channel.serial)
                                : VodAgeView(channel.serial.iarc)),
                        VodCardBadge(
                            right: 5,
                            top: 5,
                            width: 36.0,
                            child: isAgeAllowed()
                                ? const Icon(Icons.star_border)
                                : const Icon(Icons.lock))
                      ])));
                })));
  }

  Widget _getViewCount(OttPackageInfo pack, SerialInfo serial) {
    return const VodCardViews(0);
  }
}
