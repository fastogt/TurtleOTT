import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/series_stream.dart';
import 'package:turtleott/base/streams_grid/grid.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/pages/home/series/series_description.dart';

class SeriesPage extends TvStreamsGrid<SerialStream> {
  final ContentBloc bloc;

  const SeriesPage(List<OttPackageInfo> packages, this.bloc) : super(packages, false);

  @override
  _SeriesPageState createState() {
    return _SeriesPageState();
  }
}

class _SeriesPageState extends TvStreamsGridState<SerialStream, SeriesPage> {
  @override
  String get searchTitle => TR_SEARCH_SERIES;

  @override
  Widget pushPage(SerialStream stream) {
    return SeriesDescription(stream, widget.bloc);
  }

  @override
  String getIconFromItem(SerialStream item) {
    return item.icon();
  }

  @override
  String getNameFromItem(SerialStream item) {
    return item.displayName();
  }
}
