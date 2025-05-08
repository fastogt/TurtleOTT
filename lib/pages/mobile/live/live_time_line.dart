import 'dart:async';

import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/managers.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/utils/theme.dart';

class LiveTimeLine extends StatefulWidget {
  final ProgrammeInfo programmeInfo;
  final double width;
  final double? height;
  final Color? color;

  const LiveTimeLine({required this.programmeInfo, required this.width, this.height, this.color});

  @override
  LiveTimeLineState createState() {
    return LiveTimeLineState();
  }
}

class LiveTimeLineState<T extends LiveTimeLine> extends State<T> {
  static const int REFRESH_TIMELINE_SEC = 1;

  Timer? _timer;
  double _width = 0;

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
    final double height = widget.height ?? 5;
    return Stack(children: <Widget>[
      Container(
          color: widget.color ?? Theme.of(context).colorScheme.secondary,
          height: height,
          width: _width),
      Container(
          color: Theming.of(context).onBrightness().withOpacity(0.1),
          height: height,
          width: widget.width)
    ]);
  }

  @protected
  void initTimeline(ProgrammeInfo programmeInfo) {
    start = programmeInfo.start;
    stop = programmeInfo.stop;
    _update(programmeInfo);
    _timer = Timer.periodic(const Duration(seconds: REFRESH_TIMELINE_SEC), (Timer t) {
      _update(programmeInfo);
    });
  }

  // private:
  void _update(ProgrammeInfo programmeInfo) {
    _syncControls(programmeInfo);
    if (mounted) {
      setState(() {});
    }
  }

  void _syncControls(ProgrammeInfo programmeInfo) {
    final TimeManager time = locator<TimeManager>();
    final int curUtc = time.realTimeMSec();
    final int totalTime = stop - start;
    final int passed = curUtc - start;
    double inPercent = 0;
    if (totalTime != 0) {
      inPercent = passed / totalTime;
    }

    if (curUtc > stop) {
      _width = 0;
    } else {
      _width = widget.width * inPercent;
    }
  }
}
