import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/border.dart';
import 'package:turtleott/base/streams/program_bloc.dart';
import 'package:turtleott/pages/home/channels/no_programs.dart';
import 'package:turtleott/service_locator.dart';

typedef OnCatchupPressedCallback = void Function(CatchupInfo cat);

class ProgramsListView extends StatefulWidget {
  final ContentBloc contentBloc;
  final ProgramsBloc programsBloc;
  final double? itemHeight;
  final Color? activeColor;
  final Color textColor;
  final FocusNode? node;
  final OnCatchupPressedCallback onCatchupPressed;

  const ProgramsListView(
      {required this.contentBloc,
      required this.programsBloc,
      required this.onCatchupPressed,
      this.itemHeight,
      this.activeColor,
      this.node,
      required this.textColor});

  @override
  _ProgramsListViewState createState() {
    return _ProgramsListViewState();
  }
}

class _ProgramsListViewState extends State<ProgramsListView> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: StreamBuilder(
            stream: widget.programsBloc.programsList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data == null) {
                return NoPrograms(widget.textColor);
              }

              final cur = widget.programsBloc.currentProgramValue;
              final _index = widget.programsBloc.getIndex(cur);
              if (_index == null) {
                return NoPrograms(widget.textColor);
              }

              final stabled = snapshot.data as List<ProgrammeInfo>;
              return _ProgramsList(
                  programs: stabled,
                  onCatchupPressed: widget.onCatchupPressed,
                  contentBloc: widget.contentBloc,
                  bloc: widget.programsBloc,
                  index: _index,
                  itemHeight: widget.itemHeight,
                  activeColor: widget.activeColor,
                  node: widget.node,
                  textColor: widget.textColor);
            }));
  }
}

class _ProgramsList extends StatefulWidget {
  final List<ProgrammeInfo> programs;

  final ContentBloc contentBloc;
  final ProgramsBloc bloc;
  final int index;
  final double? itemHeight;
  final Color? activeColor;
  final Color textColor;
  final FocusNode? node;
  final OnCatchupPressedCallback onCatchupPressed;

  const _ProgramsList(
      {required this.programs,
      required this.contentBloc,
      required this.onCatchupPressed,
      required this.bloc,
      required this.index,
      this.itemHeight,
      this.activeColor,
      this.node,
      required this.textColor});

  @override
  _ProgramsListState createState() {
    return _ProgramsListState();
  }
}

class _ProgramsListState extends State<_ProgramsList> {
  static const ITEM_HEIGHT = 64.0;

  late CustomScrollController _scrollController;
  late final int _current;
  late double _itemHeight;
  late final List<FocusNode> _nodes;
  late final Future<List<CatchupInfo>?> _catchups;

  @override
  void initState() {
    super.initState();
    _nodes = List<FocusNode>.generate(widget.programs.length, (index) => FocusNode());
    _itemHeight = widget.itemHeight ?? ITEM_HEIGHT;
    _current = widget.index;
    _scrollController =
        CustomScrollController(itemHeight: _itemHeight, initOffset: _itemHeight * _current);
    _initCurrentProgramSubscription();
    final chan = widget.bloc.channel;
    _catchups = widget.contentBloc.profile.getCatchups(chan.pid(), chan.id());
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _catchups,
        builder: (context, snapshot) {
          List<CatchupInfo> catchups = [];
          if (snapshot.data != null) {
            catchups = snapshot.data!;
          }

          final time = locator<TimeManager>();
          return ListView.separated(
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox();
              },
              itemCount: widget.programs.length,
              controller: _scrollController.controller,
              itemBuilder: (BuildContext context, int index) {
                final program = widget.programs[index];
                final isCur = index == _current;
                final elevation = isCur ? 1.0 : 0.0;
                final curUtc = time.realTimeMSec();
                final inPast = program.stop < curUtc;
                final currentColor = isCur ? activeColor() : Colors.transparent;

                final Widget tile;
                if (inPast) {
                  tile = _ProgramListTile(
                      onCatchupPressed: widget.onCatchupPressed,
                      program: program,
                      selectedColor: widget.activeColor,
                      node: _nodes[index],
                      catchupInfo: widget.bloc.findCatchupByProgrammeInfo(program, catchups));
                } else {
                  tile = _ProgramListTile(
                      onCatchupPressed: widget.onCatchupPressed,
                      program: program,
                      selectedColor: widget.activeColor,
                      node: _nodes[index]);
                }

                return Opacity(
                    opacity: inPast ? 0.4 : 1.0,
                    child: Material(
                        elevation: elevation,
                        color: Colors.transparent,
                        child: Container(
                            height: _itemHeight,
                            decoration: BoxDecoration(border: Border.all(color: currentColor)),
                            child: tile)));
              });
        });
  }

  Color activeColor() {
    return widget.activeColor ?? Theme.of(context).colorScheme.secondary;
  }

  void _initCurrentProgramSubscription() {
    widget.bloc.currentProgram.listen((ProgrammeInfo? program) {
      final ind = widget.bloc.getIndex(program);
      if (ind != null) {
        _current = ind;
        _scrollController.jumpToPosition(_current);
        if (mounted) {
          setState(() {});
        }
      }
    });
  }
}

class _ProgramListTile extends StatefulWidget {
  final OnCatchupPressedCallback onCatchupPressed;
  final ProgrammeInfo program;
  final Color? selectedColor;
  final CatchupInfo? catchupInfo;

  final FocusNode node;

  const _ProgramListTile(
      {required this.program,
      required this.onCatchupPressed,
      this.selectedColor,
      required this.node,
      this.catchupInfo});

  @override
  _ProgramListTileState createState() {
    return _ProgramListTileState();
  }
}

class _ProgramListTileState extends State<_ProgramListTile> {
  bool _hasTouch = true;

  bool get hasCatchup {
    return widget.catchupInfo != null;
  }

  @override
  void initState() {
    super.initState();
    final device = locator<RuntimeDevice>();
    _hasTouch = device.hasTouch;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: widget.node,
        onKey: (node, event) {
          return onKey(event, (keyCode) {
            if (hasCatchup) {
              switch (keyCode) {
                case KeyConstants.ENTER:
                case KeyConstants.KEY_CENTER:
                  {
                    widget.onCatchupPressed.call(widget.catchupInfo!);
                    return KeyEventResult.ignored;
                  }
              }
            }
            return KeyEventResult.ignored;
          });
        },
        child: FocusBorder(
            focus: widget.node,
            child: ListTile(
                dense: true,
                onTap: hasCatchup
                    ? () {
                        widget.onCatchupPressed.call(widget.catchupInfo!);
                      }
                    : null,
                title: Text(widget.program.title,
                    style: TextStyle(fontSize: 16, color: _textColor()),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false),
                subtitle: Opacity(
                    opacity: 0.6,
                    child: Row(children: [
                      Text(_formatProgram(widget.program), style: TextStyle(color: _textColor())),
                      const SizedBox(width: 4),
                      _trailing()
                    ])))));
  }

  Widget _trailing() {
    if (hasCatchup) {
      return Icon(size: 15, Icons.access_time, color: Colors.green[400]);
    }

    return const SizedBox();
  }

  // private:
  Color? _textColor() {
    if ((_hasTouch && (isPortrait(context) || isLandscape(context))) || !_hasTouch) {
      return null;
    }
    return Colors.white;
  }

  String _formatProgram(ProgrammeInfo program) {
    return '${dateFromMsec(program.start)} / ${hmFromMsec(program.start)} - ${hmFromMsec(program.stop)} / ${program.durationText()}';
  }
}
