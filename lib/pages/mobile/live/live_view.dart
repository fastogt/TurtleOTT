import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/mobile_no_avaiable.dart';
import 'package:turtleott/base/mobile_tabbar.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/types.dart';
import 'package:turtleott/pages/mobile/live/live_tile.dart';
import 'package:turtleott/pages/mobile/settings/age_picker.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';

import 'live_player_page.dart';

class LiveView extends StatefulWidget {
  final List<OttPackageInfo> content;
  final OnPackageBuyPressed onBuyPressed;
  final Function(OttPackageInfo pack) onCurrentPackageChanged;
  final ContentBloc bloc;
  const LiveView(this.content, this.onBuyPressed, this.onCurrentPackageChanged, this.bloc);

  @override
  State<LiveView> createState() {
    return _LiveViewState();
  }
}

class _LiveViewState extends State<LiveView> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    if (widget.content.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _lastViewed();
        setState(() {});
      });
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
      return const NoAvaiableChannels(title: TR_LIVE_TV);
    }
    return Column(children: <Widget>[
      _makeTabBar(tabController, packages),
      Expanded(child: _makeTabListPage(tabController, packages))
    ]);
  }

  Widget _makeTabBar(TabController tabController, List<OttPackageInfo> packages) {
    final tabBar = TabBarEx(
        tabController, List<String>.generate(packages.length, (index) => packages[index].name));
    return Row(children: <Widget>[
      Expanded(child: Material(elevation: 4, child: tabBar, color: Theme.of(context).primaryColor))
    ]);
  }

  Widget _makeTabListPage(TabController tabController, List<OttPackageInfo> packages) {
    return TabBarView(controller: tabController, children: _buildTabsContent(packages));
  }

  List<Widget> _buildTabsContent(List<OttPackageInfo> packages) {
    final List<Widget> result = [];
    for (final pack in packages) {
      result.add(_buildTabContent(pack));
    }
    return result;
  }

  Widget _buildTabContent(OttPackageInfo pack) {
    if (pack.streams.isEmpty) {
      return const NoAvaiableChannels(title: TR_LIVE_TV);
    }
    return ListView.separated(
        separatorBuilder: (context, int index) => const Divider(height: 6),
        itemCount: pack.streams.length,
        itemBuilder: (context, index) {
          return LiveStreamTile(
              package: pack,
              streamIndex: index,
              onBuyPressed: (pack) => widget.onBuyPressed(pack),
              bloc: widget.bloc);
        });
  }

  void _lastViewed() {
    bool isAgeAllowed(ChannelInfo channel) {
      final settings = locator<LocalStorageService>();
      final age = settings.ageRating();
      return age >= channel.iarc;
    }

    final settings = locator<LocalStorageService>();
    final isSaved = settings.saveLastViewed();

    if (!isSaved) {
      return;
    }
    final lastPackageID = settings.lastPackage();
    final lastChannelID = settings.lastChannel();
    if (lastChannelID == null && lastPackageID == null) {
      return;
    }
    settings.setLastPackage(null);
    settings.setLastChannel(null);
    final bloc = context.read<ContentBloc>();
    for (final OttPackageInfo pack in widget.content) {
      if (lastPackageID == pack.id) {
        for (int i = 0; i < pack.streams.length; i++) {
          if (pack.streams[i].id == lastChannelID) {
            final route = MaterialPageRoute(
                builder: (BuildContext context) =>
                    ChannelPage(bloc: bloc, position: i, package: pack, listener: null));

            if (isAgeAllowed(pack.streams[i])) {
              allowAll();
              Navigator.push(context, route);
            } else {
              showDialog(
                  context: context, builder: (BuildContext context) => CheckPassword(route: route));
            }

            return;
          }
        }
      }
    }
  }
}
