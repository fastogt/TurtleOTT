import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';
import 'package:player/player.dart';
import 'package:turtleott/base/streams/program_bloc.dart';
import 'package:turtleott/pages/home/channels/player/live_time.dart';
import 'package:turtleott/pages/home/channels/player/live_timeline.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/player/player.dart';
import 'package:turtleott/player/snackbar.dart';

class LivePlayerSnackbar extends PlayerSnackbar {
  final ProgramsBloc programs;
  final VoidCallback prevChannel;
  final VoidCallback nextChannel;

  const LivePlayerSnackbar(
      LivePlayerController controller, this.programs, this.prevChannel, this.nextChannel)
      : super(controller);

  @override
  _LivePlayerSnackbarState createState() {
    return _LivePlayerSnackbarState();
  }
}

class _LivePlayerSnackbarState extends PlayerSnackbarState<LivePlayerSnackbar> {
  @override
  Widget icon() {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white),
            padding: const EdgeInsets.all(20),
            child: Image.network(widget.controller.icon())));
  }

  @override
  Widget time() {
    return LivePlayerTime(widget.programs);
  }

  @override
  Widget timeline() {
    return LivePlayerTimeline(widget.programs);
  }

  @override
  List<Widget> buttons() {
    return [
      _PlayerChannelButton.prev(widget.controller, widget.prevChannel),
      PlayPauseButton(widget.controller),
      _PlayerChannelButton.next(widget.controller, widget.nextChannel)
    ];
  }
}

class _PlayerChannelButton extends StatelessWidget {
  final IPlayerControllerRes controller;
  final VoidCallback onTap;
  final bool isPrev;

  const _PlayerChannelButton.prev(this.controller, this.onTap) : isPrev = true;

  const _PlayerChannelButton.next(this.controller, this.onTap) : isPrev = false;

  @override
  Widget build(BuildContext context) {
    return PlayerStateBuilder(controller, builder: (BuildContext context, IPlayerState? state) {
      if (isPrev) {
        return PlayerButton(
            icon: Icons.skip_previous,
            onKey: (event) {
              return onKey(event, (keyCode) {
                switch (keyCode) {
                  case KeyConstants.ENTER:
                  case KeyConstants.KEY_CENTER:
                  case KeyConstants.PAUSE:
                    if (Player.of(context)!.isSnackbarVisible()) {
                      onTap();
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
                }
                return PlayerSnackbar.of(context)!.onKeys(keyCode);
              });
            });
      }
      return PlayerButton(
          icon: Icons.skip_next,
          onKey: (event) {
            return onKey(event, (keyCode) {
              switch (keyCode) {
                case KeyConstants.ENTER:
                case KeyConstants.KEY_CENTER:
                case KeyConstants.PAUSE:
                  if (Player.of(context)!.isSnackbarVisible()) {
                    onTap();
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
              }
              return PlayerSnackbar.of(context)!.onKeys(keyCode);
            });
          });
    });
  }
}
