import 'package:flutter/material.dart';
import 'package:flutter_common/localization.dart';
import 'package:flutter_common/utils.dart';
import 'package:player/player.dart';
import 'package:turtleott/base/streams_grid/grid.dart';
import 'package:turtleott/pages/home/vods/player/vod_time.dart';
import 'package:turtleott/pages/home/vods/player/vod_timeline.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/player/player.dart';
import 'package:turtleott/player/snackbar.dart';

class VodPlayerSnackbar extends PlayerSnackbar {
  final bool trailer;

  const VodPlayerSnackbar(VodPlayerController controller)
      : trailer = false,
        super(controller);

  const VodPlayerSnackbar.trailer(VodPlayerController controller)
      : trailer = true,
        super(controller);

  @override
  VodPlayerSnackbarState createState() {
    return VodPlayerSnackbarState();
  }
}

class VodPlayerSnackbarState extends PlayerSnackbarState<VodPlayerSnackbar> {
  late final FocusNode _timelineNode = FocusNode();

  @override
  void initState() {
    //widget.controller.baseController!.addListener(_update);
    super.initState();
  }

  @override
  void dispose() {
    //widget.controller.baseController!.removeListener(_update);
    _timelineNode.dispose();
    super.dispose();
  }

  /*void _update() {
    if (widget.controller.isEOS()) {
      widget.controller.seekTo(const Duration());
      Navigator.pop(context);
    }
    if (mounted) {
      setState(() {});
    }
  }*/

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
  String get title {
    String title = AppLocalizations.toUtf8(widget.controller.displayName());
    if (widget.trailer) {
      title = 'Trailer: $title';
    }
    return title;
  }

  @override
  Widget icon() {
    return const SizedBox();
  }

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
      PlayerSeekButton.backward(widget.controller),
      PlayPauseButton(widget.controller),
      PlayerSeekButton.forward(widget.controller)
    ];
  }
}

class PlayerSeekButton extends StatelessWidget {
  final IPlayerControllerRes controller;
  final bool isBackward;

  const PlayerSeekButton.backward(this.controller) : isBackward = true;

  const PlayerSeekButton.forward(this.controller) : isBackward = false;

  @override
  Widget build(BuildContext context) {
    return PlayerStateBuilder(controller, builder: (BuildContext context, IPlayerState? state) {
      if (isBackward) {
        return PlayerButton(
            icon: Icons.replay_5,
            onKey: (event) {
              return onKey(event, (keyCode) {
                switch (keyCode) {
                  case KeyConstants.ENTER:
                  case KeyConstants.KEY_CENTER:
                    if (Player.of(context)!.isSnackbarVisible()) {
                      controller.seekBackward();
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
                }
                return PlayerSnackbar.of(context)!.onKeys(keyCode);
              });
            });
      }
      return PlayerButton(
          icon: Icons.forward_5,
          onKey: (event) {
            return onKey(event, (keyCode) {
              switch (keyCode) {
                case KeyConstants.ENTER:
                case KeyConstants.KEY_CENTER:
                  if (Player.of(context)!.isSnackbarVisible()) {
                    controller.seekForward();
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
              }
              return PlayerSnackbar.of(context)!.onKeys(keyCode);
            });
          });
    });
  }
}
