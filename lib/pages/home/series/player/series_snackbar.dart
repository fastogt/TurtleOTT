import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';
import 'package:player/controllers/standart_controller.dart';
import 'package:turtleott/base/channels/episode_stream.dart';
import 'package:turtleott/base/streams_grid/grid.dart';
import 'package:turtleott/pages/home/vods/player/vod_snackbar.dart';
import 'package:turtleott/pages/home/vods/player/vod_time.dart';
import 'package:turtleott/pages/home/vods/player/vod_timeline.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/player/player.dart';
import 'package:turtleott/player/snackbar.dart';

class SeriesPlayerSnackbar extends PlayerSnackbar {
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final int init;
  final List<EpisodeStream> streams;

  const SeriesPlayerSnackbar(
      VodPlayerController controller, this.onPrev, this.onNext, this.init, this.streams)
      : super(controller);

  @override
  SeriesPlayerSnackbarState createState() => SeriesPlayerSnackbarState();
}

class SeriesPlayerSnackbarState extends PlayerSnackbarState<SeriesPlayerSnackbar> {
  late final FocusNode _timelineNode = FocusNode();
  late int current;

  @override
  void initState() {
    current = widget.init;
    //widget.controller.baseController!.addListener(_update);
    super.initState();
  }

  @override
  void dispose() {
    //widget.controller.baseController!.removeListener(_update);
    _timelineNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomLeft, children: [
      super.build(context),
      SizedBox(
          width: 274,
          child: Padding(
              padding: const EdgeInsets.only(
                  left: TvStreamsGrid.sidePadding,
                  right: TvStreamsGrid.sidePadding,
                  bottom: PlayerSnackbarState.posterBottomSpacing),
              child: Image.network(widget.controller.icon())))
    ]);
  }

  @override
  String get title => widget.controller.displayName();

  @override
  Widget icon() => const SizedBox();

  @override
  Widget time() {
    return VodPlayerTime(widget.controller as IStandartPlayerController);
  }

  @override
  Widget timeline() {
    return VodPlayerTimeline(widget.controller as IStandartPlayerController);
  }

  @override
  List<Widget> buttons() {
    return [
      PlayerButton(
          icon: Icons.skip_previous,
          onKey: (event) {
            return onKey(event, (keyCode) {
              switch (keyCode) {
                case KeyConstants.ENTER:
                case KeyConstants.KEY_CENTER:
                case KeyConstants.PAUSE:
                  if (Player.of(context)!.isSnackbarVisible()) {
                    widget.onPrev();
                    _updateListener();
                  }
                  setState(() {});
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
                case KeyConstants.KEY_RIGHT:
                  if (Player.of(context)!.isSnackbarVisible()) {
                    return FocusScope.of(context).focusInDirection(TraversalDirection.right)
                        ? KeyEventResult.handled
                        : KeyEventResult.ignored;
                  }
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
                case KeyConstants.KEY_LEFT:
                  if (Player.of(context)!.isSnackbarVisible()) {
                    return FocusScope.of(context).focusInDirection(TraversalDirection.left)
                        ? KeyEventResult.handled
                        : KeyEventResult.ignored;
                  }
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
                case KeyConstants.KEY_UP:
                  if (Player.of(context)!.isSnackbarVisible()) {
                    return FocusScope.of(context).focusInDirection(TraversalDirection.up)
                        ? KeyEventResult.handled
                        : KeyEventResult.ignored;
                  }
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
                case KeyConstants.KEY_DOWN:
                  if (Player.of(context)!.isSnackbarVisible()) {
                    return FocusScope.of(context).focusInDirection(TraversalDirection.down)
                        ? KeyEventResult.handled
                        : KeyEventResult.ignored;
                  }
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
              }
              return PlayerSnackbar.of(context)!.onKeys(keyCode);
            });
          }),
      PlayerSeekButton.backward(widget.controller),
      PlayPauseButton(widget.controller),
      PlayerSeekButton.forward(widget.controller),
      PlayerButton(
          icon: Icons.skip_next,
          onKey: (event) {
            return onKey(event, (keyCode) {
              switch (keyCode) {
                case KeyConstants.ENTER:
                case KeyConstants.KEY_CENTER:
                case KeyConstants.PAUSE:
                  if (Player.of(context)!.isSnackbarVisible()) {
                    widget.onNext();
                    _updateListener();
                    current++;
                  }
                  setState(() {});
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
                case KeyConstants.KEY_LEFT:
                  if (Player.of(context)!.isSnackbarVisible()) {
                    return FocusScope.of(context).focusInDirection(TraversalDirection.left)
                        ? KeyEventResult.handled
                        : KeyEventResult.ignored;
                  }
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
                case KeyConstants.KEY_RIGHT:
                  if (Player.of(context)!.isSnackbarVisible()) {
                    return FocusScope.of(context).focusInDirection(TraversalDirection.right)
                        ? KeyEventResult.handled
                        : KeyEventResult.ignored;
                  }
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
                case KeyConstants.KEY_UP:
                  if (Player.of(context)!.isSnackbarVisible()) {
                    return FocusScope.of(context).focusInDirection(TraversalDirection.up)
                        ? KeyEventResult.handled
                        : KeyEventResult.ignored;
                  }
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
                case KeyConstants.KEY_DOWN:
                  if (Player.of(context)!.isSnackbarVisible()) {
                    return FocusScope.of(context).focusInDirection(TraversalDirection.down)
                        ? KeyEventResult.handled
                        : KeyEventResult.ignored;
                  }
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
              }
              return PlayerSnackbar.of(context)!.onKeys(keyCode);
            });
          })
    ];
  }

  void _updateListener() {
    //widget.controller.baseController!.removeListener(_update);
    //widget.controller.baseController!.addListener(_update);
  }
}
