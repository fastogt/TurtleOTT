import 'dart:core';

import 'package:dart_chromecast/chromecast.dart';
import 'package:dart_chromecast/widgets/connection_icon.dart';
import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/appbar_player.dart';
import 'package:flutter_fastotv_common/base/controls/custom_appbar.dart';
import 'package:flutter_fastotv_common/base/controls/fullscreen_button.dart';
import 'package:player/common/controller.dart';
import 'package:player/common/states.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/episode_stream.dart';
import 'package:turtleott/base/channels/istream.dart';
import 'package:turtleott/base/channels/vod_stream.dart';
// import 'package:turtleott/base/vod_stream.dart';
import 'package:turtleott/pages/home/vods/player/vod_time.dart';
import 'package:turtleott/pages/mobile/mobile_player.dart';
import 'package:turtleott/pages/mobile/series/episodes_list.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/theme.dart';

class EpisodePlayerPage extends StatefulWidget {
  final OttPackageInfo package;
  final List<VodInfo> episodes;
  final int initEpisode;
  final IPlayerListener listener;
  final ContentBloc bloc;
  final void Function()? onLast;

  const EpisodePlayerPage(
      {required this.package,
      required this.episodes,
      required this.initEpisode,
      required this.listener,
      required this.bloc,
      this.onLast});

  @override
  _EpisodePlayerPageState createState() {
    return _EpisodePlayerPageState();
  }
}

class _EpisodePlayerPageState<T extends EpisodeStream>
    extends PlayerPageMobileState<EpisodePlayerPage> implements IPlayerListener {
  late EpisodePlayerController _controller;

  @override
  VodStream get stream => _currentChannel;

  @override
  EpisodePlayerController get controller => _controller;

  late int currentEpisode;

  EpisodeStream get _currentChannel => _episodes[currentEpisode];

  List<EpisodeStream> get _episodes {
    final List<EpisodeStream> series = <EpisodeStream>[];
    for (final VodInfo e in widget.episodes) {
      series.add(EpisodeStream(e));
    }
    return series;
  }

  @override
  void initState() {
    currentEpisode = widget.initEpisode;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LocalStorageService settings = locator<LocalStorageService>();
    return MobileAppBarPlayer.sideList(
      appbar: (Color? background, Color text) => appBar(),
      child: playerArea(_currentChannel.icon()),
      bottomControls: bottomControls,
      sideList: sideListContent,
      bottomControlsHeight: VOD_BOTTOM_CONTROL_HEIGHT * 1.2,
      onDoubleTap: !initialized
          ? null
          : isPlaying()
              ? pause
              : play,
      onLongTapLeft: !initialized ? null : onLongTapLeft,
      onLongTapRight: !initialized ? null : onLongTapRight,
      onPrimaryColor: Theming.of(context).onPrimary,
      absoluteBrightness: settings.brightnessChange(),
      absoluteSound: settings.soundChange(),
    );
  }

  Widget appBar() {
    return ChannelPageAppBar(
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Theming.of(context).onPrimary(),
        title: AppLocalizations.toUtf8(_currentChannel.displayName()),
        onExit: () {
          Navigator.of(context).pop();
        },
        actions: <Widget>[
          const ChromeCastIcon(),
          if (isPortrait(context))
            const FullscreenButton.open()
          else
            const FullscreenButton.close(),
        ]);
  }

  Widget bottomControls(Color? back, Color text, Widget sideListButton) {
    return Container(
        color: Theme.of(context).primaryColor,
        width: MediaQuery.of(context).size.width,
        height: VOD_BOTTOM_CONTROL_HEIGHT + MediaQuery.of(context).padding.top + 32,
        child: initialized
            ? Column(children: [
                _time(),
                Stack(children: <Widget>[
                  Align(alignment: Alignment.topCenter, child: timeLine()),
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _controls(Theme.of(context).primaryColor,
                          Theming.of(context).onPrimary(), sideListButton))
                ])
              ])
            : const SizedBox());
  }

  Widget sideListContent(Color text) {
    return EpisodesList(
        episodes: const <EpisodeStream>[],
        textColor: Theming.of(context).onPrimary(),
        index: currentEpisode,
        callBack: (int index) {
          currentEpisode = index;
          _playChannel();
        });
  }

  Widget _controls(Color? back, Color text, Widget sideListButton) {
    if (castConnected) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[createPlayPauseButton(text)]);
    }

    return PlayerStateBuilder(controller, builder: (BuildContext context, IPlayerState? state) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        PlayerButtons.previous(onPressed: _moveToPrevChannel, color: text),
        PlayerButtons.seekBackward(onPressed: controller.seekBackward, color: text),
        createPlayPauseButton(text, _autoNext),
        PlayerButtons.seekForward(onPressed: controller.seekForward, color: text),
        PlayerButtons.next(onPressed: _moveToNextChannel, color: text),
        sideListButton
      ]);
    });
  }

  void _moveToPrevChannel() {
    currentEpisode == 0 ? currentEpisode = _episodes.length - 1 : currentEpisode--;
    _playChannel();
  }

  void _moveToNextChannel() {
    currentEpisode == _episodes.length - 1 ? currentEpisode = 0 : currentEpisode++;
    _playChannel();
  }

  void _playChannel() {
    final EpisodeStream cur = _currentChannel;
    final PlayingUrl prim = _currentChannel.primaryUrl();
    ChromeCastInfo().castConnected
        ? ChromeCastInfo().initVideo(prim.url, AppLocalizations.toUtf8(cur.displayName()))
        : controller.playStream(cur);
    setState(() {});
  }

  @override
  void initChromeCastPlayer() {
    _controller = EpisodePlayerController(_currentChannel, client: this);
  }

  Widget _time() {
    return VodPlayerTime(_controller);
  }

  @override
  void onPlaying(IPlayerController cont, String url) {
    final vod = cont as VodPlayerController;
    final stream = vod.currentStream;
    if (T is VodStream) {
      widget.bloc.add(PlayingVodEvent(stream));
    } else {
      widget.bloc.add(PlayingEpisodeEvent(stream as EpisodeStream));
    }
  }

  @override
  void onPlayingError(IPlayerController cont, String url) {}

  @override
  void onEOS(IPlayerController cont, String url) {
    _autoNext();
  }

  void _autoNext() {
    if (currentEpisode == widget.episodes.length - 1) {
      widget.onLast?.call();
    } else {
      _moveToNextChannel();
    }
  }

  @override
  void onSetInterrupt(IPlayerController cont, IStream stream, int msec) {
    if (T is VodStream) {
      widget.bloc.add(SetVodInterruptedEvent(stream as VodStream, msec, msec));
    } else {
      widget.bloc.add(SetEpisodeInterruptedEvent(stream as EpisodeStream, msec));
    }
  }
}
