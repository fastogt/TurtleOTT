import 'package:flutter/material.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/episode_stream.dart';
import 'package:turtleott/pages/home/series/player/series_player.dart';
import 'package:turtleott/pages/home/vods/vod_page.dart';

class EpisodePage extends VodPage {
  final int init;
  final List<EpisodeStream> episodes;
  final String background;

  EpisodePage(this.init, this.episodes, this.background, ContentBloc bloc)
      : super(episodes[init], bloc);

  @override
  void openPlayer(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return SeriesPlayer(init, episodes, background, bloc);
    }));
  }
}
