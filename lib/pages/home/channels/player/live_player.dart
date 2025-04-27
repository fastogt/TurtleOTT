import 'package:flutter/material.dart';
import 'package:player/common/controller.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/live_stream.dart';
import 'package:turtleott/base/streams/program_bloc.dart';
import 'package:turtleott/pages/home/channels/player/live_snackbar.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/player/player.dart';

class LivePlayer extends Player {
  final List<LiveStream> streams;
  final int init;
  final ContentBloc bloc;

  LivePlayer(this.streams, this.init, this.bloc);

  @override
  _LivePlayerState createState() => _LivePlayerState();
}

class _LivePlayerState extends PlayerState<LivePlayerController, LivePlayer>
    implements IPlayerListener<LiveStream> {
  late int _current;
  late ProgramsBloc _programs;

  LiveStream get _currentStream => widget.streams[_current];

  @override
  void dispose() {
    _programs.dispose();
    super.dispose();
  }

  @override
  void onPlaying(IPlayerController cont, String url) {
    final live = cont as LivePlayerController;
    widget.bloc.add(PlayingLiveStreamEvent(live.currentStream));
  }

  @override
  void onPlayingError(IPlayerController cont, String url) {}

  @override
  void onEOS(IPlayerController cont, String url) {}

  @override
  void onSetInterrupt(IPlayerController cont, LiveStream stream, int msec) {
    widget.bloc.add(SetLiveStreamInterruptedEvent(stream, msec));
  }

  @override
  void initPlayer() {
    _current = widget.init;
    _programs = ProgramsBloc(widget.streams[_current]);
    controller = LivePlayerController(_currentStream, client: this);
  }

  @override
  Widget menu() {
    return LivePlayerSnackbar(controller, _programs, _playPrev, _playNext);
  }

  void _playNext() {
    if (_current == widget.streams.length - 1) {
      _current = 0;
    } else {
      _current++;
    }
    if (_currentStream.price != null) {
      _playNext();
    } else {
      _playChannel(_current);
    }
  }

  void _playPrev() {
    if (_current == 0) {
      _current = widget.streams.length - 1;
    } else {
      _current--;
    }
    if (_currentStream.price != null) {
      _playPrev();
    } else {
      _playChannel(_current);
    }
  }

  void _playChannel(int index) {
    setState(() {
      _current = index;
      _programs.dispose();
      _programs = ProgramsBloc(_currentStream);
      controller.playStream(_currentStream);
    });
  }
}
