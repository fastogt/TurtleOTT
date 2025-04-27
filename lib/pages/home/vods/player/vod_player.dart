import 'package:flutter/material.dart';
import 'package:player/common/controller.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/vod_stream.dart';
import 'package:turtleott/pages/home/vods/player/vod_snackbar.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/player/player.dart';

class VodPlayer extends Player {
  final VodStream stream;
  final ContentBloc bloc;

  VodPlayer(this.stream, this.bloc);

  @override
  _VodPlayerState createState() {
    return _VodPlayerState();
  }
}

class _VodPlayerState extends PlayerState<VodPlayerController, VodPlayer>
    implements IPlayerListener<VodStream> {
  @override
  void initPlayer() {
    controller = VodPlayerController(widget.stream, client: this);
  }

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
  void dispose() {
    controller.setInterruptTime(controller.position().inMilliseconds);
    super.dispose();
  }

  @override
  Widget menu() {
    return VodPlayerSnackbar(controller);
  }
}

class VodTrailerPlayer extends Player {
  final VodStream stream;

  VodTrailerPlayer(this.stream);

  @override
  _VodTrailerPlayerState createState() {
    return _VodTrailerPlayerState();
  }
}

class _VodTrailerPlayerState extends PlayerState<VodPlayerController, VodTrailerPlayer> {
  @override
  void initPlayer() {
    controller = VodPlayerController(widget.stream, client: null);
  }

  @override
  Widget menu() {
    return VodPlayerSnackbar.trailer(controller);
  }
}
