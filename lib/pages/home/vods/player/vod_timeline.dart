import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';
import 'package:player/player.dart';
import 'package:turtleott/base/scale.dart';
import 'package:turtleott/player/player.dart';
import 'package:turtleott/player/snackbar.dart';
import 'package:turtleott/player/timeline.dart';

class VodPlayerTimeline extends StatefulWidget {
  static const double dashHeight = 16;
  static const double lineHeight = 8;

  final IStandartPlayerController controller;

  const VodPlayerTimeline(this.controller);

  @override
  _VodPlayerTimelineState createState() {
    return _VodPlayerTimelineState();
  }
}

class _VodPlayerTimelineState extends State<VodPlayerTimeline> {
  late final FocusNode _timelineNode = FocusNode();

  @override
  void dispose() {
    _timelineNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlayerStateBuilder(widget.controller,
        builder: (BuildContext context, IPlayerState? state) {
      if (state is PlayingIPlayerState) {
        return Focus(
            focusNode: _timelineNode,
            onKey: (node, event) {
              return onKey(event, (keyCode) {
                switch (keyCode) {
                  case KeyConstants.KEY_LEFT:
                  case KeyConstants.PREVIOUS:
                    if (Player.of(context)!.isSnackbarVisible()) {
                      widget.controller.seekBackward();
                    }
                    Player.of(context)!.showSnackbar();
                    return KeyEventResult.handled;
                  case KeyConstants.KEY_RIGHT:
                  case KeyConstants.NEXT:
                    if (Player.of(context)!.isSnackbarVisible()) {
                      widget.controller.seekForward();
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
            },
            child: AutoScaleWidget(
                xScale: 1, // avoid X-axis scaling
                yScale: 1.5,
                node: _timelineNode,
                builder: (_) {
                  return _Timeline(widget.controller);
                }));
      }

      return const Divider(thickness: VodPlayerTimeline.lineHeight, color: Colors.white70);
    });
  }
}

class _Timeline extends StatefulWidget {
  final IStandartPlayerController controller;

  const _Timeline(this.controller);

  @override
  _TimelineState createState() {
    return _TimelineState();
  }
}

class _TimelineState extends State<_Timeline> {
  @override
  void initState() {
    super.initState();
    widget.controller.baseController!.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.baseController!.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final val = widget.controller.baseController!.value;
    final int duration = val.duration.inMilliseconds;
    final int position = val.position.inMilliseconds;
    if (duration != 0) {
      final double progressValue = position / duration;
      return PlayerTimeline(progressValue);
    }
    return const PlayerTimeline(0);
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }
}
