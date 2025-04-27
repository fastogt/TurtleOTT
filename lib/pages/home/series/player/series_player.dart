import 'package:flutter/material.dart';
import 'package:player/common/controller.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/episode_stream.dart';
import 'package:turtleott/pages/home/series/player/series_snackbar.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/player/player.dart';

class SeriesPlayer extends Player {
  final int init;
  final List<EpisodeStream> streams;
  final String background;
  final ContentBloc bloc;

  SeriesPlayer(this.init, this.streams, this.background, this.bloc);

  @override
  _SeriesPlayerState createState() {
    return _SeriesPlayerState();
  }
}

class _SeriesPlayerState extends PlayerState<VodPlayerController, SeriesPlayer>
    implements IPlayerListener<EpisodeStream> {
  late int current;

  @override
  void onPlaying(IPlayerController cont, String url) {
    final epi = cont as EpisodePlayerController;
    widget.bloc.add(PlayingEpisodeEvent(epi.currentStream));
  }

  @override
  void onPlayingError(IPlayerController cont, String url) {}

  @override
  void onEOS(IPlayerController cont, String url) {}

  @override
  void onSetInterrupt(IPlayerController cont, EpisodeStream episode, int msec) {
    widget.bloc.add(SetEpisodeInterruptedEvent(episode, msec));
  }

  @override
  void initPlayer() {
    current = widget.init;
    controller = VodPlayerController(widget.streams[widget.init], client: this);
  }

  @override
  void dispose() {
    controller.setInterruptTime(controller.position().inMilliseconds);
    super.dispose();
  }

  @override
  Widget menu() => SeriesPlayerSnackbar(controller, _prev, _next, current, widget.streams);

  void _prev() {
    if (current == 0) {
      current = widget.streams.length - 1;
    } else {
      current--;
    }
    _play(current);
  }

  void _next() {
    if (current == widget.streams.length - 1) {
      current = 0;
    } else {
      current++;
    }
    _play(current);
  }

  void _play(int index) {
    controller.playStream(widget.streams[current]);
  }
}
