import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turtleott/app_config.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/notification_dialog.dart';
import 'package:turtleott/base/websocket/online_subscribers_bloc/online_subscribers_bloc.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/channels/channels_page.dart';
import 'package:turtleott/pages/home/exit_dialog.dart';
import 'package:turtleott/pages/home/series/series_page.dart';
import 'package:turtleott/pages/home/settings/settings_page.dart';
import 'package:turtleott/pages/home/sidebar.dart';
import 'package:turtleott/pages/home/vods/vods_page.dart';
import 'package:turtleott/pages/login/login_page.dart';
import 'package:turtleott/pages/profile.dart';
import 'package:turtleott/utils/iptv.dart';

class HomeTV extends StatelessWidget {
  final Profile profile;

  const HomeTV(this.profile, {Key? key}) : super(key: key);

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
                child: HomePage(profile, content));
          }
          return const Scaffold(body: LoginLoading(TR_PACKAGES_LOADING));
        });
  }
}

class HomePage extends StatefulWidget {
  final List<OttPackageInfo> content;
  final Profile profile;

  const HomePage(this.profile, this.content);

  static HomePageState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_InheritedStreamsProvider>()!.data;
  }

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RealtimeMessageBloc, BaseState>(builder: (context, state) {
      if (state is SendMessageData) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(context: context, builder: (context) => NotificationDialog(state.message));
        });
      }
      return PopScope(
        canPop: false,
        child: _InheritedStreamsProvider(
            data: this,
            child: Scaffold(
                body: Row(children: [
              Expanded(
                  child: SideBar(
                      logoLink: widget.profile.info.brand.logo,
                      items: const [
                        SideBarItem(TR_LIVE_TV, Icons.personal_video),
                        SideBarItem(TR_VODS, Icons.ondemand_video),
                        SideBarItem(TR_SERIES, Icons.list),
                        SideBarItem(TR_SETTINGS, Icons.settings),
                        SideBarItem(TR_EXIT, Icons.power_settings_new),
                      ],
                      builder: (context, name) {
                        void buyCb(OttPackageInfo pack) {
                          if (pack.id == null) {
                            return;
                          }

                          widget.profile.subscribe(pack.id!);
                        }

                        switch (name) {
                          case TR_LIVE_TV:
                            final List<OttPackageInfo> livePackages = [];
                            for (final OttPackageInfo pack in widget.content) {
                              if (pack.streams.isNotEmpty) {
                                livePackages.add(pack);
                              }
                            }
                            return ChannelsPage(livePackages, buyCb, context.read<ContentBloc>());
                          case TR_VODS:
                            final List<OttPackageInfo> vodsPackages = [];
                            for (final OttPackageInfo pack in widget.content) {
                              if (pack.vods.isNotEmpty) {
                                vodsPackages.add(pack);
                              }
                            }
                            return VodsPage(vodsPackages,
                                context.read<ContentBloc>()); //TODO add locked message
                          case TR_SERIES:
                            final List<OttPackageInfo> serialsPackages = [];
                            for (final OttPackageInfo pack in widget.content) {
                              if (pack.serials.isNotEmpty) {
                                serialsPackages.add(pack); //TODO add locked message
                              }
                            }
                            return SeriesPage(serialsPackages, context.read<ContentBloc>());
                          case TR_SETTINGS:
                            return SettingsPage(widget.profile);
                          case TR_EXIT:
                            return ExitDialog();
                          default:
                            return const SizedBox();
                        }
                      }))
            ]))),
      );
    });
  }
}

class _InheritedStreamsProvider extends InheritedWidget {
  final HomePageState data;

  const _InheritedStreamsProvider({required this.data, required Widget child, Key? key})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStreamsProvider oldWidget) {
    return true;
  }
}
