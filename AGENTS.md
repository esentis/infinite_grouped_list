# AGENTS.md

This file gives coding agents repository-specific guidance for working on
`infinite_grouped_list`.

## Project Overview

`infinite_grouped_list` is a Flutter package for rendering grouped infinite
lists with sticky headers. It supports:

- imperative pagination via `onLoadMore`
- reactive state-management integrations via `.reactive()` and `.reactiveGrid()`
- `ListView` and `GridView`-style sliver layouts
- pull-to-refresh
- sticky group headers
- optional jump-to-group anchoring through the controller

Current package version: `2.1.0` (see `pubspec.yaml`). Add a
`CHANGELOG.md` entry with every version bump.

Since 2.0.0 the package depends on `material_ui` instead of
`package:flutter/material.dart` (Dart >= 3.12, Flutter >= 3.44). Import
widgets from `package:material_ui/material_ui.dart` in `lib/`, `test/` and
`example/`.

## Tooling And Commands

Use `fvm` in this repository. Do not assume `flutter` is available directly on
`PATH`.

### Core Commands

- `fvm flutter analyze`
- `fvm flutter test`
- `fvm flutter test --coverage`
- `fvm flutter pub get`
- `fvm flutter pub deps`
- `fvm dart format <paths...>` (format only the files you changed; the
  formatter may reflow untouched files)
- `./tool/install_git_hooks.sh`
- `./.githooks/pre-push`

### Example App

The example app lives in `example/`.

- `cd example && fvm flutter pub get`
- `cd example && fvm flutter run`
- `cd example && fvm flutter analyze`

### External Drive Note

The checkout may live on an ExFAT drive, where macOS creates `._*`
AppleDouble files. `flutter test` picks up `test/._*_test.dart` and crashes with
`LiveTest.run() may not be called for a closed test`. Run `dot_clean -m .`
before testing. `._*` is excluded in `.git/info/exclude`, so the files never
show up in `git status`.

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
- `itemKeyBuilder` enables keyed child reuse via `findChildIndexCallback`;
  provided keys must be unique among currently loaded items.
- `groupingKey` (1.6.0): when set, items re-group only when the key changes,
  so inline closures don't re-group on every rebuild. When null, callback
  identity is compared.
- Reactive mode re-groups immediately when grouping callbacks change.
- `sortGroupBy` must return a `Comparable`. It and `groupSortOrder` sort items
  within a group only; groups keep first-seen order.
- `onRefresh` accepts sync or async callbacks via `FutureOr<void>`.
- `showRefreshIndicator` defaults to `true` in imperative mode and to
  `onRefresh != null` in reactive mode.
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
  `onLoadMoreTriggered`. `loadItems()` fires it even while `error` is set, so
  it can back a retry button.
- `loadItems()` awaits the actual load operation. After a failed first page or
  refresh it reloads page 1 instead of appending.
- A State only detaches the controller if the controller still points at that
  State, so a controller shared across a remount (new `key`) stays attached.
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
  bottom. After every load, reactive update and removal, the widget also keeps
  requesting pages until the viewport is filled.
- Imperative pagination uses `PaginationInfo(offset, page, limit)`.
- A result shorter than `controller.limit` marks the list as exhausted and
  triggers `onNoMoreItemsFound`.
- Reactive mode guards against duplicate `onLoadMoreTriggered` dispatches while
  a load is pending. The guard resets only when `items`, `isLoading`,
  `hasReachedMax` or `error` changes.
- `jumpToGroup(loadUntilFound: true)` is imperative-only and should stop on load
  failure instead of retrying forever.

## Agent Skills

`skills/` holds the package skills published with the package and installed by
app developers with `dart run skills@ get`:

- `skills/infinite-grouped-list-pagination/SKILL.md` (imperative mode)
- `skills/infinite-grouped-list-reactive/SKILL.md` (reactive mode)

When you change public behaviour, update the affected skill in the same change.
Check every claim against the source, keep the code snippets compiling, and
keep each `SKILL.md` well under 500 lines. Validate with `skills_lint`, and
check that both skills appear in `dart pub publish --dry-run`.

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

skills/
├── infinite-grouped-list-pagination/SKILL.md
└── infinite-grouped-list-reactive/SKILL.md

test/
├── anchoring_parent_data_test.dart
├── empty_list_test.dart
├── group_manager_test.dart
├── infinite_grouped_list_test.dart
├── pagination_info_test.dart
├── regression_1_6_0_test.dart
├── regression_2_1_0_test.dart
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
indirectly through widget tests. Add a regression test that fails before each
bug fix.

## Dependency Notes

Runtime dependencies:

- `flutter_sticky_header`
- `material_ui`

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
