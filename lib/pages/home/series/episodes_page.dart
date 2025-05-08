import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/base/animated_card.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/episode_stream.dart';
import 'package:turtleott/base/channels/series_stream.dart';
import 'package:turtleott/base/round_button.dart';
import 'package:turtleott/base/streams_grid/grid.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/series/episode_page.dart';

class EpisodesPage extends StatelessWidget {
  final int number;
  final SerialSeason season;
  final String background;
  final ContentBloc bloc;

  const EpisodesPage(this.season, this.number, this.background, this.bloc);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).size.height * 0.47;
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(child: _Background(season.background)),
      Positioned.fill(child: Container(color: Colors.white.withOpacity(0.9))),
      Positioned(
          top: topPadding,
          left: 0,
          right: 0,
          child: const Divider(height: 0, thickness: 4, color: Colors.black45)),
      Padding(
          padding: EdgeInsets.all(TvStreamsGrid.BASE_PADDING.top),
          child: RoundedButton(icon: Icons.arrow_back, onTap: Navigator.of(context).pop)),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: TvStreamsGrid.BASE_PADDING.top),
          child: Row(children: [
            SizedBox(width: 128, child: Image.network(season.icon(), fit: BoxFit.fill)),
            const SizedBox(width: 36),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: topPadding - 50),
              Text('${translate(context, TR_SEASON)} ${number + 1}',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Text('${season.episodesId.length} ${translate(context, TR_EPISODES)}',
                  style: const TextStyle(fontSize: 20, color: Colors.black54)),
              const SizedBox(height: TvStreamsGrid.sidePadding / 4)
            ]))
          ])),
      Positioned(
          bottom: TvStreamsGrid.BASE_PADDING.top,
          left: 0,
          right: 0,
          child: _EpisodesRow(season, bloc))
    ]));
  }
}

class _EpisodesRow extends StatefulWidget {
  final SerialSeason season;
  final ContentBloc bloc;

  const _EpisodesRow(this.season, this.bloc);

  Future<List<VodInfo>?> future() {
    return bloc.profile.getSeasonEpisodes(season.pid, season.id);
  }

  @override
  State<_EpisodesRow> createState() {
    return _EpisodesRowState();
  }
}

class _EpisodesRowState extends State<_EpisodesRow> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.future(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<VodInfo> episodes = [];
          if (snapshot.data != null) {
            episodes = snapshot.data!;
          }

          return Padding(
              padding: EdgeInsets.symmetric(horizontal: TvStreamsGrid.BASE_PADDING.top),
              child: SizedBox(
                  height: 160,
                  child: ListView.separated(
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      scrollDirection: Axis.horizontal,
                      itemCount: episodes.length,
                      itemBuilder: (subContext, index) {
                        final VodInfo episode = episodes[index];
                        return AspectRatio(
                            aspectRatio: 0.52,
                            child: AnimatedCard(
                                imageFit: BoxFit.cover,
                                icon: episode.icon(),
                                title: AppLocalizations.toUtf8(episode.displayName()),
                                subtitle: Text('${translate(context, TR_EPISODE)} ${index + 1}'),
                                onTap: () {
                                  final List<EpisodeStream> epi = [];
                                  for (final e in episodes) {
                                    epi.add(EpisodeStream(e));
                                  }
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                    return EpisodePage(
                                        index, epi, widget.season.background, widget.bloc);
                                  }));
                                }));
                      })));
        });
  }
}

class _Background extends StatelessWidget {
  final String url;

  const _Background(this.url);

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.fill);
    }
    return Container(color: Theme.of(context).colorScheme.surface);
  }
}
