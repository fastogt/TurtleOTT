import 'dart:async';

import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter_common/managers.dart';
import 'package:rxdart/rxdart.dart';
import 'package:turtleott/base/channels/live_stream.dart';
import 'package:turtleott/epg_manager.dart';
import 'package:turtleott/service_locator.dart';

class ProgramsBloc {
  final LiveStream channel;
  final _currentProgramStream = BehaviorSubject<ProgrammeInfo?>();
  final _programsListStream = BehaviorSubject<List<ProgrammeInfo>?>();
  Timer? _timer;
  List<ProgrammeInfo> _programs = [];

  ProgramsBloc(this.channel) {
    final epg = locator<EpgManager>();
    final programs = epg.getEpg(channel.epgId());

    // need to request
    if (programs == null) {
      final epg = locator<EpgManager>();
      final request = epg.requestEpg(channel.epgId());
      final _programsStream = request.asStream();
      _programsStream.listen(_setPrograms);
      return;
    }

    _setPrograms(programs);
  }

  CatchupInfo? findCatchupByProgrammeInfo(ProgrammeInfo progr, List<CatchupInfo> catchups) {
    return channel.findCatchupByTime(progr.start, progr.stop, catchups);
  }

  void _setPrograms(List<ProgrammeInfo> data) {
    _programs = data;
    if (_currentProgramStream.isClosed) {
      return;
    }

    if (_programs.isNotEmpty) {
      _addProgramList.add(_programs);
      _updatePrograms();
    } else {
      _addProgramList.add(null);
      _addProgram.add(null);
    }
  }

  void _updatePrograms() {
    if (_currentProgramStream.isClosed) {
      return;
    }

    final ProgrammeInfo? _currentProgram = _findCurrent();
    _addProgram.add(_currentProgram);
    _setTimer(_currentProgram);
  }

  void _setTimer(ProgrammeInfo? programmeInfo) {
    if (programmeInfo == null) {
      return;
    }

    final _timeManager = locator<TimeManager>();
    final curUtc = _timeManager.realTimeMSec();
    final timeToChangeOnNew = programmeInfo.durationMsec - (curUtc - programmeInfo.start);
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: timeToChangeOnNew), () {
      _updatePrograms();
    });
  }

  ProgrammeInfo? _findCurrent() {
    final _timeManager = locator<TimeManager>();
    final int curUtc = _timeManager.realTimeMSec();
    final program = findProgrammeByTime(curUtc);
    if (program == null) {
      return null;
    }

    return program;
  }

  ProgrammeInfo? findProgrammeByTime(int time) {
    for (final pr in _programs) {
      if (time >= pr.start && time <= pr.stop) {
        return pr;
      }
    }

    return null;
  }

  int? getIndex(ProgrammeInfo? item) {
    if (item == null) {
      return null;
    }

    for (int i = 0; i < _programs.length; i++) {
      final it = _programs[i];
      if (it.start == item.start && it.stop == item.stop) {
        return i;
      }
    }
    return null;
  }

  Sink get _addProgram => _currentProgramStream.sink;

  Sink get _addProgramList => _programsListStream.sink;

  // Public
  Stream<ProgrammeInfo?> get currentProgram => _currentProgramStream.stream;

  ProgrammeInfo? get currentProgramValue => _currentProgramStream.value;

  Stream<List<ProgrammeInfo>?> get programsList => _programsListStream.stream;

  void dispose() {
    _currentProgramStream.close();
    _programsListStream.close();
    _timer?.cancel();
  }
}

extension ProgrammeInfoDisplay on ProgrammeInfo {
  String subtitle() {
    final DateTime startTime = DateTime.fromMillisecondsSinceEpoch(start);
    final DateTime stopTime = DateTime.fromMillisecondsSinceEpoch(stop);

    String formatTime(DateTime time) {
      final int hour = time.hour;
      final int minute = time.minute;
      final String period = hour >= 12 ? 'PM' : 'AM';
      final int formattedHour = hour % 12 == 0 ? 12 : hour % 12;
      final String formattedMinute = minute.toString().padLeft(2, '0');
      return '$formattedHour:$formattedMinute $period';
    }

    String formatDate(DateTime time) {
      return '${time.month}/${time.day}';
    }

    return '${formatDate(startTime)}'
        ' / ${formatTime(startTime)}'
        ' - ${formatTime(stopTime)}'
        ' / ${durationText()}';
  }
}
