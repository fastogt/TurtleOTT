import 'package:flutter/material.dart';
import 'package:flutter_common/localization.dart';
import 'package:flutter_common/utils.dart';
import 'package:player/common/states.dart';
import 'package:turtleott/base/round_button.dart';
import 'package:turtleott/pages/home/sidebar_tile.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/player/player.dart';

abstract class PlayerSnackbar extends StatefulWidget {
  static const double HEIGHT_FACTOR = 0.45;

  final BasePlayerController controller;

  static PlayerSnackbarState? of(BuildContext context) {
    return context.findAncestorStateOfType<PlayerSnackbarState>();
  }

  const PlayerSnackbar(this.controller);
}

abstract class PlayerSnackbarState<S extends PlayerSnackbar> extends State<S>
    with AutomaticKeepAliveClientMixin {
  static const posterBottomSpacing = SidebarTile.iconWidth / 2 * 1.3;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FractionallySizedBox(
        heightFactor: 0.35,
        widthFactor: 1.0,
        child: Stack(children: [
          Positioned.fill(child: Container(color: Colors.black54)),
          Row(children: [
            SizedBox(width: 274, child: icon()),
            Expanded(
                child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(AppLocalizations.toUtf8(title),
                            style:
                                Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 28),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis))),
                DefaultTextStyle(style: Theme.of(context).textTheme.titleLarge!, child: time())
              ]),
              timeline()
            ])),
            const SizedBox(width: SidebarTile.iconWidth / 2)
          ]),
          Positioned(
              left: 0,
              right: 0,
              bottom: posterBottomSpacing - RoundedButton.SIZE / 2,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: buttons()))
        ]));
  }

  String get title => widget.controller.displayName();

  Widget icon();

  Widget time();

  Widget timeline();

  List<Widget> buttons() {
    return [PlayPauseButton(widget.controller)];
  }

  KeyEventResult onKeys(int keyCode) {
    switch (keyCode) {
      case KeyConstants.BACK:
      case KeyConstants.BACKSPACE:
        return KeyEventResult.handled;
      case KeyConstants.MENU:
      case 41:
        Player.of(context)!.toggleSnackbar();
        return KeyEventResult.handled;
      case KeyConstants.KEY_UP:
        {
          Player.of(context)!.showSnackbar();
          return FocusScope.of(context).focusInDirection(TraversalDirection.up)
              ? KeyEventResult.handled
              : KeyEventResult.ignored;
        }
      case KeyConstants.KEY_DOWN:
        {
          Player.of(context)!.showSnackbar();
          return FocusScope.of(context).focusInDirection(TraversalDirection.down)
              ? KeyEventResult.handled
              : KeyEventResult.ignored;
        }
    }
    Player.of(context)!.showSnackbar();
    return KeyEventResult.ignored;
  }
}

class PlayerButton extends RoundedButton {
  const PlayerButton(
      {required IconData icon,
      required KeyEventResult Function(RawKeyEvent) onKey,
      bool autofocus = false})
      : super(
            icon: icon,
            onKey: onKey,
            autofocus: autofocus,
            cornerRadius: 5,
            unfocusedColor: Colors.transparent);
}

class PlayPauseButton extends StatefulWidget {
  final IPlayerControllerRes controller;

  const PlayPauseButton(this.controller);

  @override
  _PlayPauseButtonState createState() {
    return _PlayPauseButtonState();
  }
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  @override
  Widget build(BuildContext context) {
    return PlayerStateBuilder(widget.controller,
        builder: (BuildContext context, IPlayerState? state) {
      if (state is PlayingIPlayerState) {
        return PlayerButton(
            autofocus: true,
            icon: widget.controller.isPlaying() ? Icons.pause : Icons.play_arrow,
            onKey: (event) {
              final result = onKey(event, (keyCode) {
                if (keyCode == KeyConstants.KEY_CENTER || keyCode == KeyConstants.ENTER) {
                  if (Player.of(context)!.isSnackbarVisible() && widget.controller.isPlaying()) {
                    widget.controller.pause();
                  } else {
                    widget.controller.play();
                  }
                  setState(() {});
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
                }
                if (keyCode == KeyConstants.KEY_RIGHT) {
                  if (Player.of(context)!.isSnackbarVisible()) {
                    return FocusScope.of(context).focusInDirection(TraversalDirection.right)
                        ? KeyEventResult.handled
                        : KeyEventResult.ignored;
                  }
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
                }
                if (keyCode == KeyConstants.KEY_LEFT) {
                  if (Player.of(context)!.isSnackbarVisible()) {
                    return FocusScope.of(context).focusInDirection(TraversalDirection.left)
                        ? KeyEventResult.handled
                        : KeyEventResult.ignored;
                  }
                  Player.of(context)!.showSnackbar();
                  return KeyEventResult.handled;
                }
                if (keyCode == KeyConstants.KEY_UP) {
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
              return result;
            });
      }

      return PlayerButton(
          autofocus: true,
          icon: Icons.play_disabled,
          onKey: (event) {
            return onKey(event, PlayerSnackbar.of(context)!.onKeys);
          });
    });
  }
}
