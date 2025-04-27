import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_common/widgets.dart';
import 'package:player/common/controller.dart';
import 'package:player/player.dart';
import 'package:turtleott/base/streams_grid/grid.dart';

abstract class Player extends StatefulWidget {
  static PlayerState? of(BuildContext context) {
    return context.findAncestorStateOfType<PlayerState>();
  }
}

abstract class PlayerState<P extends IPlayerController, S extends Player> extends State<S>
    with SingleTickerProviderStateMixin {
  static const int _timeout = 5;
  static const Duration _animationDuration = Duration(milliseconds: 500);
  late final AnimationController _animationController =
      AnimationController(duration: _animationDuration, vsync: this);
  late final Animation<Offset> _animation =
      Tween<Offset>(begin: const Offset(0.0, 0.0), end: const Offset(0.0, 1.1))
          .animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));

  late final P controller;

  bool get overlaysShown =>
      _animationController.status == AnimationStatus.dismissed ||
      _animationController.status == AnimationStatus.reverse;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    initPlayer();
    _timer = Timer(const Duration(seconds: _timeout), hideSnackbar);
  }

  @override
  void dispose() {
    controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(secondary: Theme.of(context).colorScheme.secondary)),
        child: Scaffold(body: Builder(builder: (context) {
          return SizedBox.fromSize(
              size: MediaQuery.of(context).size,
              child: Stack(alignment: Alignment.bottomCenter, children: [
                Positioned.fill(child: LitePlayer(controller: controller)),
                SlideTransition(position: _animation, child: menu()),
                Positioned(
                    top: TvStreamsGrid.sidePadding,
                    right: TvStreamsGrid.sidePadding,
                    child: AnimatedOpacity(
                        duration: _animationDuration,
                        opacity: overlaysShown ? 1 : 0,
                        child: const Clock.time(timeFontSize: 32)))
              ]));
        })));
  }

  Widget menu();

  void initPlayer();

  void toggleSnackbar() {
    if (_animationController.status == AnimationStatus.completed) {
      showSnackbar();
    } else {
      hideSnackbar();
    }
    setState(() {});
  }

  bool isSnackbarVisible() {
    return _animationController.status == AnimationStatus.dismissed;
  }

  void showSnackbar() {
    _animationController.fling(velocity: -1);
    _timer.cancel();
    _timer = Timer(const Duration(seconds: _timeout), hideSnackbar);
  }

  void hideSnackbar() {
    _animationController.fling();
    _timer.cancel();
  }
}
