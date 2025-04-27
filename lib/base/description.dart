import 'package:flutter/material.dart';
import 'package:flutter_common/localization.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/base/animated_text_button.dart';
import 'package:turtleott/base/streams_grid/grid.dart';
import 'package:turtleott/localization/translations.dart';

class StreamDesription extends StatefulWidget {
  final String title;
  final StreamInformation information;
  final String? description;
  final List<Widget> actions;

  const StreamDesription(
      {required this.title,
      required this.description,
      required this.information,
      required this.actions});

  @override
  _StreamDesriptionState createState() => _StreamDesriptionState();
}

class _StreamDesriptionState extends State<StreamDesription> {
  bool _visible = true;
  final TextStyle _textStyle = const TextStyle(fontSize: 20);
  final FocusNode focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_visible) ...[
          Row(children: widget.actions),
          Row(children: [Expanded(child: Divider(color: Colors.blueGrey[800]))]),
          const SizedBox(height: 4)
        ],
        Text(AppLocalizations.toUtf8(widget.title),
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontSize: 30, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (_visible) ...[widget.information, const SizedBox(height: 16)]
      ]),
      Flexible(
          child: Row(children: [
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(translate(context, TR_DESCRIPTION),
              style: const TextStyle(fontSize: 20, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(AppLocalizations.toUtf8(widget.description ?? ''),
              style: _textStyle,
              softWrap: true,
              maxLines: _visible ? 2 : null,
              overflow: _visible ? TextOverflow.ellipsis : null)
        ])),
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          AnimatedTextButton(
            title: _visible
                ? '${translate(context, TR_MORE_DESCRIPTION)} >>'
                : translate(context, TR_CLOSE),
            onPressed: showDescription,
          ),
        ])
      ])),
      const SizedBox(height: TvStreamsGrid.sidePadding / 4)
    ]);
  }

  void showDescription() {
    setState(() {
      _visible = !_visible;
    });
  }
}

class StreamInformation extends StatelessWidget {
  final List<String> categories;
  final List<String>? other;
  final double? score;

  const StreamInformation({required this.categories, this.other, this.score});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (other != null || categories.isNotEmpty)
        Expanded(child: Text(_combineAll(), style: const TextStyle(fontSize: 20), softWrap: true)),
      if (score != null) _score()
    ]);
  }

  Widget _score() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Image.asset('install/assets/imdb.png', height: 20),
      const SizedBox(width: 5),
      Text('$score/10')
    ]);
  }

  String _combineAll() {
    final StringBuffer _result = StringBuffer();
    if (other != null) {
      for (final String item in other!) {
        _result.writeAll([AppLocalizations.toUtf8(item), ' \u2022 ']);
      }
    }
    for (int i = 0; i < categories.length; i++) {
      final String category = categories[i];
      if (category != TR_RECENT && category != TR_FAVORITE && category != TR_ALL) {
        _result.write(AppLocalizations.toUtf8(category));
        if (i != categories.length - 1) {
          _result.write(', ');
        }
      }
    }
    return _result.toString();
  }
}
