import 'dart:async';

import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/managers.dart';
import 'package:turtleott/base/streams/program_bloc.dart';
import 'package:turtleott/player/timeline.dart';
import 'package:turtleott/service_locator.dart';

class LivePlayerTimeline extends StatelessWidget {
  final ProgramsBloc programs;

  const LivePlayerTimeline(this.programs);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgrammeInfo?>(
        stream: programs.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return LiveTimeline(snapshot.data!);
          }
          return const Divider(thickness: PlayerTimeline.lineHeight, color: Colors.white70);
        });
  }
}

class LiveTimeline extends StatefulWidget {
  final ProgrammeInfo program;
  final Widget Function(double progress)? builder;

  const LiveTimeline(this.program, {this.builder});

  @override
  _LiveTimelineState createState() => _LiveTimelineState();
}

class _LiveTimelineState extends State<LiveTimeline> {
  static const REFRESHLiveTIMELINE_SEC = 1;

  Timer? _timer;

  late double progress = 0;

  @override
  void initState() {
    super.initState();
    _initTimeline(widget.program);
  }

  @override
  void didUpdateWidget(LiveTimeline oldWidget) {
    if (oldWidget.program != widget.program) {
      _initTimeline(widget.program);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder?.call(progress) ?? PlayerTimeline(progress);
  }

  void _initTimeline(ProgrammeInfo program) {
    _update(program);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: REFRESHLiveTIMELINE_SEC), (Timer t) {
      _update(program);
    });
  }

  void _update(ProgrammeInfo programmeInfo) {
    _syncControls(programmeInfo);
    if (mounted) {
      setState(() {});
    }
  }

  void _syncControls(ProgrammeInfo program) async {
    final time = locator<TimeManager>();
    final curUtc = time.realTimeMSec();
    final totalTime = program.stop - program.start;
    final passed = curUtc - program.start;
    if (curUtc > program.stop) {
      progress = 0;
    } else if (totalTime != 0) {
      progress = passed / totalTime;
    }
  }
}
