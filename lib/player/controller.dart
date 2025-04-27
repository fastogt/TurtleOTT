import 'package:player/common/controller.dart';
import 'package:player/controllers/standart_controller.dart';
import 'package:player/player.dart';

import 'package:turtleott/base/channels/episode_stream.dart';
import 'package:turtleott/base/channels/istream.dart';
import 'package:turtleott/base/channels/live_stream.dart';
import 'package:turtleott/base/channels/vod_stream.dart';
import 'package:turtleott/player/mobile_bottom_controls.dart';

const VOD_BOTTOM_CONTROL_HEIGHT = 20 + BUTTONS_LINE_HEIGHT + TIMELINE_HEIGHT;

mixin DisplayMixin {
  String displayName();

  String icon();
}

class StandartPlayerController extends IStandartPlayerController {
  final String? _link;

  StandartPlayerController(String? link, IPlayerLinkObserver? linkObserver)
      : _link = link,
        super(linkObserver: linkObserver);

  @override
  String? get currentLink {
    return _link;
  }
}

abstract class IPlayerControllerRes extends IStandartPlayerController with DisplayMixin {
  IPlayerControllerRes(IPlayerLinkObserver? linkObserver) : super(linkObserver: linkObserver);

  @override
  String displayName();

  @override
  String icon();
}

class BasePlayerController<T extends IStream> extends IPlayerControllerRes {
  int _currentUrl = 0;
  T _stream;

  T get currentStream {
    return _stream;
  }

  @override
  String get currentLink {
    return currentStream.urls[_currentUrl].url;
  }

  BasePlayerController(this._stream, IPlayerLinkObserver? linkObserver) : super(linkObserver);

  @override
  String displayName() {
    return currentStream.displayName();
  }

  @override
  String icon() {
    return currentStream.icon();
  }

  bool favorite() {
    return currentStream.favorite();
  }

  void playStream(T stream) {
    _currentUrl = 0;
    _stream = stream;
    setUrl(currentLink, null);
  }
}

abstract class IPlayerListener<T extends IStream> extends IPlayerLinkObserver {
  @override
  void onPlaying(IPlayerController cont, String url);

  @override
  void onPlayingError(IPlayerController cont, String url);

  @override
  void onEOS(IPlayerController cont, String url);

  void onSetInterrupt(IPlayerController cont, T stream, int msec);
}

class LivePlayerController extends BasePlayerController<LiveStream> {
  LivePlayerController(LiveStream stream, {required IPlayerListener<LiveStream>? client})
      : super(stream, client);
}

class VodPlayerController<T extends VodStream> extends BasePlayerController<T> {
  VodPlayerController(T stream, {required IPlayerListener? client}) : super(stream, client);

  void moveToInterruptTime() {
    seekTo(Duration(milliseconds: _stream.interruptTime()));
  }

  void setInterruptTime(int interruptTime) {
    _stream.setInterruptTime(interruptTime);
    if (linkObserver != null) {
      (linkObserver as IPlayerListener).onSetInterrupt(this, _stream, interruptTime);
    }
  }
}

class EpisodePlayerController extends VodPlayerController<EpisodeStream> {
  EpisodePlayerController(EpisodeStream stream, {required IPlayerListener? client})
      : super(stream, client: client);
}

class VodTrailerController extends IPlayerControllerRes {
  final String _link;
  final String _name;
  final String _icon;

  @override
  String get currentLink {
    return _link;
  }

  VodTrailerController(String url, this._name, this._icon)
      : _link = url,
        super(null);

  @override
  String displayName() {
    return _name;
  }

  @override
  String icon() {
    return _icon;
  }
}
