// import 'package:fastotv_dart/commands_info/programme_info.dart';
// import 'package:fastowatch/base/bloc/program_bloc.dart';
// import 'package:fastowatch/base/focusable/border.dart';
// import 'package:fastowatch/pages/mobile/live/no_programs.dart';
// import 'package:fastowatch/service_locator.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_common/flutter_common.dart';

// class ProgramsListView extends StatefulWidget {
//   final ProgramsBloc programsBloc;
//   final double? itemHeight;
//   final Color? activeColor;
//   final Color textColor;
//   final String channelId;
//   final FocusNode? node;

//   const ProgramsListView(
//       {required this.channelId,
//       required this.programsBloc,
//       this.itemHeight,
//       this.activeColor,
//       this.node,
//       required this.textColor});

//   @override
//   _ProgramsListViewState createState() {
//     return _ProgramsListViewState();
//   }
// }

// class _ProgramsListViewState extends State<ProgramsListView> {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//         child: StreamBuilder(
//             stream: widget.programsBloc.programsList,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (snapshot.data == null) {
//                 return NoPrograms(widget.textColor);
//               }
//               final _index = widget.programsBloc.currentProgramIndex;
//               if (_index == null) {
//                 return NoPrograms(widget.textColor);
//               }
//               final stabled = snapshot.data as List<ProgrammeInfo>;
//               return _ProgramsList(
//                   channelId: widget.channelId,
//                   programs: stabled,
//                   bloc: widget.programsBloc,
//                   index: _index,
//                   itemHeight: widget.itemHeight,
//                   activeColor: widget.activeColor,
//                   node: widget.node,
//                   textColor: widget.textColor);
//             }));
//   }
// }

// class _ProgramsList extends StatefulWidget {
//   final List<ProgrammeInfo> programs;

//   final ProgramsBloc bloc;
//   final int? index;
//   final double? itemHeight;
//   final Color? activeColor;
//   final Color textColor;
//   final String channelId;
//   final FocusNode? node;

//   const _ProgramsList({
//     required this.channelId,
//     required this.programs,
//     required this.bloc,
//     this.index,
//     this.itemHeight,
//     this.activeColor,
//     this.node,
//     required this.textColor,
//   });

//   @override
//   _ProgramsListState createState() => _ProgramsListState();
// }

// class _ProgramsListState extends State<_ProgramsList> {
//   static const ITEM_HEIGHT = 64.0;

//   late CustomScrollController _scrollController;
//   ProgrammeInfo? programmeInfo;
//   int? _current;
//   late double _itemHeight;
//   late final List<FocusNode> _node;

//   @override
//   void initState() {
//     super.initState();
//     _node = List<FocusNode>.generate(widget.programs.length, (index) => FocusNode());
//     _itemHeight = widget.itemHeight ?? ITEM_HEIGHT;
//     _current = widget.index;
//     if (_current != null) {
//       programmeInfo = widget.programs[_current!];
//       _scrollController =
//           CustomScrollController(itemHeight: _itemHeight, initOffset: _itemHeight * _current!);
//       _initCurrentProgramSubscription();
//     } else {
//       _scrollController = CustomScrollController(
//           itemHeight: _itemHeight, initOffset: _itemHeight * widget.programs.length);
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _scrollController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final time = locator<TimeManager>();
//     return ListView.separated(
//         separatorBuilder: (BuildContext context, int index) => const SizedBox(),
//         itemCount: widget.programs.length,
//         controller: _scrollController.controller,
//         itemBuilder: (BuildContext context, int index) {
//           final program = widget.programs[index];
//           final elevation = index == _current ? 1.0 : 0.0;
//           return FutureBuilder<int>(
//               future: time.realTime(),
//               builder: (context, snapshot) {
//                 final int curUtc = snapshot.data ?? 0;
//                 final currentColor = curUtc >= program.start && curUtc < program.stop
//                     ? activeColor()
//                     : Colors.transparent;
//                 return Opacity(
//                     opacity: curUtc < program.stop ? 1.0 : 0.4,
//                     child: Material(
//                         elevation: elevation,
//                         color: Colors.transparent,
//                         child: Container(
//                             height: _itemHeight,
//                             decoration:
//                                 BoxDecoration(border: Border.all(color: currentColor, width: 1)),
//                             child: _ProgramListTile(
//                               program: program,
//                               channelId: widget.channelId,
//                               selectedColor: widget.activeColor,
//                               node: _node[index],
//                               previousFocus: () => FocusScope.of(context).requestFocus(widget.node),
//                             ))));
//               });
//         });
//   }

//   Color activeColor() => widget.activeColor ?? Theme.of(context).colorScheme.secondary;

//   void _initCurrentProgramSubscription() {
//     widget.bloc.currentProgram.listen((program) {
//       programmeInfo = program;
//       _current = widget.bloc.currentProgramIndex;
//       if (_scrollController.controller!.hasClients && _current != null) {
//         _scrollController.jumpToPosition(_current!);
//         if (mounted) {
//           setState(() {});
//         }
//       }
//     });
//   }
// }

// class _ProgramListTile extends StatefulWidget {
//   final ProgrammeInfo program;
//   final String channelId;
//   final Color? selectedColor;

//   final FocusNode node;
//   final VoidCallback previousFocus;

//   const _ProgramListTile({
//     required this.program,
//     required this.channelId,
//     this.selectedColor,
//     required this.node,
//     required this.previousFocus,
//   });

//   @override
//   _ProgramListTileState createState() {
//     return _ProgramListTileState();
//   }
// }

// class _ProgramListTileState extends State<_ProgramListTile> {
//   bool _hasTouch = true;

//   @override
//   void initState() {
//     super.initState();
//     final device = locator<RuntimeDevice>();
//     _hasTouch = device.hasTouch;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Focus(
//         focusNode: widget.node,
//         child: FocusBorder(
//             focus: widget.node,
//             child: ListTile(
//                 dense: true,
//                 // onTap: canTap ? () {} : null,
//                 title: Text(widget.program.title,
//                     style: TextStyle(fontSize: 16, color: _textColor()),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 1,
//                     softWrap: false),
//                 subtitle: Opacity(
//                     opacity: 0.6,
//                     child: Text(formatProgram(widget.program),
//                         style: TextStyle(color: _textColor()))))));
//   }

//   // private:
//   Color? _textColor() {
//     if ((_hasTouch && (isPortrait(context) || isLandscape(context))) || !_hasTouch) {
//       return null;
//     }
//     return Colors.white;
//   }

//   String formatProgram(ProgrammeInfo program) {
//     return '${date(program.start)} / ${hm(program.start)} - ${hm(program.stop)} / ${program.getDuration()}';
//   }
// }
