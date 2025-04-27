import 'dart:core';

import 'package:dart_chromecast/chromecast.dart';
import 'package:dart_chromecast/widgets/connection_icon.dart';
import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/appbar_player.dart';
import 'package:flutter_fastotv_common/base/controls/custom_appbar.dart';
import 'package:flutter_fastotv_common/base/controls/fullscreen_button.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/live_stream.dart';
import 'package:turtleott/base/streams/program_bloc.dart';
import 'package:turtleott/pages/home/channels/programs_list.dart';
import 'package:turtleott/pages/mobile/mobile_player.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/player/mobile_bottom_controls.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/theme.dart';

class ChannelPage extends StatefulWidget {
  final ContentBloc bloc;
  final OttPackageInfo package;
  final int position;
  final IPlayerListener<LiveStream>? listener;

  const ChannelPage(
      {required this.bloc, required this.package, required this.position, required this.listener});

  @override
  _ChannelPageState createState() {
    return _ChannelPageState();
  }
}

class _ChannelPageState<T extends LiveStream> extends PlayerPageMobileState<ChannelPage> {
  late LivePlayerController _controller;

  @override
  LiveStream get stream => _currentChannel;

  @override
  LivePlayerController get controller => _controller;

  ProgramsBloc? programsBloc;
  late int currentPos;

  LiveStream get _currentChannel {
    final cur = widget.package.streams[currentPos];
    return LiveStream(cur);
  }

  @override
  void initState() {
    _initProgramsBloc(widget.position);
    currentPos = widget.position;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    programsBloc?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = locator<LocalStorageService>();
    return withSideList(settings);
  }

  Widget withSideList(LocalStorageService settings) {
    final settings = locator<LocalStorageService>();
    return MobileAppBarPlayer.sideList(
        appbar: (background, text) => appBar(),
        child: playerArea(_currentChannel.icon()),
        bottomControls: bottomControls,
        sideList: sideListContent,
        bottomControlsHeight: bottomControlsHeight(),
        onDoubleTap: !initialized
            ? null
            : isPlaying()
                ? pause
                : play,
        onLongTapLeft: !initialized ? null : onLongTapLeft,
        onLongTapRight: !initialized ? null : onLongTapRight,
        absoluteBrightness: settings.brightnessChange(),
        absoluteSound: settings.soundChange(),
        onPrimaryColor: Theming.of(context).onPrimary);
  }

  double bottomControlsHeight() {
    return BUTTONS_LINE_HEIGHT + TEXT_HEIGHT + TIMELINE_HEIGHT + TEXT_PADDING;
  }

  Widget appBar() {
    return ChannelPageAppBar(
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Theming.of(context).onPrimary(),
        title: AppLocalizations.toUtf8(_currentChannel.displayName()),
        onExit: () {
          // final settings = locator<LocalStorageService>();
          // final isSaved = settings.saveLastViewed();
          // if (isSaved) {
          // settings.setLastPackage(widget.package.id);
          // settings.setLastChannel(_currentChannel.id());
          // }
          Navigator.of(context).pop();
        },
        actions: <Widget>[
          const ChromeCastIcon(),
          if (isPortrait(context)) const FullscreenButton.open() else const FullscreenButton.close()
        ]);
  }

  Widget bottomControls(Color? back, Color text, Widget sideListButton) {
    return Container(
        color: Theme.of(context).primaryColor,
        width: MediaQuery.of(context).size.width,
        height: bottomControlsHeight(),
        child: initialized
            ? _controls(
                Theme.of(context).primaryColor, Theming.of(context).onPrimary(), sideListButton)
            : const SizedBox());
  }

  Widget sideListContent(Color text) {
    return ProgramsListView(
        onCatchupPressed: (CatchupInfo cat) {},
        programsBloc: programsBloc!,
        contentBloc: widget.bloc,
        textColor: text);
  }

  Widget _controls(Color? back, Color text, Widget sideListButton) {
    return BottomControls(
        programsBloc: programsBloc!,
        buttons: <Widget>[
          PlayerButtons.previous(onPressed: _moveToPrevChannel, color: text),
          createPlayPauseButton(text),
          PlayerButtons.next(onPressed: _moveToNextChannel, color: text),
          sideListButton
        ],
        textColor: text,
        backgroundColor: back);
  }

  void _moveToPrevChannel() {
    currentPos == 0 ? currentPos = widget.package.streams.length - 1 : currentPos--;

    _playChannel();
    _initProgramsBloc(currentPos);
  }

  void _moveToNextChannel() {
    currentPos == widget.package.streams.length - 1 ? currentPos = 0 : currentPos++;

    _playChannel();
    _initProgramsBloc(currentPos);
  }

  void _initProgramsBloc(int position) {
    setState(() {
      programsBloc?.dispose();
      programsBloc = ProgramsBloc(LiveStream(widget.package.streams[position]));
    });
  }

  void _playChannel() {
    if (castConnected) {
      final prim = _currentChannel.primaryUrl();
      ChromeCastInfo().initVideo(prim.url, AppLocalizations.toUtf8(_currentChannel.displayName()));
    } else {
      _controller.playStream(_currentChannel);
    }
    setState(() {});
  }

  @override
  void initChromeCastPlayer() {
    _controller = LivePlayerController(_currentChannel, client: widget.listener);
  }
}
