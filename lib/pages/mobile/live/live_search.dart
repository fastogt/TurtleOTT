import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/live_stream.dart';
import 'package:turtleott/base/mobile_custom_search.dart';
import 'package:turtleott/pages/home/types.dart';
import 'package:turtleott/pages/mobile/live/live_tile.dart';

class LiveStreamSearch<T extends LiveStream> extends CustomSearchDelegate<LiveStream> {
  final OnPackageBuyPressed onPackageBuyPressed;
  final ContentBloc bloc;

  LiveStreamSearch(
      List<T> results, String hint, OttPackageInfo package, this.onPackageBuyPressed, this.bloc)
      : super(results, hint, package);

  @override
  Widget list(List<LiveStream> results, BuildContext context, OttPackageInfo package) {
    return ListView.separated(
        separatorBuilder: (context, int index) => const Divider(height: 6),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final indexInPackage = package.streams.indexWhere((el) => el.id == results[index].id());
          return LiveStreamTile(
              package: package,
              streamIndex: indexInPackage,
              onBuyPressed: (package) => onPackageBuyPressed(package),
              bloc: bloc);
        });
  }
}
