import 'package:fastotv_dart/commands_info/package_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/vod_stream.dart';
import 'package:turtleott/base/mobile_custom_search.dart';
import 'package:turtleott/pages/home/types.dart';
import 'package:turtleott/pages/home/vods/mobile_constants.dart';
import 'package:turtleott/pages/home/vods/mobile_vod_card.dart';
import 'package:turtleott/pages/home/vods/mobile_vod_card_views.dart';
import 'package:turtleott/pages/mobile/settings/age_picker.dart';
import 'package:turtleott/pages/mobile/vods/vod_description_page.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/theme.dart';

class VodStreamSearch extends CustomSearchDelegate<VodStream> {
  final OnPackageBuyPressed onPackageBuyPressed;
  final ContentBloc bloc;

  VodStreamSearch(List<VodStream> streams, String hint, OttPackageInfo package, this.bloc,
      this.onPackageBuyPressed)
      : super(streams, hint, package);

  @override
  Widget list(List<VodStream> results, BuildContext context, OttPackageInfo package) {
    const double aspect = 2 / 3;
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width - 2 * EDGE_INSETS * 3;
    final maxHeight = maxWidth / aspect;
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
                  final vod = results[index];
                  final indexInPackage = package.vods.indexWhere((el) => el.id == vod.id());
                  final settings = locator<LocalStorageService>();
                  final age = settings.ageRating();
                  bool isAgeAllowed() {
                    return age >= vod.iarc();
                  }

                  final theme = Theming.of(context);
                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EDGE_INSETS, vertical: EDGE_INSETS * 1.5),
                      child: Center(
                          child: Stack(children: [
                        VodCard(
                            iconLink: vod.icon(),
                            height: maxHeight,
                            width: maxWidth,
                            onPressed: () async {
                              if (isAgeAllowed()) {
                                final Route route = MaterialPageRoute(builder: (context) {
                                  return VodDescription(
                                    package: package,
                                    vod: package.vods[indexInPackage],
                                    bloc: bloc,
                                    onPackageBuyPressed: onPackageBuyPressed,
                                  );
                                });
                                Navigator.push(context, route);
                              } else
                                showDialog(
                                        context: context,
                                        builder: (BuildContext context) => const CheckPassword())
                                    .then((value) {
                                  if (value == true) {
                                    final Route route = MaterialPageRoute(builder: (context) {
                                      return VodDescription(
                                        package: package,
                                        vod: package.vods[indexInPackage],
                                        bloc: bloc,
                                        onPackageBuyPressed: onPackageBuyPressed,
                                      );
                                    });
                                    Navigator.push(context, route);
                                  }
                                });
                            }),
                        VodCardBadge(
                            left: 5,
                            bottom: 5,
                            child:
                                age >= vod.iarc() ? const VodCardViews(0) : VodAgeView(vod.iarc())),
                        VodCardBadge(
                          right: 5,
                          top: 5,
                          width: 36.0,
                          child: isAgeAllowed()
                              ? FavoriteStarButton(
                                  vod.favorite(),
                                  unselectedColor: theme.onPrimary(),
                                )
                              : const Icon(Icons.lock),
                        )
                      ])));
                })));
  }
}
