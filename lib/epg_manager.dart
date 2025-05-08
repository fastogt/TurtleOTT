import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/service_locator.dart';

typedef OnGetEPGRequested = Future<List<ProgrammeInfo>> Function(String cid);

class EpgManager {
  static const int MAX_PROGRAMS_COUNT = 500;
  static EpgManager? _instance;
  final Map<String, List<ProgrammeInfo>> _cache = {};
  OnGetEPGRequested? onGetEPG;

  static Future<EpgManager> getInstance() async {
    _instance ??= EpgManager();

    return _instance!;
  }

  void setEpgHandler(OnGetEPGRequested getEpgCb) {
    onGetEPG = getEpgCb;
  }

  List<ProgrammeInfo>? getEpg(String epgId) {
    return _cache[epgId];
  }

  Future<List<ProgrammeInfo>> requestEpg(String epgId) {
    final result = _epgHttpRequest(epgId);
    result.then((value) {
      _cache[epgId] = value;
    });
    return result;
  }

  // private:
  Future<List<ProgrammeInfo>> _epgHttpRequest(String epgId) async {
    if (epgId.isEmpty) {
      return [];
    }

    if (onGetEPG == null) {
      return [];
    }

    List<ProgrammeInfo> programs = await onGetEPG!.call(epgId);
    if (programs.length > MAX_PROGRAMS_COUNT) {
      final _timeManager = locator<TimeManager>();
      final int curUtc = _timeManager.realTimeMSec();
      final last = _sliceLastByTime(programs, curUtc);
      if (last.length > MAX_PROGRAMS_COUNT) {
        last.length = MAX_PROGRAMS_COUNT;
      }
      programs = last;
    }
    return programs;
  }

  static List<ProgrammeInfo> _sliceLastByTime(List<ProgrammeInfo> origin, int currentTime) {
    const int sevenDaysInSeconds = 7 * 24 * 60 * 60;
    final int sevenDaysAgo = currentTime - sevenDaysInSeconds;
    final List<ProgrammeInfo> last7DaysPrograms = <ProgrammeInfo>[];
    final List<ProgrammeInfo> currentAndFuturePrograms = <ProgrammeInfo>[];
    for (final ProgrammeInfo program in origin) {
      if (program.start >= sevenDaysAgo &&
          program.stop <= currentTime &&
          program.start <= currentTime &&
          program.stop >= currentTime) {
        last7DaysPrograms.add(program);
      } else if (program.start > currentTime) {
        currentAndFuturePrograms.add(program);
      }
    }
    List<ProgrammeInfo> combinedPrograms = [...currentAndFuturePrograms, ...last7DaysPrograms];

    if (combinedPrograms.length > MAX_PROGRAMS_COUNT) {
      combinedPrograms = combinedPrograms.sublist(0, MAX_PROGRAMS_COUNT);
    }
    return combinedPrograms;
  }
}
