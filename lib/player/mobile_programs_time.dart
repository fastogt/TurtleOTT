import 'dart:async';

import 'package:fastotv_dart/commands_info/programme_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/utils/theme.dart';

class LiveTime extends StatefulWidget {
  final ProgrammeInfo programmeInfo;
  final bool isLive;
  final Color? color;

  const LiveTime.current({required this.programmeInfo, this.color}) : isLive = true;

  const LiveTime.end({required this.programmeInfo, this.color}) : isLive = false;

  @override
  LiveTimeState createState() {
    return LiveTimeState();
  }
}

class LiveTimeState<T extends LiveTime> extends State<T> {
  static const int REFRESH_TIMELINE_SEC = 1;

  Timer? _timer;
  String _timeString = '';

  late int start;
  late int stop;

  @override
  void initState() {
    super.initState();
    initTimeline(widget.programmeInfo);
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.programmeInfo != widget.programmeInfo) {
      initTimeline(widget.programmeInfo);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.color ?? Theming.onCustomColor(Theme.of(context).primaryColor);
    return Text(_timeString, style: TextStyle(color: color));
  }

  @protected
  void initTimeline(ProgrammeInfo programmeInfo) {
    start = programmeInfo.start;
    stop = programmeInfo.stop;
    _update(programmeInfo);
    if (widget.isLive) {
      _timer = Timer.periodic(
          const Duration(seconds: REFRESH_TIMELINE_SEC), (Timer t) => _update(programmeInfo));
    }
  }

  // private:
  void _update(ProgrammeInfo programmeInfo) {
    _syncControls(programmeInfo);
    if (mounted) {
      setState(() {});
    }
  }

  void _syncControls(ProgrammeInfo programmeInfo) {
    if (widget.isLive) {
      final TimeManager _timeManager = locator<TimeManager>();
      final int curUtc = _timeManager.realTimeMSec();
      final int passed = curUtc - start;

      if (curUtc > stop) {
        _timeString = _parse(0);
      } else {
        _timeString = _parse(passed);
      }
    } else {
      _timeString = _parse(stop - start);
    }
  }

  String _parse(int time) {
    return hmsFromMsec(time - DateTime.now().timeZoneOffset.inMilliseconds);
  }
}
