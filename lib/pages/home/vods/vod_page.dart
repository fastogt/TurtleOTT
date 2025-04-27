import 'package:flutter/material.dart';
import 'package:flutter_common/src/localization/app_localizations.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/base/animated_text_button.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/vod_stream.dart';
import 'package:turtleott/base/description.dart';
import 'package:turtleott/base/round_button.dart';
import 'package:turtleott/base/streams_grid/grid.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/vods/player/vod_player.dart';

class VodPage extends StatelessWidget {
  final VodStream stream;
  final ContentBloc bloc;

  const VodPage(this.stream, this.bloc);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).size.height * 0.47;
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(child: _Background(stream.background())),
      Positioned.fill(top: topPadding, child: Container(color: Colors.white.withOpacity(0.9))),
      Padding(
          padding: EdgeInsets.all(TvStreamsGrid.BASE_PADDING.top),
          child: RoundedButton(icon: Icons.arrow_back, onTap: Navigator.of(context).pop)),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: TvStreamsGrid.BASE_PADDING.top),
          child: Row(children: [
            SizedBox(width: 150, child: Image.network(stream.icon(), fit: BoxFit.fill)),
            const SizedBox(width: 36),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.only(top: topPadding),
                    child: StreamDesription(
                        title: AppLocalizations.toUtf8(stream.displayName()),
                        description: stream.description(),
                        information: StreamInformation(
                            categories: stream.groups(),
                            other: [
                              DateTime.fromMillisecondsSinceEpoch(stream.primeDate())
                                  .year
                                  .toString(),
                              '${(stream.duration() / 60000).toStringAsFixed(0)} min',
                              'PG-${stream.iarc()}'
                            ],
                            score: stream.userScore()),
                        actions: [
                          _PlayButton(() {
                            openPlayer(context);
                          }),
                          if (stream.trailerUrl().isNotEmpty) ...[
                            const SizedBox(width: 16),
                            _PlayButton.trailer(() {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                return VodTrailerPlayer(stream);
                              }));
                            })
                          ],
                          const SizedBox(width: 16),
                          const Icon(Icons.preview, size: 24),
                          const SizedBox(width: 8),
                          Text('0 ${translate(context, TR_VIEWS)}',
                              style: const TextStyle(fontSize: 20)),
                        ])))
          ]))
    ]));
  }

  void openPlayer(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return VodPlayer(stream, bloc);
    }));
  }
}

class _PlayButton extends StatelessWidget {
  final bool _isTrailer;
  final VoidCallback onPressed;

  const _PlayButton(this.onPressed) : _isTrailer = false;

  const _PlayButton.trailer(this.onPressed) : _isTrailer = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedTextButton(
        icon: _isTrailer ? Icons.live_tv : Icons.play_circle,
        title: translate(context, _isTrailer ? TR_TRAILER : TR_PLAY),
        onPressed: onPressed);
  }
}

class _Background extends StatelessWidget {
  final String url;

  const _Background(this.url);

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.fill);
    } else {
      return Container(color: Theme.of(context).colorScheme.surface);
    }
  }
}
