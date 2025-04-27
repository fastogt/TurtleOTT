import 'package:flutter/material.dart';
import 'package:player/player.dart';
import 'package:turtleott/utils/fix_date.dart';

class VodPlayerTime extends StatelessWidget {
  final IStandartPlayerController controller;

  const VodPlayerTime(this.controller);

  static String formatMs(int ms) {
    int tempMs = ms;
    final int hours = ms ~/ 3600000;

    tempMs = tempMs - hours * 3600000;
    final int minutes = tempMs ~/ 60000;

    tempMs = tempMs - minutes * 60000;
    final int seconds = tempMs ~/ 1000;

    final StringBuffer _result = StringBuffer();
    _result.write(hours);
    _result.write(':');
    _result.write(fixZero(minutes));
    _result.write(':');
    _result.write(fixZero(seconds));
    return _result.toString();
  }

  @override
  Widget build(BuildContext context) {
    return PlayerStateBuilder(controller, builder: (BuildContext context, IPlayerState? state) {
      if (state is PlayingIPlayerState) {
        return Row(children: [
          _VodPlayerPosition(controller),
          const Text('/'),
          _VodPlayerDuration(controller)
        ]);
      }

      return const Text('0:00:00 / 0:00:00');
    });
  }
}

class _VodPlayerPosition extends StatefulWidget {
  final IStandartPlayerController controller;

  const _VodPlayerPosition(this.controller);

  @override
  _VodPlayerPositionState createState() => _VodPlayerPositionState();
}

class _VodPlayerPositionState extends State<_VodPlayerPosition> {
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
    final int position = widget.controller.position().inMilliseconds;
    final String result = VodPlayerTime.formatMs(position);
    return Text(result);
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }
}

class _VodPlayerDuration extends StatelessWidget {
  final IStandartPlayerController controller;

  const _VodPlayerDuration(this.controller);

  @override
  Widget build(BuildContext context) {
    final int duration = controller.baseController!.value.duration.inMilliseconds;
    final String result = VodPlayerTime.formatMs(duration);
    return Text(result);
  }
}
