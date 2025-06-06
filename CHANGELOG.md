## 1.2.11 ⬆️ Upgrade dependencies

- Upgraded dependencies to the latest versions

## 1.2.10

- ✨ Added `scrollController` to all constructors, you can now pass your own scroll controller

## 1.2.9

#### Performance Improvements

- ⚡ Optimized group operations with targeted updates instead of full regrouping
- 🧠 Reduced memory usage by avoiding unnecessary data structure recreation
- 🚀 Implemented efficient item addition with selective group updates
- 🗑️ Optimized item removal with targeted group processing

#### Bug Fixes

- 🔍 Fixed potential memory leaks by properly clearing controller callbacks
- 🎯 Improved scroll performance for large datasets
- 🔄 Enhanced refresh operation efficiency

#### API Improvements

- ✨ Added helper methods for group management (`_sortSingleGroup`, `_addItemsToGroups`, `_createInitialGroups`)
- 📊 Better handling of empty groups after item removal

## 1.2.8 🐛 Bug fixes

- Fixes hashValues deprecated issues

## 1.2.7 ✨ New Features

- Adds `addItems` method in `InfiniteGroupedListController`
- Adds `removeWhere` method in `InfiniteGroupedListController`
- Hides internal methods in `InfiniteGroupedListController`

## 1.2.6 ✨ New Features

- Adds a new `limit` parameter in `InfiniteGroupedListController` to tell the library how much items are expected from the remote call
- Adds a callback `onNoMoreItemsFound` that is triggered when the response returns less items than the provided `limit`

## 1.2.5 ♻️ Refactoring

- Refactors `InfiniteGroupedListController` to avoid `LateInitializationErrors`

## 1.2.4 🐛 Bug fixes

- Adds missing `showRefreshIndicator` from default constructor

## 1.2.3 ✨ New Features

- Adds `showRefreshIndicator` flag which defaults to `true`

## 1.2.2 ✨ New Features

- Adds missing `Key`

## 1.2.1 ✨ New Features

- Adds `remove(ItemType)` method to the controller. You can now programmatically remove items from the list.

## 1.2.0 💥 Breaking changes

- Tweaks `initialItemsErrorWidget` & `loadMoreItemsErrorWidget` parameters. They are now function that returns a `Widget`, exposing the error aswell :

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

- Adds `physics` parameter. Defaults to [AlwaysScrollablePhysics]

## 1.1.2

- Initializes `getItems` with default empty List to avoid `LateInitializationError`
- Internal code refactoring

## 1.1.1

- Internal code refactoring

## 1.1.0 ✨ New Features - Simplifies & Improves API

- Adds new builder `InfiniteGroupedList.gridView`.
  Define your `gridDelegate` and customise it as you want.

<img src='https://i.imgur.com/hRv7sEq.gif' height=550>

- Fields made optional:
  - `seperatorBuilder`
  - `sortGroupBy`
- Removes the `padding` that was not removed on previous version.

## 1.0.1 🐛 Bug fixes & API improvements

- Removes `padding` parameter as it does not correspond to anything
- Adds `isPaged` parameter. If the `onLoadMore` is not paged, everytime the same items will be added to the list when the list reaches at the bottom. Therefore, we should set the `isPaged` to `false` and after the initial fetch it will stop fetching the items. It defaults to `true`
- Checks if `mounted` before setting state

## 1.0.0 🎉 Initial release

- Initial release
