import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:turtleott/base/streams/program_bloc.dart';
import 'package:turtleott/utils/fix_date.dart';

class LivePlayerTime extends StatelessWidget {
  final ProgramsBloc programs;

  const LivePlayerTime(this.programs);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProgrammeInfo?>(
        stream: programs.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final start = formatMs(snapshot.data!.start);
            final stop = formatMs(snapshot.data!.stop);
            return Text('$start - $stop');
          }
          return const Text('00:00 - 00:00');
        });
  }

  static String formatMs(int ms) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(ms);
    final int hour = date.hour;
    final int minute = date.minute;

    final StringBuffer _result = StringBuffer();
    _result.write(fixZero(hour));
    _result.write(':');
    _result.write(fixZero(minute));
    return _result.toString();
  }
}
