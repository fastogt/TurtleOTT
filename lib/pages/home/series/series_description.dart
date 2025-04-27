import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/localization.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/base/animated_card.dart';
import 'package:turtleott/base/animated_text_button.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/series_stream.dart';
import 'package:turtleott/base/description.dart';
import 'package:turtleott/base/round_button.dart';
import 'package:turtleott/base/streams_grid/grid.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/series/episodes_page.dart';

final Color _overlayColor = Colors.white.withOpacity(0.9);

class SeriesDescription extends StatefulWidget {
  final SerialStream serial;
  final ContentBloc bloc;

  const SeriesDescription(this.serial, this.bloc);

  @override
  _SeriesDescriptionState createState() {
    return _SeriesDescriptionState();
  }
}

class _SeriesDescriptionState extends State<SeriesDescription> {
  final ScrollController _scrollController = ScrollController();
  final FocusScopeNode _seasonsScope = FocusScopeNode();

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<FocusedHeader>(
        onNotification: (notification) {
          _animate(notification.hasFocus ? 0 : _scrollController.position.maxScrollExtent);
          return true;
        },
        child: Scaffold(
            body: Stack(children: [
          Positioned.fill(child: _Background(widget.serial.background)),
          ListView(controller: _scrollController, children: [
            SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: _Description(widget.serial, () {
                  _seasonsScope.requestFocus();
                  _animate(_scrollController.position.maxScrollExtent);
                })),
            Container(
                color: _overlayColor,
                child: _SeasonsRow(
                    _seasonsScope, widget.serial.serial, widget.serial.background, widget.bloc))
          ])
        ])));
  }

  void _animate(double offset) {
    if (_scrollController.offset != offset) {
      _scrollController.animateTo(offset,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
    }
  }
}

class _Description extends StatelessWidget {
  final SerialStream serial;
  final VoidCallback openSeasons;

  const _Description(this.serial, this.openSeasons);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).size.height * 0.47;
    return Stack(children: [
      Positioned.fill(top: topPadding, child: Container(color: _overlayColor)),
      Padding(
          padding: EdgeInsets.all(TvStreamsGrid.BASE_PADDING.top),
          child: RoundedButton(
              autofocus: true, icon: Icons.arrow_back, onTap: Navigator.of(context).pop)),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: TvStreamsGrid.BASE_PADDING.top),
          child: Row(children: [
            SizedBox(width: 128, child: Image.network(serial.icon(), fit: BoxFit.fill)),
            const SizedBox(width: 36),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.only(top: topPadding),
                    child: StreamDesription(
                        title: AppLocalizations.toUtf8(serial.displayName()),
                        description: serial.description,
                        information: StreamInformation(categories: serial.groups),
                        actions: [
                          AnimatedTextButton(
                              icon: Icons.list,
                              title: translate(context, TR_SEASONS),
                              onPressed: openSeasons)
                        ])))
          ]))
    ]);
  }
}

class _SeasonsRow extends StatelessWidget {
  final FocusScopeNode seasonsScope;
  final SerialInfo serial;
  final String background;
  final ContentBloc bloc;

  Future<List<SeasonInfo>?> future() {
    return bloc.profile.getSerialSeasons(serial.pid, serial.id);
  }

  const _SeasonsRow(this.seasonsScope, this.serial, this.background, this.bloc);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<SeasonInfo> seasons = [];
          if (snapshot.data != null) {
            seasons = snapshot.data!;
          }

          return Padding(
              padding: TvStreamsGrid.BASE_PADDING,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Divider(),
                SizedBox(height: TvStreamsGrid.BASE_PADDING.top),
                Text(translate(context, TR_SEASONS),
                    style: Theme.of(context).textTheme.headlineSmall),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: FocusScope(
                        node: seasonsScope,
                        onFocusChange: (value) {
                          FocusedHeader(!value).dispatch(context);
                        },
                        child: SizedBox(
                            height: 256,
                            child: ListView.separated(
                                separatorBuilder: (_, __) => const SizedBox(width: 6),
                                scrollDirection: Axis.horizontal,
                                itemCount: seasons.length,
                                itemBuilder: (subContext, index) {
                                  final SerialSeason season = SerialSeason(seasons[index]);
                                  return AspectRatio(
                                      aspectRatio: 0.54,
                                      child: AnimatedCard(
                                          icon: season.icon(),
                                          title: '${translate(context, TR_SEASON)} ${index + 1}',
                                          subtitle: Text(
                                              '${season.episodesId.length} ${translate(context, TR_EPISODES)}'),
                                          onKey: (event) {
                                            final result = onKey(event, (key) {
                                              switch (key) {
                                                case KeyConstants.ENTER:
                                                case KeyConstants.KEY_CENTER:
                                                  Navigator.of(context)
                                                      .push(MaterialPageRoute(builder: (_) {
                                                    return EpisodesPage(
                                                        season, index, background, bloc);
                                                  }));
                                                  return KeyEventResult.handled;
                                                case KeyConstants.KEY_UP:
                                                  FocusScope.of(context)
                                                      .focusInDirection(TraversalDirection.up);
                                                  return KeyEventResult.handled;
                                                case KeyConstants.KEY_RIGHT:
                                                  FocusScope.of(subContext)
                                                      .focusInDirection(TraversalDirection.right);
                                                  return KeyEventResult.handled;
                                                case KeyConstants.KEY_LEFT:
                                                  FocusScope.of(subContext)
                                                      .focusInDirection(TraversalDirection.left);
                                                  return KeyEventResult.handled;
                                              }
                                              return KeyEventResult.ignored;
                                            });
                                            return result == KeyEventResult.handled;
                                          }));
                                }))))
              ]));
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
