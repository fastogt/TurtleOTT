import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/base/channels/episode_stream.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/utils/theme.dart';

class EpisodesList extends StatefulWidget {
  final List<EpisodeStream> episodes;
  final int index;
  final double? itemHeight;
  final Color? activeColor;
  final Color textColor;
  final void Function(int) callBack;

  const EpisodesList(
      {required this.episodes,
      required this.index,
      this.itemHeight,
      this.activeColor,
      required this.textColor,
      required this.callBack});

  @override
  _EpisodesListState createState() {
    return _EpisodesListState();
  }
}

class _EpisodesListState extends State<EpisodesList> {
  static const double ITEM_HEIGHT = 56.0;

  late CustomScrollController _scrollController;
  late int _current;
  late double _itemHeight;

  @override
  void initState() {
    super.initState();
    _itemHeight = widget.itemHeight ?? ITEM_HEIGHT;
    _current = widget.index;
    _scrollController =
        CustomScrollController(itemHeight: _itemHeight, initOffset: _itemHeight * _current);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.episodes.isEmpty) {
      return NonAvailableBuffer(
          message: translate(context, TR_NO_DESCRIPTION),
          color: Theming.of(context).onBrightness());
    }
    return ListView.builder(
        itemCount: widget.episodes.length,
        controller: _scrollController.controller,
        itemBuilder: (BuildContext context, int index) {
          final EpisodeStream episode = widget.episodes[index];
          final bool isPlaying = index == widget.index;
          final double elevation = isPlaying ? 1.0 : 0.0;
          final Color currentColor = isPlaying ? activeColor() : Colors.transparent;
          return Opacity(
              opacity: index >= widget.index ? 1.0 : 0.4,
              child: Material(
                  elevation: elevation,
                  color: Colors.transparent,
                  child: Container(
                      height: _itemHeight,
                      decoration: BoxDecoration(border: Border.all(color: currentColor, width: 2)),
                      child: _EpisodeListTile(
                          episode: episode,
                          index: index,
                          playing: isPlaying,
                          selectedColor: widget.activeColor,
                          callBack: () => widget.callBack(index)))));
        });
  }

  Color activeColor() => widget.activeColor ?? Theme.of(context).colorScheme.secondary;
}

class _EpisodeListTile extends StatefulWidget {
  final int index;
  final EpisodeStream episode;
  final bool playing;
  final Color? selectedColor;
  final void Function() callBack;

  const _EpisodeListTile(
      {required this.episode,
      required this.index,
      required this.playing,
      this.selectedColor,
      required this.callBack});

  @override
  _EpisodeListTileState createState() => _EpisodeListTileState();
}

class _EpisodeListTileState extends State<_EpisodeListTile> {
  bool get _playing => widget.playing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        dense: true,
        leading: Text(
          (widget.index + 1).toString(),
          style: TextStyle(color: Theming.of(context).onPrimary()),
        ),
        onTap: () => widget.callBack(),
        title: Text(AppLocalizations.toUtf8(widget.episode.displayName()),
            style: TextStyle(fontSize: 16, color: Theming.of(context).onPrimary()),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false),
        trailing: _trailing());
  }

  Widget _trailing() {
    if (_playing) {
      return Icon(Icons.play_arrow, color: Theming.of(context).onPrimary());
    }

    return const SizedBox();
  }
}
