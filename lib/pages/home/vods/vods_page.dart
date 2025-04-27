import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/vod_stream.dart';
import 'package:turtleott/base/streams_grid/grid.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/vods/vod_page.dart';

class VodsPage extends TvStreamsGrid<VodInfo> {
  final ContentBloc bloc;

  const VodsPage(List<OttPackageInfo> package, this.bloc) : super(package, true);

  @override
  _VodsPageState createState() {
    return _VodsPageState();
  }
}

class _VodsPageState extends TvStreamsGridState<VodInfo, VodsPage> {
  @override
  String get searchTitle => TR_SEARCH_VOD;

  @override
  Widget pushPage(VodInfo stream) {
    return VodPage(VodStream(stream), widget.bloc);
  }

  @override
  String getIconFromItem(VodInfo item) {
    final vod = VodStream(item);
    return vod.icon();
  }

  @override
  String getNameFromItem(VodInfo item) {
    final vod = VodStream(item);
    return vod.displayName();
  }
}
