import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/vod_stream.dart';
import 'package:turtleott/base/mobile_no_avaiable.dart';
import 'package:turtleott/base/mobile_tabbar.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/types.dart';
import 'package:turtleott/pages/home/vods/mobile_constants.dart';
import 'package:turtleott/pages/home/vods/mobile_vod_card.dart';
import 'package:turtleott/pages/home/vods/mobile_vod_card_views.dart';
import 'package:turtleott/pages/mobile/settings/age_picker.dart';
import 'package:turtleott/pages/mobile/vods/vod_description_page.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/theme.dart';

class VodsView extends StatefulWidget {
  final List<OttPackageInfo> content;
  final ContentBloc bloc;
  final OnPackageBuyPressed onPackageBuyPressed;
  final Function(OttPackageInfo pack) onCurrentPackageChanged;

  const VodsView(this.content, this.bloc, this.onPackageBuyPressed, this.onCurrentPackageChanged);

  @override
  State<VodsView> createState() {
    return _VodsViewState();
  }
}

class _VodsViewState extends State<VodsView> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    if (widget.content.isNotEmpty) {
      tabController = TabController(vsync: this, length: widget.content.length);
      tabController.addListener(_update);
      final pack = widget.content[tabController.index];
      widget.onCurrentPackageChanged(pack);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.content.isNotEmpty) {
      tabController.removeListener(_update);
    }
    super.dispose();
  }

  void _update() {
    final pack = widget.content[tabController.index];
    widget.onCurrentPackageChanged(pack);
  }

  @override
  Widget build(BuildContext context) {
    final packages = widget.content;
    if (packages.isEmpty) {
      return const NoAvaiableChannels(title: TR_VODS);
    }
    return OrientationBuilder(
        builder: (context, orientation) => Column(children: <Widget>[
              _makeTabBar(tabController, packages),
              Expanded(child: _makeTabListPage(tabController, packages, orientation))
            ]));
  }

  Widget _makeTabBar(TabController tabController, List<OttPackageInfo> packages) {
    final tabBar = TabBarEx(
        tabController, List<String>.generate(packages.length, (index) => packages[index].name));
    return Row(children: <Widget>[
      Expanded(child: Material(elevation: 4, child: tabBar, color: Theme.of(context).primaryColor))
    ]);
  }

  Widget _makeTabListPage(
      TabController tabController, List<OttPackageInfo> packages, Orientation orientation) {
    return TabBarView(
        controller: tabController, children: _buildTabsContent(packages, orientation));
  }

  List<Widget> _buildTabsContent(List<OttPackageInfo> packages, Orientation orientation) {
    Widget _tile(OttPackageInfo pack, int index, VodInfo vod, double maxHeight, double maxWidth) {
      final settings = locator<LocalStorageService>();
      final age = settings.ageRating();
      bool isAgeAllowed() {
        return age >= vod.iarc;
      }

      final theme = Theming.of(context);
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: EDGE_INSETS, vertical: EDGE_INSETS * 1.5),
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
                        package: pack,
                        vod: pack.vods[index],
                        bloc: widget.bloc,
                        onPackageBuyPressed: widget.onPackageBuyPressed,
                      );
                    });
                    Navigator.push(context, route).then((onValue) {
                      setState(() {});
                    });
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => const CheckPassword()).then((value) {
                      if (value == true) {
                        final Route route = MaterialPageRoute(builder: (context) {
                          return VodDescription(
                            package: pack,
                            vod: pack.vods[index],
                            bloc: widget.bloc,
                            onPackageBuyPressed: widget.onPackageBuyPressed,
                          );
                        });
                        Navigator.push(context, route).then((onValue) {
                          setState(() {});
                        });
                      }
                    });
                  }
                }),
            VodCardBadge(
                left: 5,
                bottom: 5,
                child: age >= vod.iarc ? const VodCardViews(0) : VodAgeView(vod.iarc)),
            VodCardBadge(
              right: 5,
              top: 5,
              width: 36.0,
              child: isAgeAllowed()
                  ? locator<RuntimeDevice>().hasTouch
                      ? FavoriteStarButton(
                          onFavoriteChanged: (state) => widget.bloc
                              .add(SetVodFavoriteEvent(vod: VodStream(vod), state: state)),
                          vod.favorite(),
                          unselectedColor: theme.onPrimary(),
                        )
                      : Icon(vod.favorite() ? Icons.star : Icons.star_border,
                          color: vod.favorite()
                              ? theme.theme.colorScheme.onSecondary
                              : theme.onPrimary())
                  : const Icon(Icons.lock),
            )
          ])));
    }

    final List<Widget> cardGridList = [];
    for (final pack in packages) {
      if (pack.vods.isEmpty) {
        cardGridList.add(const NoAvaiableChannels(title: TR_VODS));
      } else {
        Widget drawTileCb(int index, VodInfo vod, double maxHeight, double maxWidth) {
          return _tile(pack, index, vod, maxHeight, maxWidth);
        }

        cardGridList.add(VodsCardGrid(
          pack.vods,
          drawTileCb,
          cardsInHorizontal: orientation == Orientation.portrait ? 3 : 5,
        ));
      }
    }
    return cardGridList;
  }
}
