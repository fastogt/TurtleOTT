import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:player/common/controller.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/vod_stream.dart';
import 'package:turtleott/base/mobile_preview_icon.dart';
import 'package:turtleott/pages/home/types.dart';
import 'package:turtleott/pages/home/vods/mobile_vod_card.dart';
import 'package:turtleott/pages/home/vods/mobile_vod_description.dart';
import 'package:turtleott/pages/mobile/vods/vod_player_page.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/utils/theme.dart';

class VodDescription extends StatefulWidget {
  final OttPackageInfo package;
  final VodInfo vod;
  final ContentBloc bloc;
  final OnPackageBuyPressed onPackageBuyPressed;

  const VodDescription(
      {required this.package,
      required this.vod,
      required this.bloc,
      required this.onPackageBuyPressed})
      : super();

  @override
  State<VodDescription> createState() {
    return _VodDescriptionState();
  }
}

class _VodDescriptionState extends State<VodDescription> implements IPlayerListener<VodStream> {
  static const DESCRIPTION_FONT_SIZE = 20.0;

  CustomScrollController descriptionController =
      CustomScrollController(itemHeight: DESCRIPTION_FONT_SIZE);
  CustomScrollController infoController = CustomScrollController(itemHeight: DESCRIPTION_FONT_SIZE);

  final double _scaleFactor = 1;

  @override
  void onPlaying(IPlayerController cont, String url) {
    final vod = cont as VodPlayerController;
    widget.bloc.add(PlayingVodEvent(vod.currentStream));
  }

  @override
  void onPlayingError(IPlayerController cont, String url) {}

  @override
  void onEOS(IPlayerController cont, String url) {}

  @override
  void onSetInterrupt(IPlayerController cont, VodStream vod, int msec) {
    widget.bloc.add(SetVodInterruptedEvent(vod, msec, vod.duration()));
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
        mobile: OrientationBuilder(builder: (context, orientation) {
          return orientation == Orientation.portrait ? mobilePortrait() : mobileLandscape();
        }),
        tablet: tablet());
  }

  Widget tablet() {
    final textColor = Theming.of(context).onPrimary();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return FractionallySizedBox(
        widthFactor: _scaleFactor,
        heightFactor: _scaleFactor,
        child: Scaffold(
            appBar: AppBar(
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
                centerTitle: true,
                title: Text(AppLocalizations.toUtf8(widget.vod.displayName()),
                    style: TextStyle(color: textColor)),
                leading: _backButton(),
                actions: <Widget>[_playButton(), _trailerButton(), _starButton()]),
            body: Stack(children: [
              Opacity(
                  opacity: 0.5,
                  child: PreviewIcon(widget.vod.vod.backgroundIcon,
                      width: screenWidth, height: screenHeight)),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _poster(screenWidth * 0.3),
                        SizedBox(
                            width: screenWidth * 0.6,
                            child: Column(children: <Widget>[
                              Expanded(
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [_score()])),
                              Expanded(child: _info()),
                              Expanded(flex: 4, child: _description())
                            ]))
                      ]))
            ])));
  }

  Widget mobileLandscape() {
    final textColor = Theming.of(context).onPrimary();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return FractionallySizedBox(
        widthFactor: _scaleFactor,
        heightFactor: _scaleFactor,
        child: Scaffold(
            appBar: AppBar(
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
                centerTitle: true,
                title: Text(AppLocalizations.toUtf8(widget.vod.displayName()),
                    style: TextStyle(color: textColor)),
                leading: _backButton(),
                actions: <Widget>[_starButton()]),
            body: Stack(children: [
              Opacity(
                opacity: 0.5,
                child: PreviewIcon(widget.vod.vod.backgroundIcon,
                    width: screenWidth, height: screenHeight),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    _poster(screenWidth * 0.2),
                    const SizedBox(width: 16),
                    SizedBox(
                        width: screenWidth * 0.7,
                        child: Column(children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [_trailerButton(), _playButton()],
                          ),
                          Padding(
                              padding: EdgeInsets.all(8.0 * _scaleFactor),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    _score(),
                                    const VerticalDivider(color: Colors.white),
                                    _info()
                                  ])),
                          Expanded(child: _description())
                        ]))
                  ]))
            ])));
  }

  Widget mobilePortrait() {
    final textColor = Theming.of(context).onPrimary();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return FractionallySizedBox(
        widthFactor: _scaleFactor,
        heightFactor: _scaleFactor,
        child: Scaffold(
            appBar: AppBar(
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
                centerTitle: true,
                title: Text(AppLocalizations.toUtf8(widget.vod.displayName()),
                    style: TextStyle(color: textColor)),
                leading: _backButton(),
                actions: <Widget>[_starButton()]),
            body: Stack(children: [
              Opacity(
                opacity: 0.5,
                child: PreviewIcon(widget.vod.vod.backgroundIcon,
                    width: screenWidth, height: screenHeight),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(children: <Widget>[
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      _poster(screenWidth * 0.4),
                      const SizedBox(width: 16),
                      SizedBox(
                          width: screenWidth * 0.45,
                          child: Column(children: [_score(), _trailerButton(), _playButton()]))
                    ]),
                    Padding(padding: EdgeInsets.all(8.0 * _scaleFactor), child: _info()),
                    Expanded(child: _description())
                  ]))
            ])));
  }

  Widget _backButton() {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Theming.of(context).onPrimary(),
        onPressed: Navigator.of(context).pop);
  }

  Widget _playButton() {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: BaseVodPlayButton(widget.vod, widget.package, false, this,
            () => widget.onPackageBuyPressed(widget.package)));
  }

  Widget _trailerButton() {
    return Padding(padding: const EdgeInsets.all(8.0), child: VodTrailerButton(widget.vod));
  }

  Widget _starButton() {
    return FavoriteStarButton(
      onFavoriteChanged: (state) {
        widget.bloc.add(SetVodFavoriteEvent(vod: VodStream(widget.vod), state: state));
      },
      widget.vod.favorite(),
      unselectedColor: Theming.of(context).onPrimary(),
    );
  }

  Widget _score() {
    return UserScore(widget.vod.userScore());
  }

  Widget _info() {
    return SideInfo(
        views: 0,
        country: widget.vod.country(),
        duration: widget.vod.duration(),
        primeDate: widget.vod.primeDate());
  }

  Widget _poster(double width) {
    return VodCard(width: width, iconLink: widget.vod.vod.previewIcon, onPressed: _onPlayPressed);
  }

  Widget _description() {
    final description = widget.vod.vod.description;
    return DescriptionText(description,
        scrollController: descriptionController.controller,
        textColor: Theming.of(context).onBrightness());
  }

  void _onPlayPressed() async {
    final vodStream = VodStream(widget.vod);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return MobileVodPlayer(vodStream, this);
    }));
  }
}
