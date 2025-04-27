import 'dart:async';

import 'package:dart_chromecast/chromecast.dart';
import 'package:fastotv_dart/commands_info/playing_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/chromecast_filler.dart';
import 'package:player/common/controller.dart';
import 'package:player/player.dart';
import 'package:turtleott/base/channels/istream.dart';

abstract class PlayerPageMobileState<T extends StatefulWidget> extends State<T> {
  final GlobalKey _playerKey = GlobalKey();

  IPlayerController get controller;

  IStream get stream;

  bool get castConnected => ChromeCastInfo().castConnected;
  late StreamSubscription<bool> _ccConnection;
  bool? _ccConnected;

  bool get initialized => _ccConnected != null;

  @override
  void initState() {
    super.initState();
    _ccConnection = ChromeCastInfo().castConnectedStream.listen((bool event) {
      if (event) {
        final PlayingUrl prim = stream.primaryUrl();
        _initChromeCast(prim.url, AppLocalizations.toUtf8(stream.displayName()));
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.dispose();
        });
      } else {
        initChromeCastPlayer();
      }
      if (mounted && _ccConnected != event) {
        setState(() {
          _ccConnected = event;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _ccConnection.cancel();
    controller.dispose();
    controller.baseController?.dispose();
  }

  bool isPlaying() {
    if (castConnected) {
      return ChromeCastInfo().isPlaying();
    }
    return controller.isPlaying();
  }

  void play() {
    if (castConnected) {
      ChromeCastInfo().play();
    } else {
      controller.play();
    }
    setState(() {});
  }

  void pause() {
    if (castConnected) {
      ChromeCastInfo().pause();
    } else {
      controller.pause();
    }
    setState(() {});
  }

  void onLongTapLeft() {
    if (!castConnected) {
      controller.seekBackward();
    }
  }

  void onLongTapRight() {
    if (!castConnected) {
      controller.seekForward();
    }
  }

  Widget playerArea(String icon) {
    if (!initialized) {
      return const AspectRatio(
          aspectRatio: 16 / 9, child: Center(child: CircularProgressIndicator()));
    }
    final bool cc = _ccConnected != null && _ccConnected == true;
    return cc
        ? AspectRatio(aspectRatio: 16 / 9, child: _chromeCastFiller(icon))
        : LitePlayer(key: _playerKey, controller: controller);
  }

  Widget createPlayPauseButton(Color color, [Function()? autoNext]) {
    final Padding placeholder = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.play_arrow, color: color.withOpacity(0.5)));
    if (!initialized) {
      return placeholder;
    } else if (castConnected) {
      return _playPause(color);
    }
    return PlayerStateBuilder(controller, builder: (BuildContext context, IPlayerState? state) {
      if (state is PlayingIPlayerState) {
        if (autoNext != null) {
          updateListener(autoNext);
        }
        return _playPause(color);
      }
      return placeholder;
    });
  }

  Widget _playPause(Color color) {
    if (isPlaying()) {
      return PlayerButtons.pause(onPressed: pause, color: color);
    }
    return PlayerButtons.play(onPressed: play, color: color);
  }

  void updateListener(Function() autoNext) {}

  Widget timeLine() {
    if (ChromeCastInfo().castConnected) {
      return const SizedBox();
    }
    return LitePlayerTimeline(controller as IStandartPlayerController);
  }

  Widget _chromeCastFiller(String icon) {
    return ChromeCastFiller.live(icon, size: Size.square(MediaQuery.of(context).size.height));
  }

  void initChromeCastPlayer();

  void _initChromeCast(String link, String name) {
    ChromeCastInfo().initVideo(link, name);
  }
}
