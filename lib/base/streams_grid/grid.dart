import 'package:fastotv_dart/commands_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_common/localization.dart';
import 'package:flutter_common/utils.dart';
import 'package:turtleott/base/animated_card.dart';
import 'package:turtleott/base/animated_list_section.dart';
import 'package:turtleott/base/bloc/content_bloc.dart';
import 'package:turtleott/base/streams_grid/search.dart';
import 'package:turtleott/pages/home/sidebar_tile.dart';
import 'package:turtleott/service_locator.dart';
import 'package:turtleott/shared_prefs.dart';

abstract class ITvStreamsGridNotification extends Notification {
  const ITvStreamsGridNotification();
}

class FocusedHeader extends ITvStreamsGridNotification {
  final bool hasFocus;

  const FocusedHeader(this.hasFocus);
}

class FocusedCardPosition extends ITvStreamsGridNotification {
  final double top;
  final double bottom;

  const FocusedCardPosition(this.top, this.bottom);
}

abstract class TvStreamsGrid<T> extends StatefulWidget {
  static const double sidePadding = SidebarTile.iconWidth / 2;
  static const EdgeInsets BASE_PADDING =
      EdgeInsets.symmetric(horizontal: TvStreamsGrid.sidePadding, vertical: 32);

  final List<OttPackageInfo> content;
  final bool isVods;

  const TvStreamsGrid(this.content, this.isVods);
}

const int GRID_COLUMNS = 6;

bool _isUpdateTable = true;

abstract class TvStreamsGridState<T, S extends TvStreamsGrid<T>> extends State<S> {
  OttPackageInfo? currentCategory;

  String searchTerm = '';

  String get searchTitle;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double _currentScrollPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ITvStreamsGridNotification>(
        onNotification: (notification) {
          if (notification is FocusedHeader) {
            _animate(notification.hasFocus ? 0 : 34 + 32 * 2);
          } else if (notification is FocusedCardPosition) {
            if (notification.bottom >= MediaQuery.of(context).size.height) {
              _jump(TvStreamsGrid.sidePadding / 2);
            } else if (notification.top <= 0) {
              _jump(-TvStreamsGrid.sidePadding / 2);
            }
          }
          return true;
        },
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (widget.content.isEmpty)
            const SizedBox()
          else
            BlocBuilder<ContentBloc, ContentState>(builder: (context, state) {
              final content = SizedBox(
                  width: (MediaQuery.of(context).size.width * 90) / 100,
                  child: AnimatedListSection<String>(
                      items: _buildCategoryList(widget.content, context, widget.isVods),
                      itemBuilder: (String section) {
                        return Text(tryTranslate(context, AppLocalizations.toUtf8(section)));
                      },
                      contentBuilder: (category) {
                        if (_isUpdateTable) _moveToStart();

                        for (final pack in widget.content) {
                          if (pack.name == category) {
                            currentCategory = pack;
                          }
                        }
                        final tmp = _streams();
                        return Stack(children: [
                          Column(children: [
                            Expanded(
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                  GridSearch(
                                      title: searchTitle,
                                      onSearch: (isSearch) {
                                        if (!isSearch && searchTerm.isNotEmpty) {
                                          setState(() {
                                            searchTerm = '';
                                          });
                                        }
                                      },
                                      onSearchChanged: (term) {
                                        setState(() {
                                          searchTerm = term;
                                        });
                                      })
                                ])),
                            Expanded(
                                flex: 5,
                                child: GridView.builder(
                                    controller: _scrollController,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: GRID_COLUMNS,
                                      childAspectRatio: 1 / 2,
                                    ),
                                    itemBuilder: (_, int index) {
                                      final T stream = tmp[index];

                                      return Padding(
                                        padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
                                        child: _Card(
                                          viewCount: const SizedBox(),
                                          index: index,
                                          name: getNameFromItem(stream),
                                          icon: getIconFromItem(stream),
                                          onTap: () {
                                            _navigate(stream);
                                            _isUpdateTable = false;
                                          },
                                          onMenu: () {},
                                          mayScrollDown: _mayScrollDown(
                                            currentIndex: index,
                                            listSize: tmp.length,
                                          ),
                                          positionChanging: () {
                                            if (_currentScrollPosition.toStringAsFixed(2) !=
                                                _scrollController.offset.toStringAsFixed(2)) {
                                              _Card.isUpRowOdd = !_Card.isUpRowOdd;
                                            }
                                            _currentScrollPosition = _scrollController.offset;
                                          },
                                        ),
                                      );
                                    },
                                    itemCount: tmp.length))
                          ])
                        ]);
                      }));
              return content;
            })
        ]));
  }

  List<String> _buildCategoryList(
      List<OttPackageInfo> packageContent, BuildContext context, bool isVods) {
    final List<String> categories = [];
    for (final OttPackageInfo in packageContent) {
      if (OttPackageInfo.name.isNotEmpty) {
        categories.add(OttPackageInfo.name);
      }
    }
    return categories;
  }

  void _moveToStart() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position.minScrollExtent;
    _scrollController.jumpTo(position);

    _currentScrollPosition = _scrollController.offset;

    _Card.isUpRowOdd = false;
  }

  bool _mayScrollDown({required int currentIndex, required int listSize}) {
    final modulo = listSize % GRID_COLUMNS;
    final actualSize = listSize - (modulo != 0 ? modulo : GRID_COLUMNS);
    return currentIndex + 1 <= actualSize;
  }

  Widget pushPage(T stream);
  String getNameFromItem(T item);
  String getIconFromItem(T item);

  bool _compare(T item, String word) {
    final stabled = AppLocalizations.toUtf8(getNameFromItem(item));
    return stabled.toLowerCase().contains(word.toLowerCase());
  }

  List<T> _streams() {
    if (widget.isVods) {
      final List<T> vods = [];
      for (final vod in currentCategory?.vods ?? []) {
        if (_compare(vod, searchTerm)) {
          vods.add(vod);
        }
      }
      return vods;
    } else {
      final List<T> series = [];
      for (final serial in currentCategory?.serials ?? []) {
        if (_compare(serial, searchTerm)) {
          series.add(serial);
        }
      }
      return series;
    }
  }

  void _animate(double offset) {
    if (_scrollController.offset != offset) {
      _scrollController.animateTo(offset,
          duration: const Duration(milliseconds: 100), curve: Curves.linear);
    }
  }

  void _jump(double diff) {
    _scrollController.jumpTo(_scrollController.offset + diff);
  }

  void _navigate(T stream) {
    Navigator.of(context).push<bool>(MaterialPageRoute(builder: (context) {
      return pushPage(stream);
    }));
  }
}

class _Card extends StatelessWidget {
  final String name;
  final String icon;
  final Widget viewCount;

  final VoidCallback onTap, onMenu;
  final bool mayScrollDown;
  final int index;
  final Function positionChanging;

  _Card(
      {required this.name,
      required this.icon,
      required this.onTap,
      required this.onMenu,
      this.mayScrollDown = true,
      required this.index,
      required this.positionChanging,
      required this.viewCount});

  static bool isUpRowOdd = false, canDown = true;

  final settings = locator<LocalStorageService>();
  final FocusNode focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(children: [
        AnimatedCard(
          imageFit: BoxFit.cover,
          icon: icon,
          title: '',
          onTap: onTap,
          onKey: (event) {
            final result = onKey(event, (key) {
              switch (key) {
                case KeyConstants.BACKSPACE:
                case KeyConstants.FAVORITE:
                case KeyConstants.MENU:
                  _isUpdateTable = false;
                  focus.requestFocus();
                  //alertDialog(context, vod, onMenu);
                  return KeyEventResult.handled;
                case KeyConstants.KEY_LEFT:
                  return _backHandling(context);
                case KeyConstants.BACK:
                  int i = index % GRID_COLUMNS;
                  while (i >= 1) {
                    --i;
                    FocusScope.of(context).focusInDirection(TraversalDirection.left);
                  }
                  return _backHandling(context, i);
                case KeyConstants.KEY_UP:
                  _isUpdateTable = true;
                  positionChanging();
                  return FocusScope.of(context).focusInDirection(TraversalDirection.up)
                      ? KeyEventResult.handled
                      : KeyEventResult.ignored;
                case KeyConstants.KEY_DOWN:
                  _isUpdateTable = true;
                  positionChanging();
                  if (mayScrollDown) {
                    if (canDown) {
                      canDown = false;
                      Future.delayed(const Duration(milliseconds: 10), () {
                        FocusScope.of(context).focusInDirection(TraversalDirection.down);
                        canDown = true;
                      });
                    }
                  }

                  return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            });

            return result == KeyEventResult.handled;
          },
          subtitle: viewCount,
        ),
      ]);
    });
  }

  KeyEventResult _backHandling(BuildContext context, [int? backIndex]) {
    _isUpdateTable = true;
    final i = backIndex ?? index;
    if (i % GRID_COLUMNS != 0) return KeyEventResult.ignored;
    positionChanging();

    if (!isUpRowOdd) {
      if ((index ~/ GRID_COLUMNS) % 2 != 0) {
        FocusScope.of(context).focusInDirection(TraversalDirection.up);
      }
    } else {
      if ((index ~/ GRID_COLUMNS) % 2 == 0) {
        FocusScope.of(context).focusInDirection(TraversalDirection.up);
      }
    }

    FocusScope.of(context).focusInDirection(TraversalDirection.left);
    return KeyEventResult.handled;
  }

  /*void alertDialog(BuildContext context, T stream, Function onMenu) {
    showDialog(
        useRootNavigator: false,
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
              backgroundColor: Colors.black.withOpacity(0.5),
              contentPadding: const EdgeInsets.all(5),
              content: SizedBox(
                  height: 42,
                  child: Column(children: [
                    InkWell(
                        onTap: () {
                          _hideVideo(stream);
                          onMenu();
                          Navigator.of(context).pop();
                        },
                        child: Focus(
                            focusNode: focus,
                            child: FocusBorder(
                                focus: focus,
                                color: Colors.white,
                                child: Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    child: SvgPicture.asset(
                                        'install/assets/icons/eye-svgrepo-com.svg',
                                        height: 30,
                                        color: Colors.white),
                                  ),
                                  Text(translate(context, TR_HIDE),
                                      style: const TextStyle(color: Colors.white))
                                ]))))
                  ])));
        });
  }

  void _hideVideo(T stream) {
    final settings = locator<LocalStorageService>();
    final key = stream is VodStream ? moviesKey : seriesKey;
    final categories = settings.getList(key);
    List<String> list = [];
    if (categories != null) {
      list = categories;
    }
    list.add(stream is VodStream ? stream.displayName() : (stream as SerialStream).displayName());
    settings.saveList(key, list);
  }*/
}
