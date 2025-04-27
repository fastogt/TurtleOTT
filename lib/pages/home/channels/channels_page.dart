import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:turtleott/base/animated_list_section.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/live_stream.dart';
import 'package:turtleott/pages/home/channels/channels_list.dart';
import 'package:turtleott/pages/home/types.dart';

class ChannelsPage<T extends IDisplayContentInfo> extends StatefulWidget {
  final List<OttPackageInfo> content;
  final OnPackageBuyPressed onPackageBuyPressed;
  final ContentBloc bloc;

  const ChannelsPage(this.content, this.onPackageBuyPressed, this.bloc);

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  @override
  Widget build(BuildContext context) {
    final List<String> items = [];
    for (final pack in widget.content) {
      items.add(pack.name);
    }
    return widget.content.isEmpty
        ? const SizedBox()
        : AnimatedListSection<String>(
            listWidth: 190,
            items: items,
            itemBuilder: (String category) {
              return Text(category);
            },
            onItem: (value) {},
            contentBuilder: (category) {
              final List<LiveStream> streams = [];
              for (final pack in widget.content) {
                if (pack.name == category) {
                  for (final e in pack.streams) {
                    streams.add(LiveStream(e));
                  }
                }
              }
              return ChannelsList(streams, widget.onPackageBuyPressed, widget.bloc);
            });
  }
}
