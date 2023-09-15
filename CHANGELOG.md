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
