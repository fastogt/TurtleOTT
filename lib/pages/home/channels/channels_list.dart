import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_common/localization.dart';
import 'package:flutter_fastotv_common/base/controls/preview_icon.dart';
import 'package:turtleott/base/animated_list_section.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/channels/live_stream.dart';
import 'package:turtleott/base/streams/program_bloc.dart';
import 'package:turtleott/pages/home/channels/player/live_player.dart';
import 'package:turtleott/pages/home/channels/programs_list.dart';
import 'package:turtleott/pages/home/types.dart';

class ChannelsList extends StatelessWidget {
  final List<LiveStream> streams;
  final OnPackageBuyPressed onPackageBuyPressed;
  final ContentBloc bloc;
  const ChannelsList(this.streams, this.onPackageBuyPressed, this.bloc, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedListSection<LiveStream>(
        items: streams,
        onItem: (item) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) {
            return LivePlayer(streams, streams.indexOf(item), bloc);
          }));
        },
        itemBuilder: (LiveStream stream) {
          return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Expanded(flex: 3, child: PreviewIcon.live(stream.icon())),
            const Spacer(),
            Expanded(flex: 6, child: Text(AppLocalizations.toUtf8(stream.displayName()))),
          ]);
        },
        contentBuilder: (stream) {
          final programsBloc = ProgramsBloc(stream);
          final bloc = context.read<ContentBloc>();
          final FocusNode _descriptionFocus = FocusNode();
          return ProgramsListView(
              programsBloc: programsBloc,
              contentBloc: bloc,
              textColor: Theme.of(context).primaryColor,
              node: _descriptionFocus,
              onCatchupPressed: (CatchupInfo cat) {});
        });
  }
}
