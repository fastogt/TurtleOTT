import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/mobile_no_avaiable.dart';
import 'package:turtleott/base/mobile_tabbar.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/types.dart';
import 'package:turtleott/pages/home/vods/mobile_constants.dart';
import 'package:turtleott/pages/home/vods/mobile_vod_card.dart';
import 'package:turtleott/pages/home/vods/mobile_vod_card_views.dart';
import 'package:turtleott/pages/mobile/series/serial_description.dart';
import 'package:turtleott/pages/mobile/settings/age_picker.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';

class SeriesView extends StatefulWidget {
  final List<OttPackageInfo> content;
  final ContentBloc bloc;
  final OnPackageBuyPressed onPackageBuyPressed;
  final Function(OttPackageInfo pack) onCurrentPackageChanged;

  const SeriesView(this.content, this.bloc, this.onPackageBuyPressed, this.onCurrentPackageChanged);

  @override
  State<SeriesView> createState() {
    return _SeriesViewState();
  }
}

class _SeriesViewState extends State<SeriesView> with TickerProviderStateMixin {
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
      return const NoAvaiableChannels(title: TR_SERIES);
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
    Widget _tile(
        OttPackageInfo pack, int index, SerialInfo serial, double maxHeight, double maxWidth) {
      final settings = locator<LocalStorageService>();
      final age = settings.ageRating();
      bool isAgeAllowed() {
        return age >= serial.iarc;
      }

      final selectedColor = Theme.of(context).colorScheme.secondary;
      final unselectedColor = Theme.of(context).primaryIconTheme.color;
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: EDGE_INSETS, vertical: EDGE_INSETS * 1.5),
          child: Center(
              child: Stack(children: [
            VodCard(
                iconLink: serial.icon(),
                height: maxHeight,
                width: maxWidth,
                onPressed: () {
                  if (isAgeAllowed()) {
                    final Route route = MaterialPageRoute(builder: (context) {
                      return MobileSerialDescription(
                          package: pack,
                          serial: serial,
                          bloc: widget.bloc,
                          onPackageBuyPressed: widget.onPackageBuyPressed);
                    });
                    Navigator.push(context, route).then((value) {
                      setState(() {});
                    });
                  } else {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => const CheckPassword()).then((value) {
                      if (value == true) {
                        final Route route = MaterialPageRoute(builder: (context) {
                          return MobileSerialDescription(
                              package: pack,
                              serial: serial,
                              bloc: widget.bloc,
                              onPackageBuyPressed: widget.onPackageBuyPressed);
                        });
                        Navigator.push(context, route).then((value) {
                          setState(() {});
                        });
                      }
                    });
                  }
                }),
            VodCardBadge(
                left: 5,
                bottom: 5,
                child: isAgeAllowed() ? const SizedBox() : VodAgeView(serial.iarc)),
            VodCardBadge(
                right: 5,
                top: 5,
                width: 36.0,
                child: isAgeAllowed()
                    ? Icon(serial.favorite() ? Icons.star : Icons.star_border,
                        color: serial.favorite() ? selectedColor : unselectedColor)
                    : const Icon(Icons.lock))
          ])));
    }

    final List<Widget> cardGridList = [];
    for (final pack in packages) {
      if (pack.serials.isEmpty) {
        cardGridList.add(const NoAvaiableChannels(title: TR_SERIES));
      } else {
        Widget drawTileCb(int index, SerialInfo serial, double maxHeight, double maxWidth) {
          return _tile(pack, index, serial, maxHeight, maxWidth);
        }

        cardGridList.add(VodsCardGrid(pack.serials, drawTileCb,
            cardsInHorizontal: orientation == Orientation.portrait ? 3 : 5));
      }
    }
    return cardGridList;
  }
}
