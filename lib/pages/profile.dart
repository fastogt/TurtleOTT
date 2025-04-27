import 'package:fastotv_dart/commands_info.dart';
import 'package:fastotv_dart/profile.dart';
import 'package:turtleott/fetcher.dart';

class Profile {
  final Fetcher fetcher;
  final OttServerInfo info;

  Profile(this.fetcher, this.info);

  Future<SubProfile> profileWithToken() {
    return fetcher.profileWithToken();
  }

  String wsEndpoint() {
    return fetcher.wsEndpoint();
  }

  Future<(List<OttPackageInfo>, List<PackagePublic>)> packagesWithToken() {
    return fetcher.ottPackagesWithToken();
  }

  Future<bool> interruptVod(String? pid, String sid, int msec) {
    return fetcher.interruptVod(pid, sid, msec);
  }

  Future<List<SeasonInfo>?> getSerialSeasons(String? pid, String sid) {
    return fetcher.getSerialSeasons(pid, sid);
  }

  Future<List<VodInfo>?> getSeasonEpisodes(String? pid, String sid) {
    return fetcher.getSeasonEpisodes(pid, sid);
  }

  Future<bool> playingLiveStreamWithToken(String? pid, String sid) {
    return fetcher.incPlayingLive(pid, sid);
  }

  Future<int> getLiveStreamViews(String? pid, String sid) {
    return fetcher.getLiveViewCount(pid, sid);
  }

  Future<bool> playingVodWithToken(String? pid, String vid) {
    return fetcher.incPlayingVod(pid, vid);
  }

  Future<int> getVodViews(String? pid, String sid) {
    return fetcher.getVodViewCount(pid, sid);
  }

  Future<bool> playingEpisodeWithToken(String? pid, String eid) {
    return fetcher.incPlayingEpisode(pid, eid);
  }

  Future<int> getEpisodeViews(String? pid, String sid) {
    return fetcher.getEpisodeViewCount(pid, sid);
  }

  Future<bool> setInterruptStream(String? package, String sid, int msec) {
    return fetcher.interruptLive(package, sid, msec);
  }

  Future<bool> setInterruptVod(String? package, String sid, int msec) {
    return fetcher.interruptVod(package, sid, msec);
  }

  Future<bool> setInterruptEpisode(String? package, String sid, int msec) {
    return fetcher.interruptEpisode(package, sid, msec);
  }

  Future<bool> addFavoriteLiveStream(String pid, String sid, bool value) {
    return fetcher.addFavoriteLive(pid, sid, value);
  }

  Future<bool> addFavoriteVod(String pid, String sid, bool value) {
    return fetcher.addFavoriteVod(pid, sid, value);
  }

  Future<bool> addFavoriteSerial(String pid, String sid, bool value) {
    return fetcher.addFavoriteSerial(pid, sid, value);
  }

  Future<List<CatchupInfo>?> getCatchups(String? pid, String lid) {
    return fetcher.getCatchups(pid, lid);
  }

  Future<bool> subscribe(String pid) {
    return profileWithToken().then((SubProfile sub) {
      fetcher.subscribe(pid, sub.id);
      return true;
    }, onError: (_) {
      return false;
    });
  }
}
