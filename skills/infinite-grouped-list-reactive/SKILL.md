---
name: infinite-grouped-list-reactive
description: Connect infinite_grouped_list to external state (BLoC, Cubit, Riverpod, Provider, signals) through InfiniteGroupedList.reactive or .reactiveGrid, including grids and jumpToGroup with external state. Use when the app's state layer fetches pages and the list only displays items, isLoading, hasReachedMax and error, or when a reactive grouped list stalls, shows "No items found" too early, keeps showing an error, or re-groups on every emission. For lists where the widget calls the API itself, use infinite-grouped-list-pagination.
---

# infinite_grouped_list: reactive mode

Applies to `infinite_grouped_list` 2.x. In reactive mode **your state layer
owns the items and does the fetching**. The widget renders that state and calls
`onLoadMoreTriggered` when it needs another page.

2.x requires `material_ui` (Flutter >= 3.44). Import widgets from
`package:material_ui/material_ui.dart`, not `package:flutter/material.dart`.
The widget is a `CustomScrollView`, so it needs a bounded height: wrap it in
`Expanded` inside a `Column`.

## State contract

Your state must expose these four values:

| Widget param | Meaning |
|---|---|
| `items` | **A new `List` instance** every time the content changes |
| `isLoading` | `true` while any page (including the first) is in flight |
| `hasReachedMax` | `true` once the source has no more pages |
| `error` | non-null while the last load failed, **and cleared on success** |

The widget only reacts when one of these four values changes, and it compares
`items` by identity. So:

- **Emit a new list:** `items: [...state.items, ...page]`. Never mutate and
  re-emit the same list.
- **Every `onLoadMoreTriggered` call must produce a state change**, at least
  `isLoading: true`. The widget blocks further triggers until it sees one. If
  your handler silently ignores the event (an early `return` with no `emit`),
  pagination stalls for good.
- **The widget does not request the first page.** Dispatch the initial load
  yourself (e.g. `ItemsBloc()..add(LoadItems())`). Start the state with
  `isLoading: true` so users don't see "No items found" before the first
  response.

## BLoC example

```dart
class ItemsState {
  const ItemsState({
    this.items = const [],
    this.isLoading = true, // the first load is pending
    this.hasReachedMax = false,
    this.error,
  });

  final List<Item> items;
  final bool isLoading;
  final bool hasReachedMax;
  final Object? error;

  // `error ?? this.error` could never clear an error, so take it explicitly.
  ItemsState copyWith({
    List<Item>? items,
    bool? isLoading,
    bool? hasReachedMax,
    Object? Function()? error,
  }) => ItemsState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    error: error != null ? error() : this.error,
  );
}

Future<void> _onLoadMore(LoadMore event, Emitter<ItemsState> emit) async {
  emit(state.copyWith(isLoading: true, error: () => null));
  try {
    final page = await repo.fetch(offset: state.items.length, limit: pageSize);
    emit(state.copyWith(
      items: [...state.items, ...page],
      isLoading: false,
      hasReachedMax: page.length < pageSize,
    ));
  } catch (e) {
    emit(state.copyWith(isLoading: false, error: () => e));
  }
}

Future<void> _onRefresh(Refresh event, Emitter<ItemsState> emit) async {
  // Keep the old items visible. Emitting an empty list here would swap the
  // list for the full-screen loader under the refresh spinner.
  emit(state.copyWith(isLoading: true, error: () => null));
  try {
    final page = await repo.fetch(offset: 0, limit: pageSize);
    emit(ItemsState(
      items: page,
      isLoading: false,
      hasReachedMax: page.length < pageSize,
    ));
  } catch (e) {
    emit(state.copyWith(isLoading: false, error: () => e));
  }
}
```

If a load-more can still be in flight during a refresh, it will append a stale
page to the refreshed list. Prevent that by handling both events with a
`sequential()` transformer (`package:bloc_concurrency`), or drop any page whose
base list is no longer `state.items`.

```dart
BlocBuilder<ItemsBloc, ItemsState>(
  builder: (context, state) => InfiniteGroupedList<Item, String, String>.reactive(
    items: state.items,
    isLoading: state.isLoading,
    hasReachedMax: state.hasReachedMax,
    error: state.error,
    onLoadMoreTriggered: () => context.read<ItemsBloc>().add(LoadMore()),
    onRefresh: () {
      final bloc = context.read<ItemsBloc>()..add(Refresh());
      // The refresh spinner stays until this future completes.
      return bloc.stream.firstWhere((s) => !s.isLoading);
    },
    groupBy: (item) => item.category,
    groupCreator: (category) => category,
    groupTitleBuilder: (title, groupBy, isPinned, scrollPercentage) =>
        Text(title),
    itemBuilder: (item) => ListTile(title: Text(item.name)),
    groupingKey: 'category', // inline closures above: see below
    errorWidget: (error) => TextButton(
      onPressed: () => context.read<ItemsBloc>().add(LoadMore()),
      child: const Text('Retry'),
    ),
  ),
)
```

With Riverpod or Provider, keep the same immutable state class in a
`Notifier`/`ChangeNotifier` instead of `AsyncValue<List<T>>`, which has nowhere
to hold `hasReachedMax` and loses the loaded items on error. Map the four
fields directly and call the notifier's `loadMore()` from
`onLoadMoreTriggered`. With `ChangeNotifier`, assign a new list
(`_items = [..._items, ...page]`) instead of calling `addAll` on the old one.

## Behaviour to rely on

- `isLoading: true` with no items shows `loadingWidget` full screen. With items,
  it shows the loader at the bottom.
- `error` with no items replaces the list with `errorWidget(error)`. With items,
  `errorWidget` appears at the bottom. Use `errorWidget` for both cases.
- While `error` is set, scrolling does **not** trigger more loads, so the list
  can't loop on retries. A retry button can dispatch your load event directly,
  as in the example. Or it can call `controller.loadItems()`, which fires
  `onLoadMoreTriggered` even while `error` is set. Your load-more handler then
  also has to work from an empty list, for a failed first page.
- **Pull-to-refresh only appears when you pass `onRefresh`**, because in
  reactive mode it does nothing except await it. Make `onRefresh` dispatch your
  refresh and complete when it finishes, as in the example.
- After each update the widget requests pages until the viewport is full.
  Expect several `onLoadMoreTriggered` calls in a row on tall screens.
- When only the tail of the list grows (a newly loaded page), only the new
  items are grouped. Any other change to `items` re-groups everything.

## Grouping rules

- Items are grouped by the `GroupTitle` that `groupCreator` returns, compared
  with `==`. Make the title unique per group (include the year in date titles)
  and use a type with value equality.
- If `groupBy`, `groupCreator` or `sortGroupBy` are inline closures (new on
  every build), set `groupingKey`. Without it, every emission re-groups all
  items. Change the key only when the grouping logic changes.
- Groups appear in the order they are first met in `items`. `sortGroupBy` and
  `groupSortOrder` (default descending) sort only **within** a group. Order
  your data by group upstream.

## Controller in reactive mode

- `controller.addItems`, `controller.remove` and `controller.removeWhere` throw
  `UnsupportedError`. Change your state instead.
- `jumpToGroup` needs `enableAnchoring: true`. With `loadUntilFound: true` it
  throws `UnsupportedError` if the group isn't loaded yet. Load the pages in
  your state, wait a frame (`await WidgetsBinding.instance.endOfFrame;`) so the
  new headers are registered, then call `jumpToGroup`.
- `InfiniteGroupedListController.limit` is ignored. Your state decides the page
  size.
- If you use a controller, hold it in `State`, not in `build`.

## Grid

Use `.reactiveGrid(...)` with the same contract plus `gridDelegate`. Set the
delegate explicitly; the default is 3 columns with `childAspectRatio: 2`.
