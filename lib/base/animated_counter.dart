import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';

class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({required this.onChanged, this.autofocus = false, Key? key})
      : super(key: key);

  final bool autofocus;
  final void Function(int? value) onChanged;
  static const double size = 36;

  @override
  _AnimatedCounterState createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> {
  int? value;
  final FocusNode _node = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool get selected => _node.hasFocus;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _node.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
        autofocus: widget.autofocus,
        focusNode: _node,
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            _setValue(value ?? 0);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.jumpTo(AnimatedCounter.size * value!);
            });
          }
          setState(() {});
        },
        onKey: (node, event) {
          return onKey(event, (int key) {
            switch (key) {
              case KeyConstants.KEY_UP:
                if (value! > 0) {
                  value = value! - 1;
                  widget.onChanged(value!);
                  _scroll();
                } else {
                  FocusScope.of(context).focusInDirection(TraversalDirection.up);
                }
                return KeyEventResult.handled;
              case KeyConstants.KEY_DOWN:
                if (value! < 9) {
                  value = value! + 1;
                  widget.onChanged(value!);
                  _scroll();
                } else {
                  FocusScope.of(context).focusInDirection(TraversalDirection.down);
                }
                return KeyEventResult.handled;
              case KeyConstants.KEY_RIGHT:
                FocusScope.of(context).focusInDirection(TraversalDirection.right);
                return KeyEventResult.handled;
              case KeyConstants.KEY_LEFT:
                FocusScope.of(context).focusInDirection(TraversalDirection.left);
                _setValue(null);
                return KeyEventResult.handled;
              default:
                return KeyEventResult.ignored;
            }
          });
        },
        child: SizedBox(
            height: AnimatedCounter.size * 3, width: AnimatedCounter.size, child: _content()));
  }

  Widget _content() {
    if (_node.hasFocus) {
      return _Counter(_scrollController);
    } else {
      return value == null ? const _Dash() : const _Dot();
    }
  }

  void _setValue(int? newValue) {
    value = newValue;
    widget.onChanged(value);
  }

  void _scroll() {
    _scrollController.animateTo(AnimatedCounter.size * value!,
        duration: const Duration(milliseconds: 100), curve: Curves.linear);
  }
}

class _Dash extends StatelessWidget {
  const _Dash({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Divider()));
  }
}

class _Counter extends StatefulWidget {
  const _Counter(this.controller);

  final ScrollController controller;

  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  final StreamController<int> _selected = StreamController<int>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    _selected.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Center(
          child: Container(
              color: Theme.of(context).colorScheme.secondary,
              height: AnimatedCounter.size,
              width: AnimatedCounter.size)),
      Positioned.fill(
          child: StreamBuilder<int>(
              initialData: 0,
              stream: _selected.stream,
              builder: (context, snapshot) {
                return ListView(
                    controller: widget.controller,
                    children: List<Widget>.generate(10 + 2, (index) {
                      if (index == 0 || index == 11) {
                        return const SizedBox(
                            height: AnimatedCounter.size, width: AnimatedCounter.size);
                      }
                      final bool selected = index - 1 == snapshot.data!;
                      return SizedBox(
                          height: AnimatedCounter.size,
                          width: AnimatedCounter.size,
                          child: Center(
                              child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 50),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: selected ? Colors.white : Colors.black),
                                  child: Text('${index - 1}'))));
                    }));
              }))
    ]);
  }

  void _update() {
    _selected.add(widget.controller.position.extentBefore ~/ AnimatedCounter.size);
  }
}

class _Dot extends StatelessWidget {
  const _Dot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            margin: const EdgeInsets.all(AnimatedCounter.size / 3),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary, shape: BoxShape.circle)));
  }
}
