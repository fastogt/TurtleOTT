import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/base/scale.dart';

class CategoriesDropdown extends StatefulWidget {
  final String value;
  final List<String> categories;
  final void Function(String value) onChanged;

  const CategoriesDropdown(
      {required this.value, required this.categories, required this.onChanged});

  @override
  _CategoriesDropdownState createState() => _CategoriesDropdownState();
}

class _CategoriesDropdownState extends State<CategoriesDropdown> with TickerProviderStateMixin {
  final FocusNode _node = FocusNode();
  final FocusNode _buttonNode = FocusNode(skipTraversal: true);
  final GlobalKey _key = GlobalKey();

  List<String> get categories => widget.categories;

  @override
  void dispose() {
    _node.dispose();
    _buttonNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// needed to overcome [Textfield] bug
    final style = Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 18);
    return Focus(
        focusNode: _node,
        onKey: (node, event) => onKeyArrows(context, event, onEnter: _openDropdown),
        child: AutoScaleWidget(
            node: _node,
            builder: (hasFocus) {
              final selectedColor = Theme.of(context).colorScheme.onPrimary;
              return Card(
                  color: _node.hasFocus
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.all(0),
                  child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                              key: _key,
                              focusNode: _buttonNode,
                              focusColor: Colors.transparent,
                              value: widget.value,
                              onChanged: (String? newValue) {
                                widget.onChanged(newValue!);
                              },
                              icon: Icon(Icons.keyboard_arrow_down, color: selectedColor, size: 32),
                              selectedItemBuilder: (context) {
                                return List<DropdownMenuItem<String>>.generate(categories.length,
                                    (index) {
                                  final String cat = categories[index];
                                  return DropdownMenuItem<String>(
                                      child: Text(tryTranslate(context, cat),
                                          style: style.copyWith(color: selectedColor)),
                                      value: cat);
                                });
                              },
                              items: List<DropdownMenuItem<String>>.generate(categories.length,
                                  (index) {
                                final String cat = categories[index];
                                return DropdownMenuItem<String>(
                                    child: Text(tryTranslate(context, cat),
                                        style: style.copyWith(
                                            color: Theme.of(context).colorScheme.secondary)),
                                    value: cat);
                              })))));
            }));
  }

  void _openDropdown() {
    _key.currentContext!.visitChildElements((element) {
      if (element.widget is Semantics) {
        element.visitChildElements((element) {
          if (element.widget is Actions) {
            element.visitChildElements((element) {
              Actions.invoke(element, const ActivateIntent());
            });
          }
        });
      }
    });
  }
}
