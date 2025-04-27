import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/base/vods/vod_description.dart';
import 'package:intl/intl.dart';
import 'package:player/common/controller.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/episode_stream.dart';
import 'package:turtleott/base/channels/istream.dart';
import 'package:turtleott/base/mobile_preview_icon.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/types.dart';
import 'package:turtleott/pages/home/vods/mobile_vod_description.dart';
import 'package:turtleott/pages/mobile/series/season_player_page.dart';
import 'package:turtleott/pages/mobile/vods/vod_description_page.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/utils/theme.dart';

class MobileSerialDescription extends StatefulWidget {
  final ContentBloc bloc;
  final OttPackageInfo package;
  final SerialInfo serial;
  final OnPackageBuyPressed onPackageBuyPressed;
  final Function(bool favorite)? onFavoriteChanged;

  const MobileSerialDescription(
      {required this.bloc,
      required this.package,
      required this.serial,
      required this.onPackageBuyPressed,
      this.onFavoriteChanged});

  Future<List<SeasonInfo>?> future() {
    return bloc.profile.getSerialSeasons(serial.pid, serial.id);
  }

  @override
  _SerialDescriptionState createState() {
    return _SerialDescriptionState();
  }
}

class _SerialDescriptionState extends State<MobileSerialDescription> {
  SerialInfo get serial {
    return widget.serial;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theming.of(context).onPrimary();

    return FutureBuilder(
        future: widget.future(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<SeasonInfo> seasons = [];
          if (snapshot.data != null) {
            seasons = snapshot.data!;
          }

          return Scaffold(
              appBar: AppBar(
                  elevation: 0,
                  backgroundColor: Theme.of(context).primaryColor,
                  centerTitle: true,
                  iconTheme: IconThemeData(color: textColor),
                  title: Text(AppLocalizations.toUtf8(widget.serial.name),
                      style: TextStyle(color: textColor)),
                  actions: [
                    FavoriteStarButton(
                        onFavoriteChanged: widget.onFavoriteChanged,
                        widget.serial.favorite(),
                        unselectedColor: textColor)
                  ]),
              body: _drawSeasons(seasons));
        });
  }

  Widget _drawSeasons(List<SeasonInfo> seasons) {
    return _SeasonsWidget(
        bloc: widget.bloc,
        package: widget.package,
        serial: serial,
        seasons: seasons,
        onPackageBuyPressed: widget.onPackageBuyPressed);
  }
}

class _SeasonsWidget extends StatefulWidget {
  final ContentBloc bloc;
  final OttPackageInfo package;
  final SerialInfo serial;
  final List<SeasonInfo> seasons;

  final OnPackageBuyPressed onPackageBuyPressed;

  const _SeasonsWidget(
      {required this.bloc,
      required this.package,
      required this.serial,
      required this.seasons,
      required this.onPackageBuyPressed});

  @override
  _SeasonsWidgetState createState() {
    return _SeasonsWidgetState();
  }
}

class _SeasonsWidgetState extends State<_SeasonsWidget> {
  late int _currentSeasonIndex;

  SeasonInfo get _currentSeason {
    return _seasons[_currentSeasonIndex];
  }

  String get background {
    if (_seasons.isNotEmpty) {
      return _currentSeason.background;
    }
    return widget.serial.background;
  }

  SerialInfo get serial {
    return widget.serial;
  }

  List<SeasonInfo> get _seasons {
    return widget.seasons;
  }

  @override
  void initState() {
    super.initState();
    _currentSeasonIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Stack(children: <Widget>[
      Opacity(
          opacity: 0.5, child: PreviewIcon(background, width: screenWidth, height: screenHeight)),
      Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: ScreenTypeLayout.builder(
              mobile: (_) => OrientationBuilder(builder: (context, orientation) {
                    return orientation == Orientation.portrait ? portrait() : landscape();
                  }),
              tablet: (_) => OrientationBuilder(builder: (context, orientation) {
                    return orientation == Orientation.portrait ? portrait() : landscapeTablet();
                  })))
    ]);
  }

  Widget portrait() {
    if (_seasons.isEmpty) {
      return _emptySerialPortrait();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    return Column(children: <Widget>[
      Row(children: <Widget>[
        PreviewIcon(_currentSeason.icon(), width: screenWidth * 0.4),
        Expanded(child: _seasonsList())
      ]),
      Expanded(
          child: _SeasonTabs(
              widget.package, widget.onPackageBuyPressed, _currentSeason, serial, widget.bloc))
    ]);
  }

  Widget _emptySerialPortrait() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(children: <Widget>[
      Row(children: <Widget>[
        PreviewIcon(widget.serial.icon(), width: screenWidth * 0.4),
        SizedBox(width: screenWidth * 0.1),
        DescriptionText(translate(context, TR_COMING_SOON))
      ]),
      Expanded(child: DescriptionText(widget.serial.description))
    ]);
  }

  Widget landscape() {
    if (_seasons.isEmpty) {
      return _emptySerialLandscape();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
      Column(children: <Widget>[
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Focus(
                        child: PreviewIcon(_currentSeason.icon(), width: screenWidth * 0.2)))))
      ]),
      SizedBox(
          width: screenWidth * 0.7,
          child: Column(children: [
            Expanded(child: _seasonsList()),
            Expanded(
                flex: 3,
                child: _SeasonTabs(widget.package, widget.onPackageBuyPressed, _currentSeason,
                    serial, widget.bloc))
          ]))
    ]);
  }

  Widget _emptySerialLandscape() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.1),
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
          Column(children: <Widget>[
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Focus(
                            child: PreviewIcon(widget.serial.icon(), width: screenWidth * 0.2)))))
          ]),
          SizedBox(
              width: screenWidth * 0.7,
              child: Column(children: [
                Expanded(child: DescriptionText(translate(context, TR_COMING_SOON))),
                Expanded(flex: 3, child: DescriptionText(widget.serial.description))
              ]))
        ]));
  }

  Widget landscapeTablet() {
    if (_seasons.isEmpty) {
      return _emptySerialLandscapeTablet();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Column(children: <Widget>[
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: Focus(
                        child: PreviewIcon(_currentSeason.icon(), width: screenWidth * 0.3)))))
      ]),
      SizedBox(
          width: screenWidth * 0.6,
          child: Column(children: [
            Expanded(child: _seasonsList()),
            Expanded(
                flex: 3,
                child: _SeasonTabs(widget.package, widget.onPackageBuyPressed, _currentSeason,
                    serial, widget.bloc))
          ]))
    ]);
  }

  Widget _emptySerialLandscapeTablet() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Column(children: <Widget>[
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child:
                        Focus(child: PreviewIcon(widget.serial.icon(), width: screenWidth * 0.3)))))
      ]),
      SizedBox(
          width: screenWidth * 0.6,
          child: Column(children: [
            Expanded(child: DescriptionText(widget.serial.description)),
            Expanded(flex: 3, child: DescriptionText(translate(context, TR_COMING_SOON)))
          ]))
    ]);
  }

  Widget _seasonsList() {
    return PopupMenuButton<int>(
        position: PopupMenuPosition.under,
        itemBuilder: (context) {
          final seasonsList = List.generate(_seasons.length, (index) {
            return PopupMenuItem<int>(
                value: index, child: Text(AppLocalizations.toUtf8(_seasons[index].name)));
          });
          return seasonsList;
        },
        onSelected: (value) {
          _setSeason(value);
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(AppLocalizations.toUtf8(_currentSeason.name)),
          Icon(Icons.expand_more_rounded, color: Theme.of(context).colorScheme.secondary)
        ]));
  }

  void _setSeason(int index) {
    setState(() {
      _currentSeasonIndex = index;
    });
  }
}

class _SeasonTabs extends StatefulWidget {
  final OttPackageInfo package;
  final SerialInfo serial;
  final OnPackageBuyPressed onPackageBuyPressed;
  final SeasonInfo season;
  final ContentBloc bloc;

  const _SeasonTabs(this.package, this.onPackageBuyPressed, this.season, this.serial, this.bloc);

  @override
  _SeasonTabsState createState() => _SeasonTabsState();
}

class _SeasonTabsState extends State<_SeasonTabs> with SingleTickerProviderStateMixin {
  late TabController _controller;

  static const double DESCRIPTION_FONT_SIZE = 20.0;

  CustomScrollController descriptionController =
      CustomScrollController(itemHeight: DESCRIPTION_FONT_SIZE);

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor = Theming.of(context).onPrimary();
    return Column(children: <Widget>[
      TabBar(
          indicatorColor: Theme.of(context).colorScheme.secondary,
          labelColor: textColor,
          controller: _controller,
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          tabs: <Widget>[
            Tab(text: translate(context, TR_DESCRIPTION)),
            Tab(text: translate(context, TR_EPISODES))
          ]),
      Expanded(
          child: TabBarView(controller: _controller, children: <Widget>[
        SizedBox(
            child: Column(children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
            _getPrimeDate(),
            SideInfoItem(
                title: translate(context, TR_VIEWS),
                data: _getViewCount(widget.package, widget.serial).toString())
          ]),
          Expanded(
              child: DescriptionText(widget.season.description,
                  scrollController: descriptionController.controller,
                  textColor: Theming.of(context).onBrightness()))
        ])),
        _EpisodesList(widget.package, widget.onPackageBuyPressed, widget.season, widget.bloc)
      ]))
    ]);
  }

  int _getViewCount(OttPackageInfo pack, SerialInfo serial) {
    return 0;
  }

  Widget _getPrimeDate() {
    final DateTime ts = DateTime.fromMillisecondsSinceEpoch(widget.serial.primeDate);
    final String primeDate = DateFormat('dd.MM yyyy').format(ts);
    return SideInfoItem(title: translate(context, TR_PRIME_DATE), data: primeDate);
  }
}

class _EpisodesList extends StatefulWidget {
  final OttPackageInfo package;
  final OnPackageBuyPressed onPackageBuyPressed;
  final ContentBloc bloc;
  final SeasonInfo season;

  const _EpisodesList(this.package, this.onPackageBuyPressed, this.season, this.bloc);

  Future<List<VodInfo>?> future() {
    return bloc.profile.getSeasonEpisodes(season.pid, season.id);
  }

  @override
  State<_EpisodesList> createState() {
    return _EpisodesListState();
  }
}

class _EpisodesListState extends State<_EpisodesList> implements IPlayerListener<EpisodeStream> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.future(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<VodInfo> episodes = [];
          if (snapshot.data != null) {
            episodes = snapshot.data!;
          }

          return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: episodes.length,
              itemBuilder: (BuildContext context, int index) {
                final VodInfo episode = episodes[index];
                return ListTile(
                    leading: Text('${index + 1}'),
                    title: Text(AppLocalizations.toUtf8(episode.displayName())),
                    onTap: () => _play(context, index, episodes),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      _favorite(episode),
                      _infoButton(context, index, episodes)
                    ]));
              });
        });
  }

  @override
  void onSetInterrupt(IPlayerController cont, IStream stream, int msec) {}

  @override
  void onPlaying(IPlayerController cont, String url) {
    final base = cont as EpisodePlayerController;
    widget.bloc.add(PlayingEpisodeEvent(base.currentStream));
  }

  @override
  void onPlayingError(IPlayerController cont, String url) {}

  @override
  void onEOS(IPlayerController cont, String url) {}

  Widget _infoButton(BuildContext context, int index, List<VodInfo> episodes) {
    return IconButton(
        icon: const Icon(Icons.info),
        onPressed: () => _toInfo(context, index, episodes, widget.package));
  }

  Widget _favorite(VodInfo episode) {
    // if (episode.favorite()) {
    //   return const Icon(Icons.star);
    // }

    return const SizedBox();
  }

  void _toInfo(
      BuildContext context, int index, List<VodInfo> episodes, OttPackageInfo package) async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => VodDescription(
            package: package,
            onPackageBuyPressed: widget.onPackageBuyPressed,
            vod: episodes[index],
            bloc: widget.bloc)));
    if (result != null) {
      _play(context, index, episodes);
    }
  }

  void _play(BuildContext context, int index, List<VodInfo> episodes) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => EpisodePlayerPage(
                  package: widget.package,
                  initEpisode: index,
                  episodes: episodes,
                  listener: this,
                  bloc: widget.bloc,
                  onLast: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                )));
  }
}
