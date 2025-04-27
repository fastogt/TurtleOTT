import 'dart:async';

import 'package:flutter/material.dart';
import 'package:turtleott/base/animated_list.dart';

class AnimatedListSection<T> extends StatefulWidget {
  const AnimatedListSection(
      {required this.items,
      required this.itemBuilder,
      required this.contentBuilder,
      this.onItem,
      this.listWidth = 180});

  final List<T> items;
  final Widget Function(T value) itemBuilder;
  final Widget Function(T value) contentBuilder;
  final void Function(T value)? onItem;
  final double listWidth;

  @override
  _AnimatedListSectionState<T> createState() => _AnimatedListSectionState<T>();
}

class _AnimatedListSectionState<T> extends State<AnimatedListSection<T>> {
  final StreamController<T> _categoryUpdates = StreamController<T>();

  @override
  void initState() {
    super.initState();
    _categoryUpdates.add(widget.items.first);
  }

  @override
  void dispose() {
    _categoryUpdates.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SizedBox(
          width: widget.listWidth,
          child: AnimatedSelectionList<T>(
              items: widget.items,
              onChanged: _categoryUpdates.add,
              onItem: (T item) {
                widget.onItem?.call(item);
              },
              itemBuilder: (_, T value) {
                return widget.itemBuilder(value);
              })),
      Expanded(
          child: StreamBuilder<T>(
              stream: _categoryUpdates.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return widget.contentBuilder(snapshot.data!);
                }
                return const SizedBox();
              }))
    ]);
  }
}
