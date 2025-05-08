import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';
import 'package:player/common/controller.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/live_stream.dart';
import 'package:turtleott/base/locked_dialog.dart';
import 'package:turtleott/base/streams/program_bloc.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/types.dart';
import 'package:turtleott/pages/mobile/live/live_player_page.dart';
import 'package:turtleott/pages/mobile/live/live_time_line.dart';
import 'package:turtleott/pages/mobile/settings/age_picker.dart';
import 'package:turtleott/player/controller.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';
import 'package:turtleott/utils/theme.dart';

class LiveStreamTile extends StatefulWidget {
  final OttPackageInfo package;
  final int streamIndex;
  final OnPackageBuyPressed onBuyPressed;
  final ContentBloc bloc;

  const LiveStreamTile(
      {required this.package,
      required this.streamIndex,
      required this.onBuyPressed,
      required this.bloc})
      : super();

  @override
  _LiveStreamTileState createState() {
    return _LiveStreamTileState();
  }
}

class _LiveStreamTileState extends State<LiveStreamTile> implements IPlayerListener<LiveStream> {
  late ProgramsBloc programsBloc;

  LiveStream get _stream {
    return LiveStream(widget.package.streams[widget.streamIndex]);
  }

  @override
  void onPlaying(IPlayerController cont, String url) {
    final live = cont as LivePlayerController;
    widget.bloc.add(PlayingLiveStreamEvent(live.currentStream));
  }

  @override
  void onPlayingError(IPlayerController cont, String url) {}

  @override
  void onEOS(IPlayerController cont, String url) {}

  @override
  void onSetInterrupt(IPlayerController cont, LiveStream stream, int msec) {}

  @override
  void initState() {
    programsBloc = ProgramsBloc(_stream);
    super.initState();
  }

  @override
  void dispose() {
    programsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      ListTile(
          leading: PreviewIcon.live(_stream.icon(), height: 40, width: 40),
          title: Text(AppLocalizations.toUtf8(_stream.displayName())),
          subtitle: programNameWidget(),
          onTap: () => onTap(),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: _actions())),
      timeLine()
    ]);
  }

  void onTap() {
    void saveLastViewed() {
      final settings = locator<LocalStorageService>();
      final isSaved = settings.saveLastViewed();
      if (isSaved) {
        settings.setLastPackage(widget.package.id);
        settings.setLastChannel(_stream.id());
      }
    }

    final bloc = context.read<ContentBloc>();
    final route = MaterialPageRoute(
        builder: (BuildContext context) => ChannelPage(
            bloc: bloc, position: widget.streamIndex, package: widget.package, listener: this));
    if (isLocked()) {
      if (isLockedChannel()) {
        final price = _stream.price!;
        showDialog(
            context: context,
            builder: (context) => LockedStreamDialog(
                () => widget.onBuyPressed(widget.package), price.price, price.currency));
      } else {
        final price = widget.package.price!;
        showDialog(
            context: context,
            builder: (context) => LockedPackageDialog(
                () => widget.onBuyPressed(widget.package), price.price, price.currency));
      }
      return;
    }

    if (isAgeAllowed()) {
      allowAll();
      saveLastViewed();
      Navigator.push(context, route);
    } else {
      showDialog(context: context, builder: (BuildContext context) => CheckPassword(route: route));
    }
  }

  bool isLockedChannel() {
    return _stream.price != null;
  }

  bool isLocked() {
    return isLockedChannel();
  }

  bool isAgeAllowed() {
    final settings = locator<LocalStorageService>();
    final age = settings.ageRating();
    return age >= widget.package.streams[widget.streamIndex].iarc;
  }

  List<Widget> _actions() {
    if (isLocked()) {
      return [_lockedIcon()];
    }
    if (!isAgeAllowed()) {
      return <Widget>[_parentControlIcon()];
    }
    return <Widget>[_favoriteButton()];
  }

  // actions
  Widget _favoriteButton() {
    return FavoriteStarButton(_stream.favorite(), onFavoriteChanged: (bool favorite) {
      widget.bloc.add(SetLiveStreamFavoriteEvent(liveStream: _stream, state: favorite));
    }, unselectedColor: Theming.of(context).onBrightness());
  }

  Widget _lockedIcon() {
    return IconButton(icon: const Icon(Icons.lock), onPressed: () {});
  }

  Widget _parentControlIcon() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(icon: const Icon(Icons.child_care), onPressed: () {}),
      Text('${_stream.iarc()}+')
    ]);
  }

  Widget programNameWidget() {
    String title(ProgrammeInfo? programmeInfo) {
      if (programmeInfo != null) {
        return programmeInfo.title;
      }
      return 'N/A';
    }

    return StreamBuilder<ProgrammeInfo?>(
        stream: programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text(translate(context, TR_LOADING), softWrap: true, maxLines: 3);
          }
          return Text(
            title(snapshot.data),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        });
  }

  Widget timeLine() {
    return StreamBuilder<ProgrammeInfo?>(
        stream: programsBloc.currentProgram,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }

          if (!snapshot.hasData) {
            return const SizedBox();
          }
          return LiveTimeLine(
              programmeInfo: snapshot.data!, width: MediaQuery.of(context).size.width, height: 2);
        });
  }
}
