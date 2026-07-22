import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:infinite_grouped_list/src/helpers/empty_list.dart';
import 'package:infinite_grouped_list/src/helpers/enums.dart';
import 'package:infinite_grouped_list/src/helpers/group_manager.dart';
import 'package:infinite_grouped_list/src/helpers/pagination_info.dart';

typedef InfiniteGroupedListSort<ItemType> = Comparable Function(ItemType item);
typedef InfiniteGroupedListRefreshCallback = FutureOr<void> Function();

const int _defaultJumpToGroupMaxRetries = 3;

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
    required GroupTitle Function(GroupBy) groupCreator,
    bool? showGroups,
    required Future<List<ItemType>> Function(PaginationInfo paginationInfo)
        onLoadMore,
    InfiniteGroupedListSort<ItemType>? sortGroupBy,
    Widget Function(ItemType)? separatorBuilder,
    bool isPaged = true,
    InfiniteGroupedListController<ItemType, GroupBy, GroupTitle>? controller,
    InfiniteGroupedListRefreshCallback? onRefresh,
    Widget? noItemsFoundWidget,
    Widget Function(dynamic error)? initialItemsErrorWidget,
    Widget Function(dynamic error)? loadMoreItemsErrorWidget,
    SortOrder groupSortOrder = SortOrder.descending,
    bool stickyGroups = true,
    Widget loadingWidget = const Center(
      child: CircularProgressIndicator(),
    ),
    bool enableAnchoring = false,
    Color? refreshIndicatorColor,
    Color? refreshIndicatorBackgroundColor,
    ScrollPhysics? physics,
    bool? showRefreshIndicator,
    Key? key,
    ScrollController? scrollController,
    VoidCallback? onNoMoreItemsFound,
  }) {
    return InfiniteGroupedList._(
      onLoadMore: onLoadMore,
      itemBuilder: itemBuilder,
      groupTitleBuilder: groupTitleBuilder,
      groupBy: groupBy,
      groupCreator: groupCreator,
      sortGroupBy: sortGroupBy,
      separatorBuilder: separatorBuilder,
      isPaged: isPaged,
      controller: controller ?? InfiniteGroupedListController(),
      onRefresh: onRefresh,
      noItemsFoundWidget: noItemsFoundWidget,
      initialItemsErrorWidget: initialItemsErrorWidget,
      loadMoreItemsErrorWidget: loadMoreItemsErrorWidget,
      groupSortOrder: groupSortOrder,
      stickyGroups: stickyGroups,
      enableAnchoring: enableAnchoring,
      loadingWidget: loadingWidget,
      refreshIndicatorColor: refreshIndicatorColor,
      refreshIndicatorBackgroundColor: refreshIndicatorBackgroundColor,
      listStyle: ListStyle.listView,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      showRefreshIndicator: showRefreshIndicator ?? true,
      key: key,
      onNoMoreItemsFound: onNoMoreItemsFound,
      showGroups: showGroups ?? true,
      scrollController: scrollController,
      isReactiveMode: false,
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
    InfiniteGroupedListSort<ItemType>? sortGroupBy,
    SliverGridDelegate? gridDelegate,
    Widget Function(ItemType)? separatorBuilder,
    bool isPaged = true,
    InfiniteGroupedListController<ItemType, GroupBy, GroupTitle>? controller,
    InfiniteGroupedListRefreshCallback? onRefresh,
    Widget? noItemsFoundWidget,
    Widget Function(dynamic error)? initialItemsErrorWidget,
    Widget Function(dynamic error)? loadMoreItemsErrorWidget,
    SortOrder groupSortOrder = SortOrder.descending,
    bool stickyGroups = true,
    Widget loadingWidget = const Center(
      child: CircularProgressIndicator(),
    ),
    bool enableAnchoring = false,
    Color? refreshIndicatorColor,
    Color? refreshIndicatorBackgroundColor,
    ScrollPhysics? physics,
    bool? showRefreshIndicator,
    VoidCallback? onNoMoreItemsFound,
    Key? key,
    bool? showGroups,
    ScrollController? scrollController,
  }) {
    return InfiniteGroupedList._(
      onLoadMore: onLoadMore,
      itemBuilder: itemBuilder,
      groupTitleBuilder: groupTitleBuilder,
      groupBy: groupBy,
      groupCreator: groupCreator,
      sortGroupBy: sortGroupBy,
      separatorBuilder: separatorBuilder,
      isPaged: isPaged,
      controller: controller ?? InfiniteGroupedListController(),
      onRefresh: onRefresh,
      noItemsFoundWidget: noItemsFoundWidget,
      initialItemsErrorWidget: initialItemsErrorWidget,
      loadMoreItemsErrorWidget: loadMoreItemsErrorWidget,
      groupSortOrder: groupSortOrder,
      stickyGroups: stickyGroups,
      loadingWidget: loadingWidget,
      enableAnchoring: enableAnchoring,
      refreshIndicatorColor: refreshIndicatorColor,
      refreshIndicatorBackgroundColor: refreshIndicatorBackgroundColor,
      gridDelegate: gridDelegate,
      listStyle: ListStyle.grid,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      showRefreshIndicator: showRefreshIndicator ?? true,
      onNoMoreItemsFound: onNoMoreItemsFound,
      showGroups: showGroups ?? true,
      scrollController: scrollController,
      key: key,
      isReactiveMode: false,
    );
  }

  /// Creates a reactive InfiniteGroupedList for ListView layout.
  ///
  /// This constructor is designed for use with external state management
  /// solutions like BLoC, Provider, Riverpod, etc. where data fetching
  /// and state management are handled externally.
  ///
  /// Example usage with BLoC:
  /// ```dart
  /// BlocBuilder<ItemsBloc, ItemsState>(
  ///   builder: (context, state) {
  ///     return InfiniteGroupedList.reactive(
  ///       items: state.items,
  ///       isLoading: state.isLoading,
  ///       hasReachedMax: state.hasReachedMax,
  ///       onLoadMoreTriggered: () => context.read<ItemsBloc>()
  ///         .add(LoadMoreItems()),
  ///       itemBuilder: (item) => ListTile(title: Text(item.name)),
  ///       groupBy: (item) => item.category,
  ///       groupCreator: (category) => category,
  ///       groupTitleBuilder: (title, _, __, ___) => Text(title),
  ///     );
  ///   },
  /// )
  /// ```
  factory InfiniteGroupedList.reactive({
    required List<ItemType> items,
    required bool isLoading,
    required bool hasReachedMax,
    required VoidCallback onLoadMoreTriggered,
    required Widget Function(ItemType item) itemBuilder,
    required GroupBy Function(ItemType item) groupBy,
    required Widget Function(
      GroupTitle title,
      GroupBy groupBy,
      bool isPinned,
      double scrollPercentage,
    ) groupTitleBuilder,
    required GroupTitle Function(GroupBy) groupCreator,
    bool? showGroups,
    InfiniteGroupedListSort<ItemType>? sortGroupBy,
    Widget Function(ItemType)? separatorBuilder,
    InfiniteGroupedListController<ItemType, GroupBy, GroupTitle>? controller,
    InfiniteGroupedListRefreshCallback? onRefresh,
    Widget? noItemsFoundWidget,
    dynamic error,
    Widget Function(dynamic error)? errorWidget,
    SortOrder groupSortOrder = SortOrder.descending,
    bool stickyGroups = true,
    Widget loadingWidget = const Center(
      child: CircularProgressIndicator(),
    ),
    bool enableAnchoring = false,
    Color? refreshIndicatorColor,
    Color? refreshIndicatorBackgroundColor,
    ScrollPhysics? physics,
    bool? showRefreshIndicator,
    Key? key,
    ScrollController? scrollController,
  }) {
    return InfiniteGroupedList._(
      // Reactive mode properties
      reactiveItems: items,
      reactiveIsLoading: isLoading,
      reactiveHasReachedMax: hasReachedMax,
      onLoadMoreTriggered: onLoadMoreTriggered,
      reactiveError: error,
      // Common properties
      itemBuilder: itemBuilder,
      groupTitleBuilder: groupTitleBuilder,
      groupBy: groupBy,
      groupCreator: groupCreator,
      sortGroupBy: sortGroupBy,
      separatorBuilder: separatorBuilder,
      controller: controller ?? InfiniteGroupedListController(),
      onRefresh: onRefresh,
      noItemsFoundWidget: noItemsFoundWidget,
      initialItemsErrorWidget: errorWidget,
      loadMoreItemsErrorWidget: errorWidget,
      groupSortOrder: groupSortOrder,
      stickyGroups: stickyGroups,
      loadingWidget: loadingWidget,
      enableAnchoring: enableAnchoring,
      refreshIndicatorColor: refreshIndicatorColor,
      refreshIndicatorBackgroundColor: refreshIndicatorBackgroundColor,
      listStyle: ListStyle.listView,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      showRefreshIndicator: showRefreshIndicator ?? true,
      showGroups: showGroups ?? true,
      scrollController: scrollController,
      key: key,
      isReactiveMode: true,
    );
  }

  /// Creates a reactive InfiniteGroupedList for GridView layout.
  ///
  /// This constructor is designed for use with external state management
  /// solutions like BLoC, Provider, Riverpod, etc. where data fetching
  /// and state management are handled externally.
  ///
  /// Example usage with BLoC:
  /// ```dart
  /// BlocBuilder<ItemsBloc, ItemsState>(
  ///   builder: (context, state) {
  ///     return InfiniteGroupedList.reactiveGrid(
  ///       items: state.items,
  ///       isLoading: state.isLoading,
  ///       hasReachedMax: state.hasReachedMax,
  ///       onLoadMoreTriggered: () => context.read<ItemsBloc>()
  ///         .add(LoadMoreItems()),
  ///       itemBuilder: (item) => Card(child: Text(item.name)),
  ///       groupBy: (item) => item.category,
  ///       groupCreator: (category) => category,
  ///       groupTitleBuilder: (title, _, __, ___) => Text(title),
  ///       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  ///         crossAxisCount: 2,
  ///       ),
  ///     );
  ///   },
  /// )
  /// ```
  factory InfiniteGroupedList.reactiveGrid({
    required List<ItemType> items,
    required bool isLoading,
    required bool hasReachedMax,
    required VoidCallback onLoadMoreTriggered,
    required Widget Function(ItemType item) itemBuilder,
    required GroupBy Function(ItemType item) groupBy,
    required Widget Function(
      GroupTitle title,
      GroupBy groupBy,
      bool isPinned,
      double scrollPercentage,
    ) groupTitleBuilder,
    required GroupTitle Function(GroupBy) groupCreator,
    SliverGridDelegate? gridDelegate,
    bool? showGroups,
    InfiniteGroupedListSort<ItemType>? sortGroupBy,
    Widget Function(ItemType)? separatorBuilder,
    InfiniteGroupedListController<ItemType, GroupBy, GroupTitle>? controller,
    InfiniteGroupedListRefreshCallback? onRefresh,
    Widget? noItemsFoundWidget,
    dynamic error,
    Widget Function(dynamic error)? errorWidget,
    SortOrder groupSortOrder = SortOrder.descending,
    bool stickyGroups = true,
    Widget loadingWidget = const Center(
      child: CircularProgressIndicator(),
    ),
    bool enableAnchoring = false,
    Color? refreshIndicatorColor,
    Color? refreshIndicatorBackgroundColor,
    ScrollPhysics? physics,
    bool? showRefreshIndicator,
    Key? key,
    ScrollController? scrollController,
  }) {
    return InfiniteGroupedList._(
      // Reactive mode properties
      reactiveItems: items,
      reactiveIsLoading: isLoading,
      reactiveHasReachedMax: hasReachedMax,
      onLoadMoreTriggered: onLoadMoreTriggered,
      reactiveError: error,
      // Common properties
      itemBuilder: itemBuilder,
      groupTitleBuilder: groupTitleBuilder,
      groupBy: groupBy,
      groupCreator: groupCreator,
      sortGroupBy: sortGroupBy,
      separatorBuilder: separatorBuilder,
      controller: controller ?? InfiniteGroupedListController(),
      onRefresh: onRefresh,
      noItemsFoundWidget: noItemsFoundWidget,
      initialItemsErrorWidget: errorWidget,
      loadMoreItemsErrorWidget: errorWidget,
      groupSortOrder: groupSortOrder,
      stickyGroups: stickyGroups,
      loadingWidget: loadingWidget,
      enableAnchoring: enableAnchoring,
      refreshIndicatorColor: refreshIndicatorColor,
      refreshIndicatorBackgroundColor: refreshIndicatorBackgroundColor,
      gridDelegate: gridDelegate,
      listStyle: ListStyle.grid,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      showRefreshIndicator: showRefreshIndicator ?? true,
      showGroups: showGroups ?? true,
      scrollController: scrollController,
      key: key,
      isReactiveMode: true,
    );
  }

  /// Constructs an instance of InfiniteGroupedList.
  ///
  /// This requires several callback parameters:
  /// * [onLoadMore]: Fetches more items to be added to the list. This function is
  ///   expected to return a Future that completes with a List
  /// * [itemBuilder]: Builds the widget for each item in the list.
  /// * [separatorBuilder]: Builds the separator widget between items.
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
    this.onLoadMore,
    required this.itemBuilder,
    required this.groupTitleBuilder,
    required this.groupBy,
    required this.groupCreator,
    required this.listStyle,
    required this.controller,
    required this.isReactiveMode,
    this.showGroups = true,
    this.onNoMoreItemsFound,
    this.sortGroupBy,
    this.separatorBuilder,
    this.isPaged = true,
    this.onRefresh,
    this.noItemsFoundWidget,
    this.initialItemsErrorWidget,
    this.loadMoreItemsErrorWidget,
    this.groupSortOrder = SortOrder.descending,
    this.stickyGroups = true,
    this.loadingWidget = const Center(
      child: CircularProgressIndicator(),
    ),
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.refreshIndicatorColor,
    this.refreshIndicatorBackgroundColor,
    this.gridDelegate,
    this.showRefreshIndicator = true,
    this.scrollController,
    this.enableAnchoring = false,
    // Reactive mode properties
    this.reactiveItems,
    this.reactiveIsLoading,
    this.reactiveHasReachedMax,
    this.onLoadMoreTriggered,
    this.reactiveError,
    super.key,
  }) : assert(
          isReactiveMode
              ? (reactiveItems != null &&
                  reactiveIsLoading != null &&
                  reactiveHasReachedMax != null &&
                  onLoadMoreTriggered != null)
              : (onLoadMore != null),
          isReactiveMode
              ? 'In reactive mode, reactiveItems, reactiveIsLoading, reactiveHasReachedMax, '
                  'and onLoadMoreTriggered must be provided.'
              : 'In imperative mode, onLoadMore must be provided.',
        );

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
  ///
  /// This is null in reactive mode.
  final Future<List<ItemType>> Function(PaginationInfo paginationInfo)?
      onLoadMore;

  /// The item builder is used to build the item.
  final Widget Function(ItemType item) itemBuilder;

  /// The seperator builder is used to build the seperator between items.
  final Widget Function(ItemType item)? separatorBuilder;

  /// Optionally if you want to do something when the user pulls to refresh.
  final InfiniteGroupedListRefreshCallback? onRefresh;

  /// Optionally if you want to do something when there are no more items to load.
  final VoidCallback? onNoMoreItemsFound;

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
  final Widget Function(dynamic error)? initialItemsErrorWidget;

  /// The widget to show when the load call fails.
  ///
  /// This will be shown at the bottom of the list.
  final Widget Function(dynamic error)? loadMoreItemsErrorWidget;

  /// Return the field of the item that you want to group by.
  ///
  /// Will be used by the [groupCreator] to create the title of the group.
  final GroupBy Function(ItemType item) groupBy;

  /// Using the [groupBy] value, you can define how the group title should be created.
  final GroupTitle Function(GroupBy groupBy) groupCreator;

  /// You can define the field of which the items inside the groups should be sorted by.
  final InfiniteGroupedListSort<ItemType>? sortGroupBy;

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

  final bool showGroups;

  /// Enables scroll anchoring via [InfiniteGroupedListController.jumpToGroup].
  ///
  /// Off by default to avoid extra key bookkeeping when the feature
  /// is not needed.
  final bool enableAnchoring;

  /// The controller of the list.
  ///
  /// - Get the items in the list.
  /// - Retry the last failed load more call.
  /// - Refresh the list.
  final InfiniteGroupedListController<ItemType, GroupBy, GroupTitle> controller;

  /// The scroll physics of the list.
  ///
  /// Defaults to [AlwaysScrollableScrollPhysics]
  final ScrollPhysics physics;

  /// Whether to show the refresh indicator when the user pulls to refresh. Defaults to true.
  final bool showRefreshIndicator;

  /// The scroll controller of the list.
  final ScrollController? scrollController;

  // Reactive mode properties

  /// Whether this widget is in reactive mode.
  final bool isReactiveMode;

  /// External items list for reactive mode.
  final List<ItemType>? reactiveItems;

  /// External loading state for reactive mode.
  final bool? reactiveIsLoading;

  /// External flag indicating whether max items have been reached for reactive mode.
  final bool? reactiveHasReachedMax;

  /// Callback triggered when more items should be loaded in reactive mode.
  final VoidCallback? onLoadMoreTriggered;

  /// External error state for reactive mode.
  final dynamic reactiveError;

  @override
  _InfiniteGroupState<ItemType, GroupBy, GroupTitle> createState() =>
      _InfiniteGroupState();
}

enum _PageLoadOutcome { loaded, error, skipped }

class _InfiniteGroupState<ItemType, GroupBy, GroupTitle>
    extends State<InfiniteGroupedList<ItemType, GroupBy, GroupTitle>> {
  static const double _loadMoreThreshold = 100.0;

  bool loading = true;
  bool hasError = false;
  bool noMoreItemsToLoad = false;
  dynamic error;

  final _InfiniteGroupedListInternalController<ItemType, GroupBy, GroupTitle>
      _pageInformationController = _InfiniteGroupedListInternalController();

  late ScrollController _scrollController;
  bool _ownsScrollController = false;
  bool _reactiveLoadPending = false;
  Future<_PageLoadOutcome>? _activePageLoad;

  final List<ItemType> _allItems = [];

  late Map<GroupTitle, List<ItemType>> groupedItems = _groupItems(_allItems);

  late List<GroupTitle> groupTitles = groupedItems.keys.toList();

  final Map<GroupTitle, BuildContext> _groupHeaderContexts = {};
  bool _isJumpingToGroup = false;

  GroupManager<ItemType, GroupBy, GroupTitle> get _groupManager =>
      GroupManager<ItemType, GroupBy, GroupTitle>(
        groupBy: widget.groupBy,
        groupCreator: widget.groupCreator,
        sortFn: widget.sortGroupBy,
        sortOrder: widget.groupSortOrder,
      );

  void _updateState(VoidCallback updater) {
    if (!mounted) {
      updater();
      return;
    }
    setState(updater);
  }

  void _attachController(
    InfiniteGroupedListController<ItemType, GroupBy, GroupTitle> controller,
  ) {
    controller._getItemsCallback = _items;
    controller._refreshCallback = _refresh;
    controller._loadItemsCallback = _loadItems;
    controller._addItemsCallback = _addItems;
    controller._removeWhereCallback = _removeWhere;
    controller._removeCallback = _removeItem;
    controller._jumpToGroupCallback = _jumpToGroup;
    controller._isReactiveMode = widget.isReactiveMode;
  }

  void _detachController(
    InfiniteGroupedListController<ItemType, GroupBy, GroupTitle> controller,
  ) {
    controller._getItemsCallback = null;
    controller._refreshCallback = null;
    controller._loadItemsCallback = null;
    controller._addItemsCallback = null;
    controller._removeWhereCallback = null;
    controller._removeCallback = null;
    controller._jumpToGroupCallback = null;
    controller._isReactiveMode = false;
  }

  void _attachScrollController(ScrollController? controller) {
    _scrollController = controller ?? ScrollController();
    _ownsScrollController = controller == null;
    _scrollController.addListener(_handleScrollListener);
  }

  void _detachScrollController() {
    _scrollController.removeListener(_handleScrollListener);
    if (_ownsScrollController) {
      _scrollController.dispose();
    }
    _ownsScrollController = false;
  }

  void _handleScrollListener() {
    unawaited(_handleScroll());
  }

  void _scheduleHeaderContextUpdate(
    GroupTitle title,
    BuildContext context,
  ) {
    if (!widget.enableAnchoring) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !context.mounted) {
        return;
      }
      _groupHeaderContexts[title] = context;
    });
  }

  void _pruneHeaderContexts() {
    if (!widget.enableAnchoring) {
      _groupHeaderContexts.clear();
      return;
    }
    final validTitles = groupTitles.toSet();
    _groupHeaderContexts.removeWhere(
      (title, _) => !validTitles.contains(title),
    );
  }

  void _setAllItems(List<ItemType> items) {
    _allItems
      ..clear()
      ..addAll(items);
    _rebuildGroupsFromAllItems();
  }

  void _rebuildGroupsFromAllItems() {
    groupedItems = _groupItems(_allItems);
    groupTitles = groupedItems.keys.toList();
    _pruneHeaderContexts();
  }

  void _mergeItemsIntoGroups(List<ItemType> items) {
    if (items.isEmpty) {
      return;
    }

    final previousGroupCount = groupedItems.length;
    _groupManager.merge(groupedItems, items);
    _allItems.addAll(items);

    if (groupedItems.length != previousGroupCount) {
      groupTitles = groupedItems.keys.toList();
      _pruneHeaderContexts();
    }
  }

  int _normalizedInsertionIndex(int? index) {
    if (index == null) {
      return _allItems.length;
    }

    return index.clamp(0, _allItems.length);
  }

  void _markNoMoreItemsToLoad() {
    if (noMoreItemsToLoad) {
      return;
    }
    noMoreItemsToLoad = true;
    widget.onNoMoreItemsFound?.call();
  }

  void _applyReactiveData() {
    final externalLoading = widget.reactiveIsLoading ?? false;
    final externalHasReachedMax = widget.reactiveHasReachedMax ?? false;
    final externalItems = widget.reactiveItems ?? <ItemType>[];
    final externalError = widget.reactiveError;

    _reactiveLoadPending = false;
    loading = externalLoading;
    noMoreItemsToLoad = externalHasReachedMax;
    hasError = externalError != null;
    error = externalError;
    _setAllItems(externalItems);
  }

  Future<_PageLoadOutcome> _performImperativeLoad({
    required PaginationInfo paginationInfo,
    required void Function(List<ItemType> items) onItemsLoaded,
    bool resetPaginationState = false,
  }) async {
    _updateState(() {
      loading = true;
      hasError = false;
      error = null;
      if (resetPaginationState) {
        noMoreItemsToLoad = false;
      }
    });

    try {
      final items = await widget.onLoadMore!(paginationInfo);

      onItemsLoaded(items);
      if (items.length < widget.controller.limit) {
        _markNoMoreItemsToLoad();
      } else {
        noMoreItemsToLoad = false;
      }

      _updateState(() {
        loading = false;
        hasError = false;
        error = null;
      });
      return _PageLoadOutcome.loaded;
    } catch (e) {
      _updateState(() {
        loading = false;
        hasError = true;
        error = e;
      });
      return _PageLoadOutcome.error;
    }
  }

  Future<_PageLoadOutcome> _trackPageLoad(
    Future<_PageLoadOutcome> Function() operation,
  ) {
    final existingLoad = _activePageLoad;
    if (existingLoad != null) {
      return existingLoad;
    }

    final future = operation();
    _activePageLoad = future;
    future.whenComplete(() {
      if (identical(_activePageLoad, future)) {
        _activePageLoad = null;
      }
    });
    return future;
  }

  Future<_PageLoadOutcome> _loadFirstPage() {
    if (widget.isReactiveMode) {
      _applyReactiveData();
      return Future<_PageLoadOutcome>.value(_PageLoadOutcome.skipped);
    }

    return _trackPageLoad(() {
      const initialOffset = 0;
      const initialPage = 1;

      return _performImperativeLoad(
        paginationInfo: PaginationInfo(
          offset: initialOffset,
          page: initialPage,
          limit: widget.controller.limit,
        ),
        resetPaginationState: true,
        onItemsLoaded: (items) {
          _pageInformationController.currentOffset =
              initialOffset + items.length;
          _pageInformationController.currentPage = initialPage + 1;
          _setAllItems(items);
        },
      );
    });
  }

  Future<_PageLoadOutcome> _loadNextPage() {
    if (widget.isReactiveMode) {
      _requestReactiveLoadMore();
      return Future<_PageLoadOutcome>.value(_PageLoadOutcome.skipped);
    }

    if (noMoreItemsToLoad) {
      return Future<_PageLoadOutcome>.value(_PageLoadOutcome.skipped);
    }

    return _trackPageLoad(() {
      final currentOffset = _pageInformationController.currentOffset;
      final currentPage = _pageInformationController.currentPage;

      return _performImperativeLoad(
        paginationInfo: PaginationInfo(
          offset: currentOffset,
          page: currentPage,
          limit: widget.controller.limit,
        ),
        onItemsLoaded: (items) {
          _pageInformationController.currentOffset =
              currentOffset + items.length;
          _pageInformationController.currentPage = currentPage + 1;
          _mergeItemsIntoGroups(items);
        },
      );
    });
  }

  bool _requestReactiveLoadMore() {
    if (!widget.isReactiveMode ||
        loading ||
        noMoreItemsToLoad ||
        hasError ||
        _reactiveLoadPending) {
      return false;
    }

    _reactiveLoadPending = true;
    widget.onLoadMoreTriggered?.call();
    return true;
  }

  GroupTitle? _findMatchingGroup(
    _JumpToGroupRequest<GroupTitle, GroupBy> request,
  ) {
    if (groupTitles.isEmpty) {
      return null;
    }

    if (request.title != null && groupedItems.containsKey(request.title)) {
      return request.title;
    }

    if (request.predicate != null) {
      for (final title in groupTitles) {
        final group = groupedItems[title];
        if (group == null || group.isEmpty) {
          continue;
        }
        final groupByValue = widget.groupBy(group.first);
        if (request.predicate!(title, groupByValue)) {
          return title;
        }
      }
    }

    return null;
  }

  Future<bool> _jumpToGroup(
    _JumpToGroupRequest<GroupTitle, GroupBy> request,
  ) async {
    if (!widget.enableAnchoring) {
      throw StateError(
        'Set enableAnchoring to true on InfiniteGroupedList to use jumpToGroup.',
      );
    }
    if (!mounted) {
      return false;
    }
    if (_isJumpingToGroup) {
      return false;
    }

    _isJumpingToGroup = true;
    try {
      final activeLoad = _activePageLoad;
      if (activeLoad != null) {
        await activeLoad;
      }

      GroupTitle? target = _findMatchingGroup(request);

      if (target == null && request.loadUntilFound) {
        if (widget.isReactiveMode) {
          throw UnsupportedError(
            'loadUntilFound is not supported in reactive mode. '
            'Drive additional loads through your state management layer.',
          );
        }

        var attempts = 0;
        while (target == null &&
            !noMoreItemsToLoad &&
            attempts < request.maxRetries) {
          final outcome = await _loadNextPage();
          if (outcome == _PageLoadOutcome.error ||
              outcome == _PageLoadOutcome.skipped) {
            return false;
          }
          attempts++;
          target = _findMatchingGroup(request);
        }
      }

      if (target == null) {
        return false;
      }

      BuildContext? headerContext = _groupHeaderContexts[target];
      if (headerContext == null || !headerContext.mounted) {
        await Future<void>.delayed(Duration.zero);
        headerContext = _groupHeaderContexts[target];
      }
      if (!mounted || headerContext == null || !headerContext.mounted) {
        return false;
      }

      final duration = request.animate ? request.duration : Duration.zero;
      await Scrollable.ensureVisible(
        headerContext,
        alignment: request.alignment,
        duration: duration,
        curve: request.curve,
      );
      return true;
    } finally {
      _isJumpingToGroup = false;
    }
  }

  void _handleReactiveDataUpdate() {
    if (!widget.isReactiveMode) {
      return;
    }

    _updateState(_applyReactiveData);
  }

  Future<void> _initList() async {
    if (widget.isReactiveMode) {
      _applyReactiveData();
      return;
    }

    await _loadFirstPage();
  }

  Future<void> _handleScroll() async {
    if (!widget.isPaged || !_scrollController.hasClients) {
      return;
    }

    final threshold =
        _scrollController.position.maxScrollExtent - _loadMoreThreshold;
    if (_scrollController.offset < threshold) {
      return;
    }

    if (widget.isReactiveMode) {
      _requestReactiveLoadMore();
      return;
    }

    if (loading || noMoreItemsToLoad || hasError) {
      return;
    }

    await _loadNextPage();
  }

  /// Returns the items that are currently fetched.
  List<ItemType> _items() => List<ItemType>.unmodifiable(_allItems);

  Future<void> _loadItems() async {
    if (widget.isReactiveMode) {
      _requestReactiveLoadMore();
      return;
    }

    await _loadNextPage();
  }

  /// Refreshes the list resetting the offset and page to 0.
  Future<void> _refresh() async {
    await Future<void>.value(widget.onRefresh?.call());
    _reactiveLoadPending = false;

    if (widget.isReactiveMode) {
      return;
    }

    // A page load already in flight (for example a scroll-triggered load-more)
    // occupies the same _trackPageLoad slot, so calling _loadFirstPage now would
    // just return that unrelated future and silently skip the refresh. Wait for
    // it to settle first, mirroring the guard used in _jumpToGroup, so the reload
    // below actually resets pagination and re-fetches the first page.
    final activeLoad = _activePageLoad;
    if (activeLoad != null) {
      await activeLoad;
    }

    await _loadFirstPage();
  }

  void _removeWhere(bool Function(ItemType) predicate) {
    _groupManager.removeWhere(groupedItems, _allItems, predicate);
    groupTitles = groupedItems.keys.toList();
    _pruneHeaderContexts();

    _updateState(() {});
  }

  void _removeItem(ItemType item) {
    final removed = _groupManager.removeItem(groupedItems, _allItems, item);
    if (!removed) {
      return;
    }

    groupTitles = groupedItems.keys.toList();
    _pruneHeaderContexts();

    _updateState(() {});
  }

  /// Function to add items to the list.
  void _addItems(List<ItemType> items, {int? index}) {
    if (items.isEmpty) {
      return;
    }

    error = null;
    hasError = false;

    if (index == null) {
      _mergeItemsIntoGroups(items);
    } else {
      _allItems.insertAll(_normalizedInsertionIndex(index), items);
      _rebuildGroupsFromAllItems();
    }

    _updateState(() {});
  }

  @override
  void initState() {
    super.initState();

    _attachScrollController(widget.scrollController);
    _attachController(widget.controller);
    unawaited(_initList());
  }

  @override
  void didUpdateWidget(
      InfiniteGroupedList<ItemType, GroupBy, GroupTitle> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _detachController(oldWidget.controller);
      _attachController(widget.controller);
    } else if (widget.isReactiveMode != oldWidget.isReactiveMode) {
      _attachController(widget.controller);
    }

    if (widget.scrollController != oldWidget.scrollController) {
      _detachScrollController();
      _attachScrollController(widget.scrollController);
    }

    if (widget.isReactiveMode) {
      if (widget.reactiveItems != oldWidget.reactiveItems ||
          widget.reactiveIsLoading != oldWidget.reactiveIsLoading ||
          widget.reactiveHasReachedMax != oldWidget.reactiveHasReachedMax ||
          widget.reactiveError != oldWidget.reactiveError) {
        _handleReactiveDataUpdate();
      }
    } else if (widget.groupBy != oldWidget.groupBy ||
        widget.groupCreator != oldWidget.groupCreator ||
        widget.sortGroupBy != oldWidget.sortGroupBy ||
        widget.groupSortOrder != oldWidget.groupSortOrder) {
      _updateState(_rebuildGroupsFromAllItems);
    }

    if (widget.enableAnchoring != oldWidget.enableAnchoring &&
        !widget.enableAnchoring) {
      _groupHeaderContexts.clear();
    }
  }

  CustomScrollView _buildList() {
    return CustomScrollView(
      controller: _scrollController,
      physics: widget.physics,
      slivers: groupTitles.map<Widget>((title) {
        return SliverStickyHeader.builder(
          sticky: widget.stickyGroups,
          builder: (context, state) {
            if (!widget.showGroups) {
              return const SizedBox.shrink();
            }
            final header = widget.groupTitleBuilder(
              title,
              widget.groupBy(
                groupedItems[title]!.first,
              ),
              state.isPinned,
              state.scrollPercentage,
            );
            if (widget.enableAnchoring) {
              _scheduleHeaderContextUpdate(title, context);
            }
            return header;
          },
          sliver: widget.listStyle == ListStyle.listView
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final item = groupedItems[title]![i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          widget.itemBuilder(item),
                          if (widget.separatorBuilder != null)
                            widget.separatorBuilder!(item),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          widget.itemBuilder(item),
                          if (widget.separatorBuilder != null)
                            widget.separatorBuilder!(item),
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
              child: widget.loadMoreItemsErrorWidget?.call(error) ??
                  const Text(
                    'Oops something went wrong !',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
            ),
        ]),
    );
  }

  @override
  void dispose() {
    _detachScrollController();
    _detachController(widget.controller);
    _groupHeaderContexts.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading && _allItems.isEmpty
        ? widget.loadingWidget
        : widget.showRefreshIndicator
            ? RefreshIndicator(
                color: widget.refreshIndicatorColor,
                backgroundColor: widget.refreshIndicatorBackgroundColor,
                onRefresh: _refresh,
                child: groupTitles.isEmpty
                    ? EmptyList(
                        widget: widget,
                        hasError: hasError,
                        error: error,
                      )
                    : _buildList(),
              )
            : groupTitles.isEmpty
                ? EmptyList(
                    widget: widget,
                    hasError: hasError,
                    error: error,
                  )
                : _buildList();
  }

  Map<GroupTitle, List<ItemType>> _groupItems(List<ItemType> items) {
    return _groupManager.initialize(items);
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
  /// The constructor for the controller.
  InfiniteGroupedListController({
    this.limit = 20,
  });

  List<ItemType> Function()? _getItemsCallback;

  Future<void> Function()? _loadItemsCallback;

  Future<void> Function()? _refreshCallback;

  void Function(ItemType item)? _removeCallback;

  void Function(List<ItemType> items, {int? index})? _addItemsCallback;

  void Function(bool Function(ItemType) predicate)? _removeWhereCallback;

  Future<bool> Function(
    _JumpToGroupRequest<GroupTitle, GroupBy> request,
  )? _jumpToGroupCallback;

  bool _isReactiveMode = false;

  /// The limit of items to fetch in a single call.
  int limit;

  /// Call this function to get the items in the list.
  List<ItemType> getItems() {
    return _getItemsCallback?.call() ?? <ItemType>[];
  }

  /// Call this function to programmatically fetch the next page
  ///
  /// If the last call failed then it retries the same page.
  ///
  /// In reactive mode, this triggers the configured external load callback
  /// using the same in-flight guard as scroll-based pagination.
  Future<void> loadItems() {
    return _loadItemsCallback?.call() ?? Future<void>.value();
  }

  /// Refresh the list.
  Future<void> refresh() {
    return _refreshCallback?.call() ?? Future.value();
  }

  /// Scrolls the list so that the group identified by [title] or [predicate]
  /// becomes visible. Returns true if the group could be found and focused.
  ///
  /// * Pass `title` when you already know the exact visual label of the group.
  /// * Pass `predicate` (and keep `title` null) when the target must be resolved dynamically (e.g. match today's date).
  /// * `animate`, `duration`, `curve`, and `alignment` are forwarded to [Scrollable.ensureVisible].
  /// * `loadUntilFound` is imperative-only and keeps fetching more pages until the group appears.
  /// * `maxRetries` caps the extra page loads attempted when `loadUntilFound`
  ///   is true. Defaults to 3. A value of 0 disables retry loads.
  Future<bool> jumpToGroup({
    GroupTitle? title,
    bool Function(GroupTitle title, GroupBy groupBy)? predicate,
    bool animate = true,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.ease,
    double alignment = 0.0,
    bool loadUntilFound = false,
    int maxRetries = _defaultJumpToGroupMaxRetries,
  }) {
    if ((title == null) == (predicate == null)) {
      throw ArgumentError(
        'Provide exactly one of title or predicate when calling jumpToGroup.',
      );
    }
    if (maxRetries < 0) {
      throw ArgumentError.value(
        maxRetries,
        'maxRetries',
        'must be greater than or equal to 0',
      );
    }

    if (_jumpToGroupCallback == null) {
      return Future.value(false);
    }

    return _jumpToGroupCallback!(
      _JumpToGroupRequest<GroupTitle, GroupBy>(
        title: title,
        predicate: predicate,
        animate: animate,
        duration: duration,
        curve: curve,
        alignment: alignment,
        loadUntilFound: loadUntilFound,
        maxRetries: maxRetries,
      ),
    );
  }

  /// Remove an item from the list.
  ///
  /// Note: This method is not supported in reactive mode.
  /// In reactive mode, manage data through your external state management solution.
  void remove(ItemType item) {
    if (_isReactiveMode) {
      throw UnsupportedError(
        'remove() is not supported in reactive mode. '
        'Manage data through your external state management solution.',
      );
    }
    _removeCallback?.call(item);
  }

  /// Add items to the list.
  /// If index is provided, the items will be added at that index.
  ///
  /// Note: This method is not supported in reactive mode.
  /// In reactive mode, manage data through your external state management solution.
  void addItems(List<ItemType> items, {int? index}) {
    if (_isReactiveMode) {
      throw UnsupportedError(
        'addItems() is not supported in reactive mode. '
        'Manage data through your external state management solution.',
      );
    }
    _addItemsCallback?.call(items, index: index);
  }

  /// Remove items from the list based on a predicate.
  /// The predicate should return true for items that should be removed.
  ///
  /// Note: This method is not supported in reactive mode.
  /// In reactive mode, manage data through your external state management solution.
  void removeWhere(bool Function(ItemType) predicate) {
    if (_isReactiveMode) {
      throw UnsupportedError(
        'removeWhere() is not supported in reactive mode. '
        'Manage data through your external state management solution.',
      );
    }
    _removeWhereCallback?.call(predicate);
  }
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

class _JumpToGroupRequest<GroupTitle, GroupBy> {
  _JumpToGroupRequest({
    this.title,
    this.predicate,
    required this.animate,
    required this.duration,
    required this.curve,
    required this.alignment,
    required this.loadUntilFound,
    required this.maxRetries,
  });

  final GroupTitle? title;
  final bool Function(GroupTitle title, GroupBy groupBy)? predicate;
  final bool animate;
  final Duration duration;
  final Curve curve;
  final double alignment;
  final bool loadUntilFound;
  final int maxRetries;
}
