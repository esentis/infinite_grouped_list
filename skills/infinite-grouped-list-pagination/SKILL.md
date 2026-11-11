---
name: infinite-grouped-list-pagination
description: Build a grouped, infinitely scrolling list with the infinite_grouped_list package where the widget fetches pages itself through onLoadMore. Use when adding InfiniteGroupedList or InfiniteGroupedList.gridView, wiring PaginationInfo to an API, grouping items under sticky headers, or using InfiniteGroupedListController (refresh, retry, add/remove items, jumpToGroup). For BLoC/Riverpod/Provider-driven lists use infinite-grouped-list-reactive instead.
---

# infinite_grouped_list: imperative pagination

Applies to `infinite_grouped_list` 2.x. In this mode the widget calls your
`onLoadMore` and owns the loaded items. If the app keeps the items in
BLoC, Riverpod, Provider or another store, use the
`infinite-grouped-list-reactive` skill instead.

## Prerequisites

- 2.x requires `material_ui` (Flutter >= 3.44, Dart >= 3.12). Import widgets
  from `package:material_ui/material_ui.dart`, not
  `package:flutter/material.dart`. Apps still on `package:flutter/material.dart`
  must stay on `infinite_grouped_list: ^1.6.0`.
- One import gives you everything public, including `PaginationInfo` and
  `SortOrder`:
  `import 'package:infinite_grouped_list/infinite_grouped_list.dart';`
- The widget is a `CustomScrollView`, so it needs a bounded height. Inside a
  `Column`, wrap it in `Expanded`. Don't put it inside another scroll view.

## Minimal correct setup

```dart
class TransactionsList extends StatefulWidget {
  const TransactionsList({super.key});

  @override
  State<TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  // Keep the controller in State, never create it inside build().
  final _controller =
      InfiniteGroupedListController<Transaction, DateTime, String>(limit: 20);

  @override
  Widget build(BuildContext context) {
    return InfiniteGroupedList<Transaction, DateTime, String>(
      controller: _controller,
      onLoadMore: (info) => api.fetchTransactions(
        offset: info.offset, // or page: info.page
        limit: info.limit, // never hardcode the page size
      ),
      groupBy: (tx) => DateUtils.dateOnly(tx.date),
      groupCreator: (day) => '${day.day}/${day.month}/${day.year}',
      groupTitleBuilder: (title, groupBy, isPinned, scrollPercentage) =>
          Padding(padding: const EdgeInsets.all(8), child: Text(title)),
      itemBuilder: (tx) => ListTile(title: Text(tx.title)),
      groupingKey: 'by-day', // see "Grouping rules"
    );
  }
}
```

The generic types are `<ItemType, GroupBy, GroupTitle>`. `groupBy` maps an item
to `GroupBy`, and `groupCreator` maps `GroupBy` to the `GroupTitle` that is
shown. Write the type arguments out anyway: then a mistake in one closure is
reported where it happens, not as a confusing type error somewhere else.

## Pagination rules

- **Request `info.limit` items.** A page with fewer than `limit` items marks
  the list as exhausted. If you hardcode `limit: 10` while the controller limit
  is 20 (the default), the list stops after the first page.
- Set the page size on the controller: `InfiniteGroupedListController(limit: n)`
  or `controller.limit`.
- `info.offset` counts loaded items and `info.page` starts at 1. Use whichever
  your API expects.
- If the API returns everything in one response, set `isPaged: false`.
  Otherwise each scroll appends the same items again.
- The widget fills the viewport by itself: it keeps requesting pages until the
  content scrolls or the data runs out. Don't add your own "load until full"
  logic.
- **Changing a search query, filter or sort does not refetch**, even if
  `onLoadMore` captures it. Call `_controller.refresh()` after the change.
- `onNoMoreItemsFound` fires when the data runs out, and again after each
  refresh that runs out.
- Pull-to-refresh is on by default (`showRefreshIndicator: true`) and reloads
  from page 1 by itself. `onRefresh` is optional: if you pass it, the widget
  awaits it before reloading, for example to clear a cache. The old items stay
  on screen until the reload succeeds.

## Errors and retry

- To signal a failure, **throw** from `onLoadMore`. Don't return an empty list,
  because that means "no more data".
- A failed first page shows `initialItemsErrorWidget(error)` instead of the
  list. A failed later page, or a failed refresh while items are shown, shows
  `loadMoreItemsErrorWidget(error)` at the bottom.
- Scrolling doesn't retry, so give both error widgets a retry button that
  calls `_controller.loadItems()`. It retries the failed page, or page 1 if
  the first load or a refresh failed.
- `noItemsFoundWidget` is shown when the list is empty without an error.

## Grouping rules

- **Items are grouped by the `GroupTitle` that `groupCreator` returns, compared
  with `==`.** Make the title unique per group (include the year in date
  titles) and use a type with value equality. Otherwise unrelated groups merge,
  or every item ends up in its own group.
- **Inline closures re-group everything on every rebuild.** If `groupBy`,
  `groupCreator` or `sortGroupBy` are written inline in `build`, set
  `groupingKey` to any value that stays the same while the grouping logic is
  the same. Change the key when the logic changes, for example
  `groupingKey: groupMode` for a "by date / by type" toggle. You can skip the
  key if the callbacks are top-level or static functions, or methods torn off
  a `State`. A method torn off a `StatelessWidget` is a new object on every
  build.
- **Groups appear in the order they are first met in the loaded data.** Neither
  `sortGroupBy` nor `groupSortOrder` reorders groups. To get newest-first date
  groups, the API must return items newest-first.
- `sortGroupBy` sorts items **inside** each group, and `groupSortOrder` (default
  `SortOrder.descending`) sets that direction.
- Use `isPinned` in `groupTitleBuilder` to style a header while it is stuck.
  Set `stickyGroups: false` to turn sticky headers off, and `showGroups: false`
  to hide headers entirely.

## Item identity and separators

- If items can be inserted or removed while tiles hold state (text fields,
  animations, expansion), pass `itemKeyBuilder: (item) => ValueKey(item.id)`.
  Keys must be unique among the loaded items.
- Use `separatorBuilder` (the misspelled `seperatorBuilder` was removed in
  1.4.0). It receives the item above the separator and is not drawn after the
  last item of a group.

## Controller operations

Local edits, which never fetch:

- `getItems()`: an unmodifiable copy of the items
- `addItems(items, index: i)`: `index` is a position in the flat item list,
  not inside a group
- `remove(item)`: matches with `==`, so for models without `==` use
  `removeWhere((t) => t.id == id)`
- `removeWhere(predicate)`

Local edits don't change `info.offset`. If the server also gained or lost
those items, call `refresh()` so offsets stay aligned.

Fetching:

- `refresh()`: awaits `onRefresh`, then reloads page 1
- `loadItems()`: fetches the next page, or retries a failed one

## Jump to a group

```dart
InfiniteGroupedList<Transaction, DateTime, String>(
  enableAnchoring: true, // required: without it the jump's future fails with StateError
  controller: _controller,
  // ...
);

await _controller.jumpToGroup(
  predicate: (title, day) => DateUtils.isSameDay(day, DateTime.now()),
  loadUntilFound: true, // fetch more pages until the group appears
  maxRetries: 3,
);
```

- Pass exactly one of `title` or `predicate`. Passing both or neither throws
  `ArgumentError`.
- `GroupTitle` must implement `==` and `hashCode`. `String` and `DateTime` do.
- The call returns `false` if the group is never found.

## Grid layout

Use `InfiniteGroupedList.gridView(...)` with the same parameters plus
`gridDelegate`. If you leave `gridDelegate` out, it defaults to 3 columns with
`childAspectRatio: 2`, so set it explicitly. Items fill their cell. With a
`separatorBuilder`, the item gets the space the separator leaves.

## Don't

- Don't create `InfiniteGroupedListController` or `ScrollController` inside
  `build`.
