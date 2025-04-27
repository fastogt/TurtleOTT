import 'package:dart_chromecast/chromecast.dart';
import 'package:dart_chromecast/widgets/connection_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/appbar_player.dart';
import 'package:flutter_fastotv_common/base/controls/fullscreen_button.dart';
import 'package:player/common/states.dart';
import 'package:player/controllers/standart_controller.dart';
import 'package:turtleott/base/channels/vod_stream.dart';
import 'package:turtleott/pages/home/vods/player/vod_time.dart';
import 'package:turtleott/pages/mobile/mobile_player.dart';
import 'package:turtleott/pages/mobile/vods/vod_trailer_page.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/theme.dart';

class MobileVodPlayer extends StatefulWidget {
  final VodStream channel;
  final IPlayerListener listener;

  const MobileVodPlayer(this.channel, this.listener);

  @override
  _VodPlayerPageMobileState createState() {
    return _VodPlayerPageMobileState();
  }
}

class _VodPlayerPageMobileState extends PlayerPageMobileState<MobileVodPlayer> {
  late VodPlayerController _controller;

  @override
  VodStream get stream => widget.channel;

  @override
  VodPlayerController get controller => _controller;

  @override
  Widget build(BuildContext context) {
    final settings = locator<LocalStorageService>();
    final player = playerArea(widget.channel.icon());
    return MobileAppBarPlayer(
        appbar: (background, text) => appBar(),
        child: player,
        bottomControls: (background, text, __) => bottomControls(),
        bottomControlsHeight: VOD_BOTTOM_CONTROL_HEIGHT,
        onDoubleTap: !initialized
            ? null
            : isPlaying()
                ? pause
                : play,
        onLongTapLeft: !initialized ? null : onLongTapLeft,
        onLongTapRight: !initialized ? null : onLongTapRight,
        onPrimaryColor: Theming.of(context).onPrimary,
        absoluteBrightness: settings.brightnessChange(),
        absoluteSound: settings.soundChange());
  }

  Widget appBar() {
    return ChannelPageAppBar(
        title: AppLocalizations.toUtf8(widget.channel.displayName()),
        backgroundColor: Theme.of(context).primaryColor,
        textColor: Theming.of(context).onPrimary(),
        onExit: () {
          controller.setInterruptTime(position());
          Navigator.of(context).pop();
        },
        actions: [
          const ChromeCastIcon(),
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
        child: initialized
            ? Column(
                children: [
                  _time(),
                  Stack(children: <Widget>[
                    Align(alignment: Alignment.topCenter, child: timeLine()),
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _controls(Theming.of(context).onPrimary()))
                  ]),
                ],
              )
            : const SizedBox());
  }

  Widget _controls(Color color) {
    if (castConnected) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[createPlayPauseButton(color)]);
    } else {
      return PlayerStateBuilder(controller, builder: (BuildContext context, IPlayerState? state) {
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          PlayerButtons.seekBackward(onPressed: controller.seekBackward, color: color),
          const SizedBox(width: 16),
          createPlayPauseButton(color),
          const SizedBox(width: 16),
          PlayerButtons.seekForward(onPressed: controller.seekForward, color: color)
        ]);
      });
    }
  }

  int position() {
    if (ChromeCastInfo().castConnected) {
      return ChromeCastInfo().position()!.toInt();
    }
    return controller.position().inMilliseconds;
  }

  @override
  void initChromeCastPlayer() {
    _controller = VodPlayerController(widget.channel, client: widget.listener);
  }

  Widget _time() {
    return VodPlayerTime(_controller as IStandartPlayerController);
  }
}
