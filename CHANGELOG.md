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
