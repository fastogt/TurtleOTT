import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/flutter_common.dart';
import 'package:turtleott/localization/translations.dart';
import 'package:turtleott/utils/theme.dart';

abstract class CustomSearchDelegate<T extends IDisplayContentInfo> extends SearchDelegate {
  final List<T> streams;
  final String hint;
  final OttPackageInfo package;

  CustomSearchDelegate(this.streams, this.hint, this.package) : super(searchFieldLabel: hint);

  @override
  List<Widget> buildActions(BuildContext context) {
    return query.isNotEmpty
        ? [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')]
        : [];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = streams.where(resultsCriteria);
    if (query.isEmpty || results.isEmpty) {
      return _NothingFound();
    }

    return list(results.toList(), context, package);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = streams.where(suggestionsCriteria);
    if (query.isEmpty || results.isEmpty) {
      return _NothingFound();
    }

    return list(results.toList(), context, package);
  }

  bool resultsCriteria(T s) =>
      AppLocalizations.toUtf8(s.displayName()).toLowerCase().contains(query);

  bool suggestionsCriteria(T s) =>
      AppLocalizations.toUtf8(s.displayName()).toLowerCase().contains(query);

  Widget list(List<T> results, BuildContext context, OttPackageInfo package);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = Theming.onCustomColor(Theme.of(context).primaryColor);
    return theme.copyWith(
        appBarTheme: AppBarTheme(
            backgroundColor: theme.primaryColor,
            iconTheme: theme.primaryIconTheme.copyWith(color: textColor)),
        textTheme: Theme.of(context).textTheme.copyWith(titleLarge: TextStyle(color: textColor)),
        inputDecorationTheme: searchFieldDecorationTheme ??
            InputDecorationTheme(
                hintStyle: searchFieldStyle ?? TextStyle(color: textColor),
                border: InputBorder.none));
  }
}

class _NothingFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child:
            NonAvailableBuffer(icon: Icons.search, message: translate(context, TR_SEARCH_EMPTY)));
  }
}
