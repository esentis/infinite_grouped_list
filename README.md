<p align="center">
<img src='https://i.imgur.com/eA2MXLC.gif' width=300>
</p>
<p align="center">
 <img src="https://img.shields.io/pub/v/infinite_grouped_list?color=637d0d&style=for-the-badge&logo=flutter" alt="Version" /> <img src="https://img.shields.io/github/languages/code-size/esentis/infinite_grouped_list?color=637d0d&style=for-the-badge&label=size" alt="Version" />
</br>
</p>

<p align="center">
Show some love by dropping a ⭐ at GitHub </br>
<a href="https://github.com/esentis/infinite_grouped_list/stargazers"><img src="https://img.shields.io/github/stars/esentis/infinite_grouped_list?style=for-the-badge&logo=github&color=637d0d" alt="HTML tutorial"></a>

# Infinite Grouped List

Brings together infinite scrolling, group-based item organization, and numerous other enhancements to improve the end-user experience.

### Key Features

- **Infinite Scrolling**: The widget supports loading more data as the user reaches the end of the list. This is essential for handling large datasets without overwhelming the user or their device.

- **Grouping of Items**: The widget can organize items into groups based on user-defined criteria. This helps to make sense of large amounts of data by breaking it down into manageable chunks.

- **Reactive State Management**: 🆕 Full support for modern state management patterns like BLoC, Provider, and Riverpod with dedicated reactive constructors that separate event triggering from data listening.

- **Customizable Loading and Error States**: You can provide custom widgets to be displayed while data is being loaded or if an error occurs. This allows for a seamless, branded experience.

- **Pull-to-Refresh**: The widget incorporates a pull-to-refresh feature, letting users manually trigger a refresh of the list's content.

- **Sticky Group Headers**: Headers stick to the top of the list as the user scrolls, making it easier to understand the context of the data they're viewing. Can be changed.

### Usage

The InfiniteGroupedList offers two usage patterns to fit different architectural approaches:

#### 🔄 Reactive Pattern (Recommended for Modern Apps)

Perfect for apps using BLoC, Provider, Riverpod, or any external state management:

```dart
BlocBuilder<ItemsBloc, ItemsState>(
  builder: (context, state) {
    return InfiniteGroupedList<Item, String, String>.reactive(
      // External state from your state management solution
      items: state.items,
      isLoading: state.isLoading,
      hasReachedMax: state.hasReachedMax,
      error: state.error,
      
      // Event trigger - cleanly separated from data fetching
      onLoadMoreTriggered: () {
        context.read<ItemsBloc>().add(LoadMoreItems());
      },
      
      // Refresh trigger
      onRefresh: () {
        context.read<ItemsBloc>().add(RefreshItems());
      },
      
      // UI builders
      itemBuilder: (item) => ListTile(title: Text(item.name)),
      groupBy: (item) => item.category,
      groupCreator: (category) => category,
      groupTitleBuilder: (title, _, __, ___) => Text(title),
    );
  },
)
```

#### ⚡ Imperative Pattern (Traditional Approach)

For apps that prefer direct data fetching within the widget:

```dart
InfiniteGroupedList(
  onLoadMore: (paginationInfo) async {
    // Fetch data directly and return it
    return await apiService.fetchItems(
      page: paginationInfo.page,
      limit: 20,
    );
  },
  itemBuilder: (item) => ListTile(title: Text(item.name)),
  groupBy: (item) => item.category,
  groupCreator: (category) => category,
  groupTitleBuilder: (title, _, __, ___) => Text(title),
)
```

#### Key Differences

- **Reactive**: Event triggering and data listening are completely separated. Your state management handles data fetching, and the widget displays the current state.
- **Imperative**: The widget directly calls your data fetching function and manages the loading states internally.

#### PaginationInfo Helper

When using the imperative pattern, `PaginationInfo` provides pagination context:
- `offset`: Current item offset for offset-based pagination
- `page`: Current page number for page-based pagination  
- `limit`: Items per page (configurable via controller)

The InfiniteGroupedList widget is a comprehensive solution for any use case that involves displaying large amounts of data in an organized, easy-to-navigate manner.

### Examples

Explore comprehensive examples demonstrating different usage patterns:

- **🆕 [Reactive BLoC Example](https://github.com/esentis/infinite_grouped_list/blob/main/example/lib/reactive_bloc_example.dart)**: Complete implementation using reactive pattern with flutter_bloc, including error handling, loading states, and event-driven architecture.

- **📅 [Group by Date](https://github.com/esentis/infinite_grouped_list/blob/main/example/lib/group_by_date_example.dart)**: Traditional imperative pattern grouping transactions by date with custom group titles.

- **🏷️ [Group by Type](https://github.com/esentis/infinite_grouped_list/blob/main/example/lib/group_by_type_example.dart)**: Demonstrates grouping items by category/type with different visual treatments.

- **🔲 [Grid Layout](https://github.com/esentis/infinite_grouped_list/blob/main/example/lib/group_by_date_grid_example.dart)**: Shows how to use the `.gridView()` constructor for grid-based layouts.

Run the example app to see all patterns in action with an interactive example selection screen.

### Migration Guide

**Existing users**: Your current code continues to work without any changes! The new reactive constructors are purely additive.

**Moving to reactive pattern**: 
1. Replace `InfiniteGroupedList()` with `InfiniteGroupedList.reactive()`
2. Move your `onLoadMore` logic to your state management solution
3. Replace the `onLoadMore` parameter with `onLoadMoreTriggered` callback  
4. Provide external state via `items`, `isLoading`, `hasReachedMax` parameters

The reactive pattern is recommended for new projects using modern state management, while the imperative pattern remains fully supported for simpler use cases.
