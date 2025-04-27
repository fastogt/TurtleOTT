import 'package:flutter/material.dart';
import 'package:flutter_common/localization.dart';
import 'package:flutter_common/utils.dart';
import 'package:flutter_common/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/subjects.dart';
import 'package:turtleott/base/net_assets.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/sidebar_tile.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/theme.dart';

class SideBarItem {
  final String name;
  final IconData icon;

  const SideBarItem(this.name, this.icon);
}

class SideBar extends StatefulWidget {
  final String logoLink;
  final List<SideBarItem> items;
  final Function(BuildContext context, String name) builder;

  const SideBar({required this.items, required this.builder, required this.logoLink});

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final FocusScopeNode _scope = FocusScopeNode();
  final BehaviorSubject<String> _updates = BehaviorSubject<String>();

  String get current => _updates.stream.value;

  static const double expandedWidth = 240;

  bool opened = false;

  @override
  void initState() {
    super.initState();
    _updates.add(TR_LIVE_TV);
    _scope.addListener(_toggle);
  }

  @override
  void dispose() {
    _scope.removeListener(_toggle);
    _scope.dispose();
    _updates.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = locator<LocalStorageService>();
    final langCode = settings.langCode();

    final List<Widget> _tiles = List<Widget>.generate(widget.items.length, _tile);
    final double logoSize = opened ? 80 : 50;
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(children: [
          FocusScope(
              node: _scope,
              child: AnimatedContainer(
                  color: Theming.of(context).themeId == LIGHT_THEME_ID
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).scaffoldBackgroundColor,
                  duration: const Duration(milliseconds: 100),
                  width: opened ? expandedWidth : SidebarTile.iconWidth,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: SizedBox(
                          width: expandedWidth,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const SizedBox(height: 10),
                            SizedBox(
                              width: opened ? expandedWidth : SidebarTile.iconWidth,
                              child:
                                  NetAssetsIcon(widget.logoLink, width: logoSize, height: logoSize),
                            ),
                            const Spacer(),
                            ..._tiles,
                            const Spacer(),
                            SizedBox(
                                width: opened ? expandedWidth : SidebarTile.iconWidth,
                                child: const Clock.time(dateFontSize: 15)),
                            SizedBox(
                                width: opened ? expandedWidth : SidebarTile.iconWidth,
                                child: Clock.date(dateformat: DateFormat.EEEE(langCode))),
                            SizedBox(
                                width: opened ? expandedWidth : SidebarTile.iconWidth,
                                child: Clock.date(dateformat: DateFormat.yMMMMd(langCode))),
                            const SizedBox(height: 24)
                          ]))))),
          SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width - SidebarTile.iconWidth,
              child: Stack(children: [
                Positioned.fill(
                    child: StreamBuilder<String>(
                        initialData: TR_LIVE_TV,
                        stream: _updates.stream,
                        builder: (context, snapshot) {
                          return widget.builder(context, snapshot.data!);
                        })),
                Positioned(
                    left: 0,
                    right: MediaQuery.of(context).size.width - SidebarTile.iconWidth - 3,
                    top: 0,
                    bottom: 0,
                    child: Image.asset('install/assets/rainbow.jpg', fit: BoxFit.fill))
              ]))
        ]));
  }

  Widget _tile(int index) {
    return SidebarTile(
        icon: widget.items[index].icon,
        title: translate(context, AppLocalizations.toUtf8(widget.items[index].name)),
        onKey: (event) {
          return onKey(event, (key) {
            switch (key) {
              case KeyConstants.KEY_UP:
                return _scope.focusInDirection(TraversalDirection.up)
                    ? KeyEventResult.handled
                    : KeyEventResult.ignored;
              case KeyConstants.KEY_DOWN:
                return _scope.focusInDirection(TraversalDirection.down)
                    ? KeyEventResult.handled
                    : KeyEventResult.ignored;
              case KeyConstants.KEY_RIGHT:
                return FocusScope.of(context).focusInDirection(TraversalDirection.right)
                    ? KeyEventResult.handled
                    : KeyEventResult.ignored;
            }
            return KeyEventResult.ignored;
          });
        },
        onFocusChanged: (hasFocus) {
          if (hasFocus) {
            _updates.add(widget.items[index].name);
          }
        },
        selected: current == widget.items[index].name);
  }

  void _toggle() {
    setState(() {
      opened = _scope.hasFocus;
    });
  }
}
