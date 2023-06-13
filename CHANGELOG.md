## 1.0.2 ✨ Simplifies & Improves API

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
