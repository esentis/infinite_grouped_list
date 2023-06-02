import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

/// The sort order of the items inside the groups.
enum SortOrder { ascending, descending }

/// This is the controller for the [InfiniteGroupedList].
///
/// You can use it to :
///
/// * refresh the list
/// * get the items in the list
class InfiniteGroupedListController<ItemType, GroupBy, GroupTitle> {
  /// Call this function to refresh the list.
  late VoidCallback refresh;

  /// Call this function to get the items in the list.
  late List<ItemType> Function() getItems;

  /// Retry the last failed load more call.
  late Future<void> Function() retry;

  InfiniteGroupedListController();
}

/// A list of items that are grouped and infinite.
///
/// This list fetches data in chunks, creating an "infinite scroll" experience for
/// the user. Additionally, the items are grouped based on a grouping criterion
/// provided by the developer.
///
/// `ItemType` is the type of item in the list. For instance, if your list displays
/// Users, ItemType would be User.
///
/// `GroupBy` is the type of value used to group the items. This could be any type
/// as long as it can be derived from ItemType. For instance, if you are grouping
/// Users by their city, GroupBy would be String.
///
/// `GroupTitle` is the type of the group title. This is derived from GroupBy values.
/// For example, you could have GroupBy be DateTime (representing user birthdays) and
/// have GroupTitle be String, if you want to display the birthdays as string titles.
class InfiniteGroupedList<ItemType, GroupBy, GroupTitle>
    extends StatefulWidget {
  /// Constructs an instance of InfiniteGroupedList.
  ///
  /// This requires several callback parameters:
  /// * [onLoadMore]: Fetches more items to be added to the list. This function is
  ///   expected to return a Future that completes with a List<ItemType>.
  /// * [itemBuilder]: Builds the widget for each item in the list.
  /// * [seperatorBuilder]: Builds the separator widget between items.
  /// * [groupTitleBuilder]: Builds the widget for the title of each group.
  /// * [groupBy]: Determines the GroupBy value for each item.
  /// * [groupCreator]: Determines the GroupTitle for each group.
  /// * [sortGroupBy]: Determines the sorting of items within each group.
  ///
  /// The list behavior can be further customized with optional parameters like
  /// [controller], [onRefresh], [padding], [noItemsFoundWidget],
  /// [initialItemsErrorWidget], [loadMoreItemsErrorWidget], [groupSortOrder],
  /// [loadingWidget], [refreshIndicatorColor], and
  /// [refreshIndicatorBackgroundColor].
  const InfiniteGroupedList({
    required this.onLoadMore,
    required this.itemBuilder,
    required this.seperatorBuilder,
    required this.groupTitleBuilder,
    required this.groupBy,
    required this.groupCreator,
    required this.sortGroupBy,
    this.controller,
    this.onRefresh,
    this.padding,
    this.noItemsFoundWidget,
    this.initialItemsErrorWidget,
    this.loadMoreItemsErrorWidget,
    this.groupSortOrder = SortOrder.descending,
    this.stickyGroups = true,
    this.loadingWidget = const Center(
      child: CircularProgressIndicator(),
    ),
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,
    super.key,
  });

  /// The controller of the list.
  ///
  /// You can use it to refresh the list or get the items in the list.
  final InfiniteGroupedListController<ItemType, GroupBy, GroupTitle>?
      controller;

  /// Fetches more items to be added to the list. This function is expected to return a Future that completes with a List<ItemType>.
  /// The function is called each time the list is scrolled to its end and more items need to be loaded.
  ///
  /// This function is responsible for determining the "offset" or "page" of data to fetch, based on the data it has already fetched.
  /// Typically, the function should keep track of the number of successful fetches it has made, and use that number to determine
  /// what data to fetch next.
  ///
  /// If a fetch fails (that is, if the function throws an exception), it's the function's responsibility to remember this and try to
  /// fetch the same data again the next time it's called. This typically involves keeping track of the last failed fetch.
  ///
  /// Here's an example of how you might implement this:
  ///
  /// ```dart
  /// int offset = 0;
  /// final List<ItemType> items = [];
  /// bool fetchFailed = false;
  ///
  /// Future<List<ItemType>> onLoadMore() async {
  ///   try {
  ///     List<ItemType> newItems = await fetchItems(offset);
  ///     items.addAll(newItems);
  ///     offset++;
  ///     fetchFailed = false;
  ///   } catch (e) {
  ///     fetchFailed = true;
  ///     // Handle error (e.g., show a message to the user)
  ///   }
  ///
  ///   if (!fetchFailed) {
  ///     offset++;
  ///   }
  ///
  ///   return items;
  /// }
  /// ```
  final Future<List<ItemType>> Function() onLoadMore;

  /// The item builder is used to build the item.
  final Widget Function(ItemType item) itemBuilder;

  /// The seperator builder is used to build the seperator between items.
  final Widget Function(ItemType item) seperatorBuilder;

  /// Optionally if you want to do something when the user pulls to refresh.
  final VoidCallback? onRefresh;

  /// The group title builder is used to build the title of the group.
  ///
  /// The first parameter is the title of the group as created from [groupCreator], the second parameter is the [groupBy] value.
  ///
  /// The [groupBy] is the first item of the group, in case you want to use it to build the title.
  ///
  /// The third parameter is a boolean that indicates if the group is pinned or not.
  ///
  /// The fourth parameter is the scroll percentage of the group title. 0 means the group title is at the top of the screen, 1 means the group title is at the bottom of the screen.
  final Widget Function(
    GroupTitle title,
    GroupBy groupBy,
    bool isPinned,
    double scrollPercentage,
  ) groupTitleBuilder;

  /// The widget to show when the list is loading.
  final Widget loadingWidget;

  /// The widget to show when the list is empty.
  final Widget? noItemsFoundWidget;

  /// The widget to show when the first load call fails
  final Widget? initialItemsErrorWidget;

  /// The widget to show when the load call fails.
  ///
  /// This will be shown at the bottom of the list.
  final Widget? loadMoreItemsErrorWidget;

  /// Using this function you can return the field you want to group by.
  final GroupBy Function(ItemType item) groupBy;

  /// Using this function you can return the title of the group.
  final GroupTitle Function(GroupBy groupBy) groupCreator;

  /// You can define the field of which the items inside the groups should be sorted by.
  final void Function(ItemType sortGroupBy) sortGroupBy;

  /// The sort order of the items inside the groups.
  final SortOrder groupSortOrder;

  /// The padding of the list
  final EdgeInsets? padding;

  /// The color of the refresh indicator
  final Color? refreshIndicatorColor;

  /// The background color of the refresh indicator
  final Color? refreshIndicatorBackgroundColor;

  /// Whether the grpup should stick to the top of the screen when scrolling up.
  final bool stickyGroups;
  @override
  InfiniteGroupedListState<ItemType, GroupBy, GroupTitle> createState() =>
      InfiniteGroupedListState();
}

class InfiniteGroupedListState<ItemType, GroupBy, GroupTitle>
    extends State<InfiniteGroupedList<ItemType, GroupBy, GroupTitle>> {
  bool loading = true;
  bool hasError = false;

  bool stillHasItems = true;

  final ScrollController _scrollController = ScrollController();

  final List<ItemType> _items = [];

  late Map<GroupTitle, List<ItemType>> groupedItems = groupItems(_items);

  late List<GroupTitle> groupTitles = groupedItems.keys.toList();

  Future<void> _initList() async {
    if (!loading) {
      setState(() {
        loading = true;
        hasError = false;
      });
    }
    try {
      final items = await widget.onLoadMore();

      _items.addAll(items);

      groupedItems = groupItems(_items);

      groupTitles = groupedItems.keys.toList();

      setState(() {
        loading = false;
      });
    } catch (e) {
      hasError = true;
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    _items.clear();
    widget.onRefresh?.call();
    stillHasItems = true;
    hasError = false;
    setState(() {
      loading = true;
    });

    try {
      final items = await widget.onLoadMore();

      _items.addAll(items);

      groupedItems = groupItems(_items);

      groupTitles = groupedItems.keys.toList();

      setState(() {
        loading = false;
      });
    } catch (e) {
      hasError = true;
      setState(() {
        loading = false;
      });
    }
  }

  List<ItemType> _getItems() {
    return _items;
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.refresh = _refresh;
      widget.controller!.getItems = _getItems;
      widget.controller!.retry = _initList;
    }
    _initList();
    _scrollController.addListener(() async {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent - 100) {
        if (!loading && stillHasItems && !hasError) {
          setState(() {
            loading = true;
            hasError = false;
          });
          List<ItemType> items = [];
          try {
            items = await widget.onLoadMore();
            if (items.isEmpty) {
              stillHasItems = false;
              setState(() {
                loading = false;
              });
              return;
            }
            _items.addAll(items);
            groupedItems = groupItems(_items);

            groupTitles = groupedItems.keys.toList();
            setState(() {
              loading = false;
            });
          } catch (e) {
            hasError = true;
            setState(() {
              loading = false;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading && _items.isEmpty
        ? widget.loadingWidget
        : RefreshIndicator(
            color: widget.refreshIndicatorColor,
            backgroundColor: widget.refreshIndicatorBackgroundColor,
            onRefresh: _refresh,
            child: groupTitles.isEmpty
                ? CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        child: Center(
                          child: hasError
                              ? widget.initialItemsErrorWidget ??
                                  const Center(
                                    child: Text(
                                      'Something went wrong while fetching items',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                    ),
                                  )
                              : widget.noItemsFoundWidget ??
                                  const Text(
                                    'No items found',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                        ),
                      )
                    ],
                  )
                : CustomScrollView(
                    controller: _scrollController,
                    slivers: groupTitles.map<Widget>((title) {
                      return SliverStickyHeader.builder(
                        sticky: widget.stickyGroups,
                        builder: (context, state) {
                          return widget.groupTitleBuilder(
                            title,
                            widget.groupBy(
                              groupedItems[title]!.first,
                            ),
                            state.isPinned,
                            state.scrollPercentage,
                          );
                        },
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              final item = groupedItems[title]![i];
                              return Column(
                                children: [
                                  widget.itemBuilder(item),
                                  widget.seperatorBuilder(item),
                                ],
                              );
                            },
                            childCount: groupedItems[title]!.length,
                          ),
                        ),
                      );
                    }).toList()
                      ..addAll([
                        if (loading)
                          SliverToBoxAdapter(child: widget.loadingWidget),
                        if (hasError)
                          SliverToBoxAdapter(
                            child: widget.loadMoreItemsErrorWidget ??
                                const Text(
                                  'Oops something went wrong !',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                          ),
                      ]),
                  ),
          );
  }

  /// Function to group items based on [GroupBy]
  Map<GroupTitle, List<ItemType>> groupItems(List<ItemType> items) {
    final Map<GroupTitle, List<ItemType>> groupedItems = {};

    for (final item in items) {
      final GroupTitle groupTitle = widget.groupCreator(widget.groupBy(item));

      if (groupedItems.containsKey(groupTitle)) {
        groupedItems[groupTitle]!.add(item);
      } else {
        groupedItems[groupTitle] = [item];
      }
    }

    groupedItems.forEach((key, value) {
      if (widget.groupSortOrder == SortOrder.ascending) {
        value.sort((a, b) {
          return (widget.sortGroupBy(a) as Comparable?)
                  ?.compareTo(widget.sortGroupBy(b) as Comparable?) ??
              0;
        });
      } else {
        value.sort((a, b) {
          return (widget.sortGroupBy(b) as Comparable?)
                  ?.compareTo(widget.sortGroupBy(a) as Comparable?) ??
              0;
        });
      }
    });
    return groupedItems;
  }
}
