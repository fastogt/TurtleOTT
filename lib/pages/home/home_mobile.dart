import 'package:fastotv_dart/commands_info.dart';
import 'package:fastotv_dart/commands_info/package_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/app_config.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/live_stream.dart';
import 'package:turtleott/base/channels/series_stream.dart';
import 'package:turtleott/base/channels/vod_stream.dart';
import 'package:turtleott/base/net_assets.dart';
import 'package:turtleott/base/notification_dialog.dart';
import 'package:turtleott/base/websocket/online_subscribers_bloc/online_subscribers_bloc.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/login/login_page.dart';
import 'package:turtleott/pages/mobile/about_page.dart';
import 'package:turtleott/pages/mobile/live/live_search.dart';
import 'package:turtleott/pages/mobile/live/live_view.dart';
import 'package:turtleott/pages/mobile/series/series_search.dart';
import 'package:turtleott/pages/mobile/series/series_view.dart';
import 'package:turtleott/pages/mobile/settings/settings_page.dart';
import 'package:turtleott/pages/mobile/vods/vod_search.dart';
import 'package:turtleott/pages/mobile/vods/vods_view.dart';
import 'package:turtleott/pages/profile.dart';
import 'package:turtleott/utils/iptv.dart';
import 'package:turtleott/utils/theme.dart';

class HomeMobile extends StatelessWidget {
  final Profile profile;

  const HomeMobile(this.profile, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: profile.packagesWithToken(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var (content, avail) = snapshot.data!;
            final isIPTV = !AppConfig.of(context).isOTT;
            if (isIPTV) {
              (_, content) = generateIPTVPackages(content);
            }
            return BlocProvider(
                create: (context) => ContentBloc(profile: profile),
                child: HomeMobileView(profile, content));
          }
          return const Scaffold(body: LoginLoading(TR_PACKAGES_LOADING));
        });
  }
}

class HomeMobileView extends StatefulWidget {
  final Profile profile;
  final List<OttPackageInfo> content;

  const HomeMobileView(this.profile, this.content, {Key? key}) : super(key: key);

  @override
  State<HomeMobileView> createState() {
    return _HomeMobileViewState();
  }
}

class _HomeMobileViewState extends State<HomeMobileView> {
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  String selectedType = TR_LIVE_TV;
  late final List<String> videoTypesList;
  int selectedPackage = 0;

  @override
  void initState() {
    videoTypesList = [TR_LIVE_TV, TR_VODS, TR_SERIES];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Theming.onCustomColor(Theme.of(context).primaryColor);
    return BlocBuilder<RealtimeMessageBloc, BaseState>(
      builder: (context, state) {
        if (state is SendMessageData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(context: context, builder: (context) => NotificationDialog(state.message));
          });
        }
        return PopScope(
            canPop: false,
            child: Scaffold(
                key: _drawerKey,
                appBar: _appBar(color),
                drawer: _Drawer(widget.profile, _setType, videoTypesList, selectedType),
                body: _getCurrentTabWidget()));
      },
    );
  }

  Widget _getCurrentTabWidget() {
    void updatePackage(OttPackageInfo pack) {
      final index = widget.content.indexWhere((el) => el == pack);
      updateCurrentPackage(index);
    }

    void buyCb(OttPackageInfo pack) {
      if (pack.id == null) {
        return;
      }

      widget.profile.subscribe(pack.id!);
    }

    if (selectedType == TR_LIVE_TV) {
      final List<OttPackageInfo> packages = [];
      for (final OttPackageInfo pack in widget.content) {
        if (pack.streams.isNotEmpty) {
          packages.add(pack);
        }
      }
      return LiveView(packages, buyCb, updatePackage, context.read<ContentBloc>());
    } else if (selectedType == TR_VODS) {
      final List<OttPackageInfo> packages = [];
      for (final OttPackageInfo pack in widget.content) {
        if (pack.vods.isNotEmpty) {
          packages.add(pack);
        }
      }
      return VodsView(packages, context.read<ContentBloc>(), buyCb, updatePackage);
    } else if (selectedType == TR_SERIES) {
      final List<OttPackageInfo> packages = [];
      for (final OttPackageInfo pack in widget.content) {
        if (pack.serials.isNotEmpty) {
          packages.add(pack);
        }
      }
      return SeriesView(packages, context.read<ContentBloc>(), buyCb, updatePackage);
    }
    return Container(color: Colors.pink);
  }

  void updateCurrentPackage(int index) {
    selectedPackage = index;
  }

  OttPackageInfo get currentPackage {
    return widget.content[selectedPackage];
  }

  SearchDelegate? get searchDelegate {
    void buyCb(OttPackageInfo pack) {
      if (pack.id == null) {
        return;
      }

      widget.profile.subscribe(pack.id!);
    }

    final bloc = context.read<ContentBloc>();

    switch (selectedType) {
      case TR_LIVE_TV:
        {
          final List<LiveStream> streams = [];
          for (final el in currentPackage.streams) {
            streams.add(LiveStream(el));
          }
          return LiveStreamSearch<LiveStream>(streams, translate(context, TR_SEARCH_LIVE),
              currentPackage, buyCb, context.read<ContentBloc>());
        }
      case TR_VODS:
        {
          final List<VodStream> vods = [];
          for (final el in currentPackage.vods) {
            vods.add(VodStream(el));
          }
          return VodStreamSearch(
              vods, translate(context, TR_SEARCH_VOD), currentPackage, bloc, buyCb);
        }
      case TR_SERIES:
        {
          final List<SerialStream> serials = [];
          for (final el in currentPackage.serials) {
            serials.add(SerialStream(el));
          }
          return SeriesStreamSearch(
              serials, translate(context, TR_SEARCH_SERIES), currentPackage, buyCb, bloc);
        }
      default:
        return null;
    }
  }

  void _setType(String type) {
    setState(() {
      selectedType = type;
    });
    updateCurrentPackage(0);
  }

  PreferredSizeWidget _appBar(Color iconColor) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      automaticallyImplyLeading: false,
      title: Text(translate(context, selectedType), style: TextStyle(color: iconColor)),
      leading: IconButton(
          icon: Icon(Icons.menu, color: iconColor),
          onPressed: () => _drawerKey.currentState!.openDrawer()),
      actions: <Widget>[if (selectedType != TR_PACKAGES && widget.content.isNotEmpty) _search()],
    );
  }

  Widget _search() {
    final Color color = Theming.onCustomColor(Theme.of(context).primaryColor);
    return IconButton(
        icon: Icon(
          Icons.search,
          color: color,
        ),
        onPressed: () => showSearch(context: context, delegate: searchDelegate!));
  }
}

class _Drawer extends StatelessWidget {
  final List<String> videoTypesList;
  final String selectedType;
  final void Function(String) onType;
  final Profile profile;

  String get logo {
    return profile.info.brand.logo;
  }

  const _Drawer(this.profile, this.onType, this.videoTypesList, this.selectedType);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      DrawerHeader(child: Center(child: NetAssetsIcon(logo))),
      _drawerTiles(context),
      const Divider(),
      _SettingsTile(profile),
      _AboutTile(profile),
    ]));
  }

  Widget _drawerTiles(BuildContext context) {
    final iconColor = Theming.of(context).onBrightness();
    final tabs = List<ListTile>.generate(videoTypesList.length, (int index) {
      final type = videoTypesList[index];
      final title = translate(context, type);
      final icon = _iconFromType(type);
      return ListTile(
          leading: Icon(icon, color: iconColor),
          title: Text(title),
          selected: title == selectedType,
          selectedColor: Theme.of(context).textTheme.titleMedium!.color,
          selectedTileColor: Theme.of(context).focusColor,
          onTap: () {
            Navigator.of(context).pop();
            onType(videoTypesList[index]);
          });
    });
    return Column(mainAxisSize: MainAxisSize.min, children: tabs);
  }

  IconData _iconFromType(String type) {
    if (type == TR_LIVE_TV) {
      return Icons.personal_video;
    } else if (type == TR_VODS) {
      return Icons.ondemand_video;
    }
    // else if (type == TR_PACKAGES) {
    //   return Icons.add_to_photos;
    // }
    else if (type == TR_SERIES) {
      return Icons.video_library;
    }
    return Icons.warning;
  }
}

class _AboutTile extends StatelessWidget {
  final Profile profile;

  const _AboutTile(this.profile);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.info, color: Theming.of(context).onBrightness()),
        title: Text(translate(context, TR_ABOUT)),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return AboutPage(profile);
          }));
        });
  }
}

class _SettingsTile extends StatelessWidget {
  final Profile profile;

  const _SettingsTile(this.profile);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.settings, color: Theming.of(context).onBrightness()),
        title: Text(translate(context, TR_SETTINGS)),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => SettingsPage(profile: profile)));
        });
  }
}
