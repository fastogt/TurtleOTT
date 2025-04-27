part of 'content_bloc.dart';

abstract class ContentEvent extends Equatable {}

class ParseContent extends ContentEvent {
  @override
  List<Object?> get props => [];
}

class SetVodFavoriteEvent extends ContentEvent {
  final VodStream vod;
  final bool state;

  SetVodFavoriteEvent({required this.vod, required this.state});

  @override
  List<Object> get props => [vod, state];
}

class SetSerialFavoriteEvent extends ContentEvent {
  final SerialStream serial;
  final bool state;

  SetSerialFavoriteEvent({required this.serial, required this.state});

  @override
  List<Object> get props => [serial, state];
}

class SetLiveStreamFavoriteEvent extends ContentEvent {
  final LiveStream liveStream;
  final bool state;

  SetLiveStreamFavoriteEvent({required this.liveStream, required this.state});

  @override
  List<Object> get props => [liveStream, state];
}

class SetVodInterruptedEvent extends ContentEvent {
  final VodStream vod;
  final int duration;
  final int msec;

  SetVodInterruptedEvent(this.vod, this.msec, this.duration);

  @override
  List<Object?> get props => [vod, msec];
}

class SetEpisodeInterruptedEvent extends ContentEvent {
  final EpisodeStream epi;
  final int msec;

  SetEpisodeInterruptedEvent(this.epi, this.msec);

  @override
  List<Object?> get props => [];
}

class SetLiveStreamInterruptedEvent extends ContentEvent {
  final LiveStream live;
  final int msec;

  SetLiveStreamInterruptedEvent(this.live, this.msec);

  @override
  List<Object?> get props => [live, msec];
}

class PlayingLiveStreamEvent extends ContentEvent {
  final LiveStream live;

  PlayingLiveStreamEvent(this.live);

  @override
  List<Object?> get props => [live];
}

class PlayingVodEvent extends ContentEvent {
  final VodStream vod;

  PlayingVodEvent(this.vod);

  @override
  List<Object?> get props => [vod];
}

class PlayingEpisodeEvent extends ContentEvent {
  final EpisodeStream episode;

  PlayingEpisodeEvent(this.episode);

  @override
  List<Object?> get props => [episode];
}
