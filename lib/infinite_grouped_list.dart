import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:infinite_grouped_list/helpers/pagination_info.dart';

enum ListStyle {
  /// The list will be displayed as a grid.
  grid,

  /// The list will be displayed as a list.
  listView,
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
  factory InfiniteGroupedList({
    required Widget Function(ItemType item) itemBuilder,
    required GroupBy Function(ItemType item) groupBy,
    required Widget Function(
      GroupTitle title,
      GroupBy groupBy,
      bool isPinned,
      double scrollPercentage,
    ) groupTitleBuilder,
    required Future<List<ItemType>> Function(PaginationInfo paginationInfo)
        onLoadMore,
    required GroupTitle Function(GroupBy) groupCreator,
    Function(ItemType)? sortGroupBy,
    Widget Function(ItemType)? seperatorBuilder,
    bool isPaged = true,
    InfiniteGroupedListController<ItemType, GroupBy, GroupTitle>? controller,
    Function()? onRefresh,
    Widget? noItemsFoundWidget,
    Widget? initialItemsErrorWidget,
    Widget? loadMoreItemsErrorWidget,
    SortOrder groupSortOrder = SortOrder.descending,
    bool stickyGroups = true,
    Widget loadingWidget = const Center(
      child: CircularProgressIndicator(),
    ),
    Color? refreshIndicatorColor,
    Color? refreshIndicatorBackgroundColor,
  }) {
    return InfiniteGroupedList._(
      onLoadMore: onLoadMore,
      itemBuilder: itemBuilder,
      groupTitleBuilder: groupTitleBuilder,
      groupBy: groupBy,
      groupCreator: groupCreator,
      sortGroupBy: sortGroupBy,
      seperatorBuilder: seperatorBuilder,
      isPaged: isPaged,
      controller: controller,
      onRefresh: onRefresh,
      noItemsFoundWidget: noItemsFoundWidget,
      initialItemsErrorWidget: initialItemsErrorWidget,
      loadMoreItemsErrorWidget: loadMoreItemsErrorWidget,
      groupSortOrder: groupSortOrder,
      stickyGroups: stickyGroups,
      loadingWidget: loadingWidget,
      refreshIndicatorColor: refreshIndicatorColor,
      refreshIndicatorBackgroundColor: refreshIndicatorBackgroundColor,
      listStyle: ListStyle.listView,
    );
  }

  factory InfiniteGroupedList.gridView({
    required Widget Function(ItemType item) itemBuilder,
    required GroupBy Function(ItemType item) groupBy,
    required Widget Function(
      GroupTitle title,
      GroupBy groupBy,
      bool isPinned,
      double scrollPercentage,
    ) groupTitleBuilder,
    required Future<List<ItemType>> Function(PaginationInfo paginationInfo)
        onLoadMore,
    required GroupTitle Function(GroupBy) groupCreator,
    Function(ItemType)? sortGroupBy,
    SliverGridDelegate? gridDelegate,
    Widget Function(ItemType)? seperatorBuilder,
    bool isPaged = true,
    InfiniteGroupedListController<ItemType, GroupBy, GroupTitle>? controller,
    Function()? onRefresh,
    Widget? noItemsFoundWidget,
    Widget? initialItemsErrorWidget,
    Widget? loadMoreItemsErrorWidget,
    SortOrder groupSortOrder = SortOrder.descending,
    bool stickyGroups = true,
    Widget loadingWidget = const Center(
      child: CircularProgressIndicator(),
    ),
    Color? refreshIndicatorColor,
    Color? refreshIndicatorBackgroundColor,
  }) {
    return InfiniteGroupedList._(
      onLoadMore: onLoadMore,
      itemBuilder: itemBuilder,
      groupTitleBuilder: groupTitleBuilder,
      groupBy: groupBy,
      groupCreator: groupCreator,
      sortGroupBy: sortGroupBy,
      seperatorBuilder: seperatorBuilder,
      isPaged: isPaged,
      controller: controller,
      onRefresh: onRefresh,
      noItemsFoundWidget: noItemsFoundWidget,
      initialItemsErrorWidget: initialItemsErrorWidget,
      loadMoreItemsErrorWidget: loadMoreItemsErrorWidget,
      groupSortOrder: groupSortOrder,
      stickyGroups: stickyGroups,
      loadingWidget: loadingWidget,
      refreshIndicatorColor: refreshIndicatorColor,
      refreshIndicatorBackgroundColor: refreshIndicatorBackgroundColor,
      gridDelegate: gridDelegate,
      listStyle: ListStyle.grid,
    );
  }

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
  const InfiniteGroupedList._({
    required this.onLoadMore,
    required this.itemBuilder,
    required this.groupTitleBuilder,
    required this.groupBy,
    required this.groupCreator,
    required this.listStyle,
    this.sortGroupBy,
    this.seperatorBuilder,
    this.isPaged = true,
    this.controller,
    this.onRefresh,
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
    this.gridDelegate,
    super.key,
  });

  final SliverGridDelegate? gridDelegate;
  final ListStyle listStyle;

  /// The function to call when the list needs to load more items.
  ///
  /// The function should take a PaginationInfo parameter representing the current
  /// offset and page, for pagination.
  ///
  /// The widget will automatically increment the offset and page each time this function
  /// is called, so your function just needs to use the provided PaginationInfo to fetch
  /// the appropriate items.
  ///
  /// The function should return a Future that completes with a list of new items
  /// to be added to the list. The function is expected to return an empty list
  /// when there are no more items to load, signaling the end of the available data.
  ///
  /// #### Example usage (with an API that uses offset-based pagination):
  ///
  /// ```dart
  /// onLoadMore: (paginationInfo) {
  ///   // fetch 10 items starting from 'paginationInfo.offset'
  ///   return myApi.getItems(offset: paginationInfo.offset, limit: 10);
  /// }
  /// ```
  ///
  /// #### Example usage (with an API that uses page-based pagination):
  ///
  /// ```dart
  /// onLoadMore: (paginationInfo) {
  ///   // fetch 10 items starting from 'paginationInfo.page'
  ///   return myApi.getItems(page: paginationInfo.page, limit: 10);
  /// }
  /// ```
  ///
  /// If an error occurs while fetching the items (for example, due to network
  /// issues), the function should throw an exception. The widget will catch this
  /// exception and call the [loadMoreItemsErrorWidget] builder.
  final Future<List<ItemType>> Function(PaginationInfo paginationInfo)
      onLoadMore;

  /// The item builder is used to build the item.
  final Widget Function(ItemType item) itemBuilder;

  /// The seperator builder is used to build the seperator between items.
  final Widget Function(ItemType item)? seperatorBuilder;

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

  /// Return the field of the item that you want to group by.
  ///
  /// Will be used by the [groupCreator] to create the title of the group.
  final GroupBy Function(ItemType item) groupBy;

  /// Using the [groupBy] value, you can define how the group title should be created.
  final GroupTitle Function(GroupBy groupBy) groupCreator;

  /// You can define the field of which the items inside the groups should be sorted by.
  final void Function(ItemType sortGroupBy)? sortGroupBy;

  /// The sort order of the items inside the groups.
  final SortOrder groupSortOrder;

  /// The color of the refresh indicator
  final Color? refreshIndicatorColor;

  /// The background color of the refresh indicator
  final Color? refreshIndicatorBackgroundColor;

  /// Whether the grpup should stick to the top of the screen when scrolling up.
  final bool stickyGroups;

  /// Whether the [onLoadMore] uses paging. If it does not, this should be set as [false]
  ///
  /// otherwise it will keep on adding the same items to the list.
  final bool isPaged;

  /// The controller of the list.
  ///
  /// - Get the items in the list.
  /// - Retry the last failed load more call.
  /// - Refresh the list.
  final InfiniteGroupedListController<ItemType, GroupBy, GroupTitle>?
      controller;

  @override
  _InfiniteGroupState<ItemType, GroupBy, GroupTitle> createState() =>
      _InfiniteGroupState();
}

class _InfiniteGroupState<ItemType, GroupBy, GroupTitle>
    extends State<InfiniteGroupedList<ItemType, GroupBy, GroupTitle>> {
  bool loading = true;
  bool hasError = false;

  bool stillHasItems = true;
  final _InfiniteGroupedListInternalController<ItemType, GroupBy, GroupTitle>
      _pageInformationController = _InfiniteGroupedListInternalController();

  final ScrollController _scrollController = ScrollController();

  final List<ItemType> _allItems = [];

  late Map<GroupTitle, List<ItemType>> groupedItems = groupItems(_allItems);

  late List<GroupTitle> groupTitles = groupedItems.keys.toList();

  Future<void> _initList() async {
    if (!loading && mounted) {
      setState(() {
        loading = true;
        hasError = false;
      });
    }
    try {
      final items = await widget.onLoadMore(
        PaginationInfo(
          offset: _pageInformationController.currentOffset,
          page: _pageInformationController.currentPage,
        ),
      );

      // Increment the offset after a successful fetch
      _pageInformationController.incrementOffset(items.length);

      // Increment the page after a successful fetch
      _pageInformationController.incrementPage();

      _allItems.addAll(items);

      groupedItems = groupItems(_allItems);

      groupTitles = groupedItems.keys.toList();
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      hasError = true;
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  /// Returns the items that are currently fetched.
  List<ItemType> _items() => _allItems;

  /// Refreshes the list resetting the offset and page to 0.
  Future<void> _refresh() async {
    _allItems.clear();
    widget.onRefresh?.call();
    stillHasItems = true;
    hasError = false;
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    _pageInformationController.currentOffset = 0;
    _pageInformationController.currentPage = 1;
    try {
      final items = await widget.onLoadMore(
        PaginationInfo(
          offset: _pageInformationController.currentOffset,
          page: _pageInformationController.currentPage,
        ),
      );

      // Increment the offset after a successful fetch
      _pageInformationController.incrementOffset(items.length);

      // Increment the page after a successful fetch
      _pageInformationController.incrementPage();

      _allItems.addAll(items);

      groupedItems = groupItems(_allItems);

      groupTitles = groupedItems.keys.toList();

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      hasError = true;
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  /// Retries the last failed fetch
  Future<void> _retry() async {
    if (!loading && mounted) {
      setState(() {
        loading = true;
        hasError = false;
      });
    }
    try {
      final items = await widget.onLoadMore(
        PaginationInfo(
          offset: _pageInformationController.currentOffset,
          page: _pageInformationController.currentPage,
        ),
      );

      // Increment the offset after a successful fetch
      _pageInformationController.incrementOffset(items.length);

      // Increment the page after a successful fetch
      _pageInformationController.incrementPage();

      _allItems.addAll(items);

      groupedItems = groupItems(_allItems);

      groupTitles = groupedItems.keys.toList();
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      hasError = true;
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      widget.controller!.getItems = _items;
      widget.controller!.refresh = _refresh;
      widget.controller!.loadItems = _retry;
    }

    _initList();
    _scrollController.addListener(() async {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent - 100 &&
          widget.isPaged) {
        if (!loading && stillHasItems && !hasError && mounted) {
          setState(() {
            loading = true;
            hasError = false;
          });
          List<ItemType> items = [];
          try {
            items = await widget.onLoadMore(
              PaginationInfo(
                offset: _pageInformationController.currentOffset,
                page: _pageInformationController.currentPage,
              ),
            );

            // Increment the offset after a successful fetch
            _pageInformationController.incrementOffset(items.length);

            // Increment the page after a successful fetch
            _pageInformationController.incrementPage();

            if (items.isEmpty) {
              stillHasItems = false;
              if (mounted) {
                setState(() {
                  loading = false;
                });
              }
              return;
            }
            _allItems.addAll(items);
            groupedItems = groupItems(_allItems);

            groupTitles = groupedItems.keys.toList();
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          } catch (e) {
            hasError = true;
            if (mounted) {
              setState(() {
                loading = false;
              });
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading && _allItems.isEmpty
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
                        sliver: widget.listStyle == ListStyle.listView
                            ? SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, i) {
                                    final item = groupedItems[title]![i];
                                    return Column(
                                      children: [
                                        widget.itemBuilder(item),
                                        if (widget.seperatorBuilder != null)
                                          widget.seperatorBuilder!(item),
                                      ],
                                    );
                                  },
                                  childCount: groupedItems[title]!.length,
                                ),
                              )
                            : SliverGrid(
                                gridDelegate: widget.gridDelegate ??
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 2,
                                    ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, i) {
                                    final item = groupedItems[title]![i];
                                    return Column(
                                      children: [
                                        widget.itemBuilder(item),
                                        if (widget.seperatorBuilder != null)
                                          widget.seperatorBuilder!(item),
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
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 14.0,
                                top: 5.0,
                              ),
                              child: widget.loadingWidget,
                            ),
                          ),
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
    if (widget.sortGroupBy != null) {
      groupedItems.forEach((key, value) {
        if (widget.groupSortOrder == SortOrder.ascending) {
          value.sort((a, b) {
            return (widget.sortGroupBy!(a) as Comparable?)
                    ?.compareTo(widget.sortGroupBy!(b) as Comparable?) ??
                0;
          });
        } else {
          value.sort((a, b) {
            return (widget.sortGroupBy!(b) as Comparable?)
                    ?.compareTo(widget.sortGroupBy!(a) as Comparable?) ??
                0;
          });
        }
      });
    }
    return groupedItems;
  }
}

/// This is the controller for the [InfiniteGroupedList].
///
/// Use this controller to :
///
/// 1. Get the items in the list.
/// 2. Retry the last failed load more call.
/// 3. Refresh the list.
class InfiniteGroupedListController<ItemType, GroupBy, GroupTitle> {
  /// Call this function to get the items in the list.
  late List<ItemType> Function() getItems;

  /// Call this function to programmatically fetch the next page
  ///
  /// If the last call was failed then it will retry the last call.
  late Future<void> Function() loadItems;

  /// Refresh the list.
  late Future<void> Function() refresh;

  InfiniteGroupedListController();
}

class _InfiniteGroupedListInternalController<ItemType, GroupBy, GroupTitle> {
  // This is the current offset of the list.
  int currentOffset = 0;

  // Function to increment the offset
  void incrementOffset(int offset) => currentOffset += offset;

  /// This is the current page of the list.
  int currentPage = 1;

  /// Function to increment the page
  void incrementPage() => currentPage++;

  _InfiniteGroupedListInternalController();
}
