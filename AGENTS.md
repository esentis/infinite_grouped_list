# AGENTS.md

This file provides repository-specific guidance for Codex when working in
`/Users/esentis/Development/infinite_grouped_list`.

## Project Overview

`infinite_grouped_list` is a Flutter package for rendering grouped infinite
lists with sticky headers. It supports:

- imperative pagination via `onLoadMore`
- reactive state-management integrations via `.reactive()` and `.reactiveGrid()`
- `ListView` and `GridView`-style sliver layouts
- pull-to-refresh
- sticky group headers
- optional jump-to-group anchoring through the controller

Current package version: `1.4.2`

## Tooling And Commands

Use `fvm` in this repository. Do not assume `flutter` is available directly on
`PATH`.

### Core Commands

- `fvm flutter analyze`
- `fvm flutter test`
- `fvm flutter test --coverage`
- `fvm flutter pub get`
- `fvm flutter pub deps`
- `fvm dart format <paths...>`
- `./tool/install_git_hooks.sh`
- `./.githooks/pre-push`

### Example App

The example app lives in `example/`.

- `cd example && fvm flutter pub get`
- `cd example && fvm flutter run`
- `cd example && fvm flutter analyze`

## Architecture

### Main Widget

Main implementation: `lib/src/infinite_grouped_list.dart`

`InfiniteGroupedList<ItemType, GroupBy, GroupTitle>` is the public widget.
Important constructors:

- `InfiniteGroupedList(...)`
- `InfiniteGroupedList.gridView(...)`
- `InfiniteGroupedList.reactive(...)`
- `InfiniteGroupedList.reactiveGrid(...)`

Important public API details:

- `separatorBuilder` is the correct separator parameter name.
- The old typo `seperatorBuilder` was removed in `1.4.0`.
- `sortGroupBy` must return a `Comparable`.
- `onRefresh` accepts sync or async callbacks via `FutureOr<void>`.
- `jumpToGroup(...)` requires `enableAnchoring: true`.

### Controller

`InfiniteGroupedListController<ItemType, GroupBy, GroupTitle>` provides:

- `getItems()`
- `loadItems()`
- `refresh()`
- `jumpToGroup(...)`
- `addItems(...)`
- `remove(...)`
- `removeWhere(...)`

Important behavior:

- `addItems`, `remove`, and `removeWhere` are imperative-only.
- In reactive mode, pagination is triggered externally through
  `onLoadMoreTriggered`.
- `loadItems()` now awaits the actual load operation.
- The widget correctly distinguishes owned vs external `ScrollController`s.

### Grouping Logic

Helper: `lib/src/helpers/group_manager.dart`

This owns grouping, merging, sorting, and removal behavior. Prefer keeping
grouping rules centralized here rather than duplicating logic inside the widget.

### Empty/Error Rendering

Helper: `lib/src/helpers/empty_list.dart`

This is responsible for the empty-state and initial-error rendering path.

## Behavioral Notes

- Infinite scrolling triggers when the scroll position is within `100px` of the
  bottom.
- Imperative pagination uses `PaginationInfo(offset, page, limit)`.
- A result shorter than `controller.limit` marks the list as exhausted and
  triggers `onNoMoreItemsFound`.
- Reactive mode includes internal guarding against duplicate
  `onLoadMoreTriggered` dispatches while a load is pending.
- `jumpToGroup(loadUntilFound: true)` is imperative-only and should stop on load
  failure instead of retrying forever.

## File Structure

```text
lib/
├── infinite_grouped_list.dart
└── src/
    ├── infinite_grouped_list.dart
    └── helpers/
        ├── empty_list.dart
        ├── enums.dart
        ├── group_manager.dart
        └── pagination_info.dart

test/
├── anchoring_parent_data_test.dart
├── empty_list_test.dart
├── group_manager_test.dart
├── infinite_grouped_list_test.dart
└── sticky_spacer_test.dart
```

## Testing Guidance

Before wrapping up code changes that affect package behavior, run:

- `fvm flutter analyze`
- `fvm flutter test`

When touching pagination, refresh, empty/error states, grouping, or controller
behavior, also run:

- `fvm flutter test --coverage`

Current package-level coverage is intentionally high and should not regress
without reason. Helper files should remain directly tested, not only exercised
indirectly through widget tests.

## Dependency Notes

Runtime dependency:

- `flutter_sticky_header`

Dev dependencies:

- `flutter_test`
- `lint`
- `test`

If you run coverage locally, `coverage/` is generated output rather than source.

## Git Hooks

This repository includes a repo-local pre-push hook in `.githooks/pre-push`.

- Install it with `./tool/install_git_hooks.sh`
- The installer sets `git config core.hooksPath .githooks` for this repo
- The pre-push hook runs `fvm flutter analyze` and `fvm flutter test`
