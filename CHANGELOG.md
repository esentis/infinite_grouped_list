## 1.5.0

### Added

- Added `itemKeyBuilder` to all four constructors. When provided, each item row is keyed and the sliver delegates use `findChildIndexCallback`, so inserting or removing items preserves the element (and its `State`) of the remaining items instead of shifting it onto their neighbours — animations, text controllers, and scroll positions inside tiles survive list mutations. Keys must be unique among the currently loaded items.
- Added `==`, `hashCode`, `toString`, and `copyWith` to `PaginationInfo`.

### Changed

- Error-related parameters and fields (`initialItemsErrorWidget`, `loadMoreItemsErrorWidget`, the reactive `error`, and reactive `errorWidget`) are now typed `Object?` instead of `dynamic`. Existing call sites remain source-compatible.

### Fixed

- Reactive mode (`.reactive()` / `.reactiveGrid()`) now re-groups items immediately when `groupBy`, `groupCreator`, `sortGroupBy`, or `groupSortOrder` change, matching imperative-mode behaviour. Previously the list kept rendering with the old grouping until the next external data update arrived.

### Docs

- Documented that anchoring identifies groups by their `GroupTitle` value, so `GroupTitle` should implement `==` and `hashCode` consistently for `jumpToGroup` to resolve reliably.
- Documented that with paging enabled and loaded content shorter than the viewport, additional pages are fetched automatically as the user scrolls until the viewport fills.

## 1.4.3

### Fixed

- Default empty-state, initial-error, and load-more-error texts now follow the
  active `Theme` instead of hardcoding `Colors.black`, which rendered them
  barely visible on dark themes. The empty text uses `colorScheme.onSurface`
  and both error texts use `colorScheme.error`. Custom widgets and error
  builders are unaffected.
- Sorting items **within** a group is now stable. Dart's `List.sort` is not a
  stable sort, so items whose sort keys compared equal could silently reorder
  whenever their group was re-sorted as new pages were merged in. Equal-keyed
  items now deterministically keep the order in which they arrived, across
  pagination, refreshes, re-groups, and item removals.
- An internally owned `ScrollController` is now disposed after the current
  frame ends. Swapping from an internal controller to an external one no
  longer risks the child `Scrollable` touching a disposed controller while it
  releases its scroll position.

### Changed

- Removed unused internal pagination helper methods. No public API impact.

### Docs

- Removed a stale `[padding]` reference from the constructor documentation;
  that parameter was removed in an earlier release.
- The controller documentation now lists all of its capabilities (`getItems`,
  `loadItems`, `refresh`, `addItems`, `remove`, `removeWhere`,
  `jumpToGroup`) instead of only the original three.
- Fixed typos in doc comments ("seperator" → "separator", "grpup" → "group").

### Testing

- Added regression tests for dark-theme default text colors, sort stability
  with equal keys (unit-level through `GroupManager` and widget-level across
  paginated loads), and internal-to-external scroll controller swap lifecycle.

## 1.4.2

### Fixed

- Separators from `separatorBuilder` are no longer drawn after the last item of each group. Previously a trailing separator appeared beneath the final item of every group (just above the next header); separators now appear only _between_ items, matching the documented intent and `ListView.separated` semantics. This applies to both list and grid layouts. If you relied on the trailing separator, add the spacing via the group header or item padding instead.

Previous vs current behaviour:
![image](https://i.ibb.co/20G4sX9L/Screenshot-2026-07-23-at-12-48-57-AM.png)

- `refresh()` (pull-to-refresh and `controller.refresh()`) is no longer silently skipped when a scroll-triggered load-more is still in flight. The refresh now waits for the pending load to settle and then resets pagination and re-fetches the first page.

### Docs

- Clarified that `sortGroupBy` / `groupSortOrder` sort items **within** each group, while the order of the groups themselves follows the order in which each group is first encountered in the loaded data.
- Documented that grouping callbacks (`groupBy`, `groupCreator`, `sortGroupBy`) should be stable references to avoid unnecessary re-grouping on parent rebuilds.

## 1.4.1

### Fixed

- List items now stretch to the full cross-axis width. Previously, items were centered with intrinsic width. Wrap items in `Center` if you relied on the old behavior.

## 1.4.0

### Added

- Expanded package-level test coverage across pagination, refresh, reactive loading, anchoring, helper classes, and empty/error states.
- Added `maxRetries` to `jumpToGroup(loadUntilFound: true)` so callers can cap extra page loads explicitly.

### Changed

- Moved tooling packages out of runtime dependencies.

### Fixed

- Fixed controller rebinding and external `ScrollController` ownership so parent-managed controllers are no longer disposed by the widget.
- Prevented duplicate reactive `onLoadMoreTriggered` dispatches while a reactive load is already pending.
- Stopped `jumpToGroup(loadUntilFound: true)` from retrying forever after load failures.
  - There is also optional `maxRetries` parameter to cap the extra page loads defaulting to `3`.

### Breaking Changes

- Removed the misspelled `seperatorBuilder` API. Use `separatorBuilder`.

## 1.3.1

### Added

- Added optional `enableAnchoring` plus `InfiniteGroupedListController.jumpToGroup` so apps can programmatically snap to any group header, such as "Today".

### Fixed

- Replaced an invalid `Spacer` usage in the example app's `ListView`, eliminating the `ParentDataWidget` assertion and keeping the showcase aligned with the package API.

## 1.3.0

### Added

- Added `InfiniteGroupedList.reactive()` for reactive state management patterns.
- Added `InfiniteGroupedList.reactiveGrid()` for grid layouts with reactive patterns.
- Added external state support through `items`, `isLoading`, `hasReachedMax`, and `error`.
- Added a comprehensive reactive BLoC example with mock API, error handling, and loading states.

### Changed

- Improved controller behavior so it adapts automatically to reactive versus imperative mode.
- Added safety guards so controller mutation methods throw helpful errors in reactive mode.
- Improved lifecycle handling so reactive widgets update when external state changes through `didUpdateWidget`.
- Optimized reactive data handling to avoid unnecessary rebuilds.
- Expanded the example app with richer navigation, more polished UI, and clearer pattern comparison.
- Improved the documentation with more complete usage guidance and architectural examples.

### Breaking Changes

- None.

## 1.2.11

### Changed

- Upgraded dependencies to newer versions.

## 1.2.10

### Added

- Added `scrollController` to all constructors so callers can provide their own scroll controller.

## 1.2.9

### Added

- Added helper methods for group management: `_sortSingleGroup`, `_addItemsToGroups`, and `_createInitialGroups`.

### Changed

- Optimized group operations with targeted updates instead of full regrouping.
- Reduced memory usage by avoiding unnecessary data structure recreation.
- Implemented more efficient item addition with selective group updates.
- Optimized item removal with targeted group processing.
- Improved refresh operation efficiency.

### Fixed

- Fixed potential memory leaks by properly clearing controller callbacks.
- Improved scroll performance for large datasets.
- Improved handling of empty groups after item removal.

## 1.2.8

### Fixed

- Fixed deprecated `hashValues` usage.

## 1.2.7

### Added

- Added `addItems` to `InfiniteGroupedListController`.
- Added `removeWhere` to `InfiniteGroupedListController`.

### Changed

- Hid internal methods in `InfiniteGroupedListController`.

## 1.2.6

### Added

- Added `limit` to `InfiniteGroupedListController` to define the expected page size from remote calls.
- Added `onNoMoreItemsFound`, which is triggered when the response contains fewer items than the configured `limit`.

## 1.2.5

### Changed

- Refactored `InfiniteGroupedListController` to avoid `LateInitializationError`s.

## 1.2.4

### Fixed

- Added missing `showRefreshIndicator` support to the default constructor.

## 1.2.3

### Added

- Added `showRefreshIndicator`, which defaults to `true`.

## 1.2.2

### Added

- Added missing `Key` support.

## 1.2.1

### Added

- Added `remove(ItemType)` to the controller so items can be removed programmatically.

## 1.2.0

### Added

- Added the `physics` parameter. It defaults to `AlwaysScrollablePhysics`.

### Changed

- Tweaked `initialItemsErrorWidget` and `loadMoreItemsErrorWidget`. They now accept the error and return a `Widget`.

```dart
initialItemsErrorWidget: (error) => GestureDetector(
  child: Text(
    error.toString(),
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
      decorationColor: Colors.blue,
      color: Colors.blue,
    ),
  ),
),
loadMoreItemsErrorWidget: (error) => GestureDetector(
  child: Text(
    error.toString(),
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
      decorationColor: Colors.blue,
      color: Colors.blue,
    ),
  ),
),
```

### Breaking Changes

- `initialItemsErrorWidget` and `loadMoreItemsErrorWidget` now receive the error and must return a widget.

## 1.1.2

### Fixed

- Initialized `getItems` with a default empty list to avoid `LateInitializationError`.

### Changed

- Internal code refactoring.

## 1.1.1

### Changed

- Internal code refactoring.

## 1.1.0

### Added

- Added `InfiniteGroupedList.gridView`.

<img src='https://i.imgur.com/hRv7sEq.gif' height=550>

### Changed

- Made `separatorBuilder` optional.
- Made `sortGroupBy` optional.

### Fixed

- Removed the padding that was not removed in the previous version.

## 1.0.1

### Added

- Added `isPaged`. When `onLoadMore` is not paged, set this to `false` to prevent the same items from being appended repeatedly. It defaults to `true`.

### Fixed

- Removed the unused `padding` parameter.
- Added a `mounted` check before calling `setState`.

## 1.0.0

### Added

- Initial release.
