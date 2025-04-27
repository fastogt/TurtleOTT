import 'package:dart_chromecast/chromecast.dart';
import 'package:dart_chromecast/widgets/connection_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/appbar_player.dart';
import 'package:flutter_fastotv_common/base/controls/fullscreen_button.dart';
import 'package:flutter_fastotv_common/chromecast_filler.dart';
import 'package:player/player.dart';
import 'package:turtleott/pages/home/vods/player/vod_time.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/theme.dart';

class VodTrailer extends StatefulWidget {
  final String title;
  final String link;
  final String imageLink;

  const VodTrailer(this.title, this.link, this.imageLink);

  @override
  VodTrailerPageMobileState createState() {
    return VodTrailerPageMobileState();
  }
}

class VodTrailerPageMobileState extends State<VodTrailer> {
  late IPlayerControllerRes _controller;

  bool get _castConnected => ChromeCastInfo().castConnected;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = locator<LocalStorageService>();
    return MobileAppBarPlayer(
        appbar: (background, text) => appBar(),
        child: playerArea(),
        bottomControls: (background, text, __) => bottomControls(),
        bottomControlsHeight: VOD_BOTTOM_CONTROL_HEIGHT,
        onDoubleTap: () {
          if (!_paused) {
            pause();
          } else {
            play();
          }
        },
        onLongTapLeft: onLongTapLeft,
        onLongTapRight: onLongTapRight,
        absoluteBrightness: settings.brightnessChange(),
        absoluteSound: settings.soundChange(),
        onPrimaryColor: Theming.of(context).onPrimary);
  }

  bool isPlaying() {
    if (_castConnected) {
      return ChromeCastInfo().isPlaying();
    }
    return _controller.isPlaying();
  }

  void play() {
    if (_castConnected) {
      ChromeCastInfo().play();
    } else {
      _controller.play();
    }
    setState(() {
      _paused = false;
    });
  }

  void pause() {
    if (_castConnected) {
      ChromeCastInfo().pause();
    } else {
      _controller.pause();
    }
    setState(() {
      _paused = true;
    });
  }

  void onLongTapLeft() {
    if (!_castConnected) {
      _controller.seekBackward();
    }
  }

  void onLongTapRight() {
    if (!_castConnected) {
      _controller.seekForward();
    }
  }

  Widget appBar() {
    return ChannelPageAppBar(
        title: widget.title,
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Theming.of(context).onPrimary(),
        actions: [
          ChromeCastIcon(onChromeCast: _chromeCastCallback),
          if (isPortrait(context))
            const FullscreenButton.open()
          else
            const FullscreenButton.close(),
        ]);
  }

  Widget bottomControls() {
    return Container(
        color: Theme.of(context).primaryColor,
        width: MediaQuery.of(context).size.width,
        height: VOD_BOTTOM_CONTROL_HEIGHT + MediaQuery.of(context).padding.top + 16,
        child: Column(children: [
          _time(),
          Stack(children: <Widget>[
            Align(alignment: Alignment.topCenter, child: _timeLine()),
            Padding(padding: const EdgeInsets.all(16.0), child: _controls())
          ])
        ]));
  }

  Widget _time() {
    return VodPlayerTime(_controller as IStandartPlayerController);
  }

  Widget playerArea() {
    return ChromeCastInfo().castConnected
        ? _chromeCastFiller()
        : LitePlayer(controller: _controller);
  }

  Widget _controls() {
    return PlayerStateBuilder(_controller, builder: (BuildContext context, IPlayerState? state) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        if (!_castConnected)
          PlayerButtons.seekBackward(
              onPressed: _controller.seekBackward, color: Theming.of(context).onPrimary()),
        const SizedBox(width: 16),
        createPlayPauseButton(),
        const SizedBox(width: 16),
        if (!_castConnected)
          PlayerButtons.seekForward(
              onPressed: _controller.seekForward, color: Theming.of(context).onPrimary())
      ]);
    });
  }

  Widget createPlayPauseButton() {
    if (!_paused) {
      return PlayerButtons.pause(onPressed: pause, color: Theming.of(context).onPrimary());
    }
    return PlayerButtons.play(onPressed: play, color: Theming.of(context).onPrimary());
  }

  Widget _timeLine() {
    if (ChromeCastInfo().castConnected) {
      return const SizedBox();
    }

    return LitePlayerTimeline(_controller as IStandartPlayerController);
  }

  Widget _chromeCastFiller() {
    return ChromeCastFiller.vod(widget.imageLink,
        size: Size.square(MediaQuery.of(context).size.height));
  }

  void _chromeCastCallback(bool connected) {
    if (connected) {
      _controller.dispose();
      ChromeCastInfo().initVideo(widget.link, widget.title);
    } else {
      _controller = VodTrailerController(widget.link, widget.title, widget.imageLink);
    }
    setState(() {});
  }

  void _initPlayer() {
    ChromeCastInfo().castConnected
        ? ChromeCastInfo().initVideo(widget.link, widget.title)
        : _controller = VodTrailerController(widget.link, widget.title, widget.imageLink);
  }
}

class ChannelPageAppBar extends StatelessWidget {
  final String title;
  final Color? backgroundColor;
  final Color? textColor;
  final List<Widget> actions;
  final void Function()? onExit;

  const ChannelPageAppBar(
      {required this.title,
      this.backgroundColor,
      this.textColor,
      this.actions = const [],
      this.onExit});

  @override
  Widget build(BuildContext context) {
    final Color? textColor = this.textColor ?? Theme.of(context).primaryTextTheme.bodySmall!.color;
    return AppBar(
        actionsIconTheme: IconThemeData(color: textColor),
        leading: IconButton(
            onPressed: () {
              if (onExit != null) {
                onExit!();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back),
            color: textColor),
        actions: actions,
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        title: Text(title, style: TextStyle(color: textColor)));
  }
}
