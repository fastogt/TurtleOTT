import 'package:flutter/material.dart';
import 'package:turtleott/utils/theme.dart';

class VodCardViews extends StatelessWidget {
  final int count;

  const VodCardViews(this.count);

  @override
  Widget build(BuildContext context) {
    final color = Theming.of(context).onPrimary();
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Icon(Icons.visibility, color: color),
          Text(' $count', style: TextStyle(color: color))
        ]));
  }
}

class VodAgeView extends StatelessWidget {
  final int iarc;

  const VodAgeView(this.iarc);

  @override
  Widget build(BuildContext context) {
    final color = Theming.of(context).onPrimary();
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Icon(Icons.child_care, color: color),
          Text(' $iarc+', style: TextStyle(color: color))
        ]));
  }
}
