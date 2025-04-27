import 'package:flutter/material.dart';

typedef FavoriteCallback = void Function(bool favorite);

class FavoriteStarButton extends StatefulWidget {
  final Color? selectedColor;
  final Color? unselectedColor;
  final FavoriteCallback? onFavoriteChanged;
  final bool initFavorite;
  final FocusNode? focusNode;

  const FavoriteStarButton(this.initFavorite,
      {this.selectedColor, this.unselectedColor, this.onFavoriteChanged, this.focusNode});

  @override
  _FavoriteStarButtonState createState() {
    return _FavoriteStarButtonState();
  }
}

class _FavoriteStarButtonState extends State<FavoriteStarButton> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initFavorite;
  }

  @override
  void didUpdateWidget(FavoriteStarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isFavorite = widget.initFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.selectedColor ?? Theme.of(context).colorScheme.secondary;
    final unselectedColor = widget.unselectedColor ?? Theme.of(context).primaryIconTheme.color;
    return IconButton(
        focusNode: widget.focusNode,
        padding: const EdgeInsets.all(0.0),
        onPressed: () {
          _setFavorite(!_isFavorite);
        },
        icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
        color: _isFavorite ? selectedColor : unselectedColor);
  }

  void _setFavorite(bool favorite) {
    setState(() {
      _isFavorite = favorite;
      widget.onFavoriteChanged?.call(favorite);
    });
  }
}
