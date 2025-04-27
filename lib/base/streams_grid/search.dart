import 'package:flutter/material.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/base/login/textfields.dart';
import 'package:turtleott/base/round_button.dart';
import 'package:turtleott/base/streams_grid/grid.dart';

class GridSearch extends StatefulWidget {
  final String title;
  final void Function(bool isSearch)? onSearch;
  final void Function(String term) onSearchChanged;

  const GridSearch({required this.title, required this.onSearchChanged, this.onSearch});

  @override
  _GridSearchState createState() => _GridSearchState();
}

class _GridSearchState extends State<GridSearch> {
  bool isSearch = false;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      RoundedButton(
          icon: isSearch ? Icons.search_off : Icons.search,
          onTap: () {
            setState(() {
              isSearch = !isSearch;
            });
            widget.onSearch?.call(isSearch);
          }),
      SizedBox(width: TvStreamsGrid.BASE_PADDING.left / 2),
      if (isSearch)
        SizedBox(
            width: 256,
            child: LoginTextField(
                canBeEmpty: true,
                padding: const EdgeInsets.all(0),
                hintText: tryTranslate(context, widget.title),
                onFieldSubmit: widget.onSearchChanged))
    ]);
  }
}
