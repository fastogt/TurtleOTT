import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:turtleott/base/channels/episode_stream.dart';
import 'package:turtleott/base/channels/live_stream.dart';
import 'package:turtleott/base/channels/series_stream.dart';
import 'package:turtleott/base/channels/vod_stream.dart';
import 'package:turtleott/pages/profile.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';

part 'content_event.dart';
part 'content_state.dart';

class ContentBloc extends Bloc<ContentEvent, ContentState> {
  Profile profile;

  ContentBloc({required this.profile}) : super(ContentStatedState()) {
    on<SetVodFavoriteEvent>(_setFavoriteVod);
    on<SetSerialFavoriteEvent>(_onSetSerialFavorite);
    on<SetLiveStreamFavoriteEvent>(_onSetLiveStreamFavorite);
    // interrupted
    on<SetVodInterruptedEvent>(_setInterruptedVod);
    on<SetEpisodeInterruptedEvent>(_onSetEpisodeInterrupted);

    // play
    on<PlayingLiveStreamEvent>(_onPlayingLiveStream);
    on<PlayingVodEvent>(_onPlayingVod);
    on<PlayingEpisodeEvent>(_onPlayingEpisode);
  }

  //Play
  void _onPlayingLiveStream(PlayingLiveStreamEvent event, Emitter<ContentState> emit) {
    final LiveStream live = event.live;
    final res = profile.playingLiveStreamWithToken(live.pid(), live.id());
    res.then((bool success) {
      if (success) {
        final settings = locator<LocalStorageService>();
        final isSaved = settings.saveLastViewed();
        if (isSaved) {
          settings.setLastPackage(live.pid());
          settings.setLastChannel(live.id());
        }
      }
    });
  }

  void _onPlayingVod(PlayingVodEvent event, Emitter<ContentState> emit) {
    final VodStream vod = event.vod;
    final res = profile.playingVodWithToken(vod.pid(), vod.id());
    res.then((bool success) {
      if (success) {}
    });
  }

  void _onPlayingEpisode(PlayingEpisodeEvent event, Emitter<ContentState> emit) {
    final EpisodeStream episode = event.episode;
    final res = profile.playingEpisodeWithToken(episode.pid(), episode.id());
    res.then((bool success) {
      if (success) {}
    });
  }

  // Interrupted
  void _setInterruptedVod(SetVodInterruptedEvent event, Emitter<ContentState> emit) async {
    emit(LoadContentState());
    final VodStream vod = event.vod;
    profile.interruptVod(vod.pid(), vod.id(), event.msec); // check result
    // update content
    vod.setInterruptTime(event.msec);
    emit(SetContentSuccessState());
  }

  void _onSetEpisodeInterrupted(SetEpisodeInterruptedEvent event, Emitter<ContentState> emit) {
    final EpisodeStream epi = event.epi;
    final res = profile.setInterruptEpisode(epi.pid(), epi.id(), event.msec);
    res.then((bool success) {
      if (success) {
        epi.setInterruptTime(event.msec);
      }
    });
  }

  //Favourite
  void _setFavoriteVod(SetVodFavoriteEvent event, Emitter<ContentState> emit) async {
    final vod = event.vod;
    if (vod.pid() == null) {
      return;
    }

    emit(LoadContentState());
    final res = profile.addFavoriteVod(vod.pid()!, vod.id(), event.state);
    res.then((bool success) {
      if (success) {
        vod.setFavorite(event.state);
      }
    });

    emit(SetContentSuccessState());
  }

  void _onSetSerialFavorite(SetSerialFavoriteEvent event, Emitter<ContentState> emit) {
    final serial = event.serial;
    if (serial.pid == null) {
      return;
    }

    final res = profile.addFavoriteSerial(serial.pid!, serial.id, event.state);
    res.then((bool success) {
      if (success) {
        serial.setFavorite(event.state);
      }
    });
  }

  void _onSetLiveStreamFavorite(SetLiveStreamFavoriteEvent event, Emitter<ContentState> emit) {
    final live = event.liveStream;
    if (live.pid() == null) {
      return;
    }

    final res = profile.addFavoriteLiveStream(live.pid()!, live.id(), event.state);
    res.then((bool success) {
      if (success) {
        live.setFavorite(event.state);
      }
    });
  }
}
