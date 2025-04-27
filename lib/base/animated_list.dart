import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/base/scale.dart';

class AnimatedSelectionList<T> extends StatefulWidget {
  final List<T> items;
  final int initItem;
  final void Function(T newItem)? onChanged;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final void Function(T item)? onItem;
  final double topPadding;
  final double itemHeight;
  final EdgeInsets itemPadding;
  final Widget Function(BuildContext context, T item, bool hasFocus)? underline;

  const AnimatedSelectionList(
      {required this.items,
      required this.itemBuilder,
      this.initItem = 0,
      this.topPadding = 200,
      this.itemHeight = 56,
      this.itemPadding = const EdgeInsets.all(16.0),
      this.onItem,
      this.onChanged,
      this.underline,
      Key? key})
      : super(key: key);

  @override
  _AnimatedSelectionListState createState() => _AnimatedSelectionListState<T>();
}

class _AnimatedSelectionListState<T> extends State<AnimatedSelectionList<T>> {
  final FocusScopeNode _scope = FocusScopeNode();
  final StreamController<int> _updates = StreamController<int>();
  late ScrollController _scrollController;
  late int selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initItem;
    _scrollController = ScrollController(initialScrollOffset: widget.itemHeight * selected);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scope.dispose();
    _updates.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return FocusScope(
          node: _scope,
          child: Stack(children: [
            Padding(
                padding: EdgeInsets.only(left: constraints.maxWidth),
                child: const VerticalDivider(width: 0)),
            AutoScaleWidget(
                node: _scope,
                builder: (_) {
                  return Container(color: Colors.transparent);
                }),
            FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
                child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                        top: widget.topPadding,
                        bottom: MediaQuery.of(context).size.height -
                            widget.topPadding -
                            widget.itemHeight),
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                          height: widget.itemHeight,
                          child: Padding(
                              padding: widget.itemPadding,
                              child: _TileWrap(
                                  onKey: _onTile,
                                  onFocusChanged: (hasFocus) {
                                    if (hasFocus) {
                                      _updateSelection(index);
                                    }
                                  },
                                  builder: (context, hasFocus) {
                                    if (index == selected) {
                                      return DefaultTextStyle(
                                          style: DefaultTextStyle.of(context).style.copyWith(
                                              color: Theme.of(context).colorScheme.secondary),
                                          child: widget.itemBuilder(context, widget.items[index]));
                                    }
                                    return widget.itemBuilder(context, widget.items[index]);
                                  })));
                    })),
            Positioned(
                top: widget.topPadding + widget.itemHeight - 1,
                left: 0,
                right: 0,
                child: AutoScaleWidget(
                    xScale: 1,
                    // avoid X-axis scaling
                    yScale: 2,
                    node: _scope,
                    primaryFocus: false,
                    builder: (hasFocus) {
                      if (widget.underline != null) {
                        return StreamBuilder<int>(
                            initialData: selected,
                            stream: _updates.stream,
                            builder: (context, _) {
                              return widget.underline!
                                  .call(context, widget.items[selected], hasFocus);
                            });
                      }
                      return Container(
                          color: hasFocus ? Theme.of(context).colorScheme.secondary : Colors.white,
                          height: 2);
                    }))
          ]));
    });
  }

  KeyEventResult _onTile(RawKeyEvent event) {
    return onKey(event, (key) {
      switch (key) {
        case KeyConstants.ENTER:
        case KeyConstants.KEY_CENTER:
          if (widget.onItem != null) {
            widget.onItem!.call(widget.items[selected]);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        case KeyConstants.KEY_UP:
          return _scope.focusInDirection(TraversalDirection.up)
              ? KeyEventResult.handled
              : KeyEventResult.ignored;
        case KeyConstants.KEY_DOWN:
          return _scope.focusInDirection(TraversalDirection.down)
              ? KeyEventResult.handled
              : KeyEventResult.ignored;
        case KeyConstants.KEY_RIGHT:
          return FocusScope.of(context).focusInDirection(TraversalDirection.right)
              ? KeyEventResult.handled
              : KeyEventResult.ignored;
        case KeyConstants.KEY_LEFT:
          return FocusScope.of(context).focusInDirection(TraversalDirection.left)
              ? KeyEventResult.handled
              : KeyEventResult.ignored;
      }
      return KeyEventResult.ignored;
    });
  }

  void _updateSelection(int index) {
    selected = index;
    _updates.add(selected);
    widget.onChanged?.call(widget.items[selected]);
    _scrollController.animateTo(widget.itemHeight * index,
        duration: const Duration(milliseconds: 100), curve: Curves.linear);
  }
}

class _TileWrap extends StatefulWidget {
  final Widget Function(BuildContext context, bool hasFocus) builder;
  final void Function(bool hasFocus) onFocusChanged;
  final KeyEventResult Function(RawKeyEvent event) onKey;

  const _TileWrap({required this.builder, required this.onKey, required this.onFocusChanged});

  @override
  _TileState createState() => _TileState();
}

class _TileState extends State<_TileWrap> {
  final FocusNode _node = FocusNode();

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        focusNode: _node,
        onKey: (_, event) => widget.onKey(event),
        onFocusChange: widget.onFocusChanged,
        child: AutoScaleWidget(
            alignment: Alignment.centerLeft,
            node: _node,
            builder: (hasFocus) {
              return DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: hasFocus
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: hasFocus ? FontWeight.bold : FontWeight.normal),
                  child: Builder(builder: (context) {
                    return widget.builder(context, hasFocus);
                  }));
            }));
  }
}
