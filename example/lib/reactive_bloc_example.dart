import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_grouped_list/infinite_grouped_list.dart';

// Models
class Item {
  final int id;
  final String name;
  final String category;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.createdAt,
  });

  @override
  String toString() => 'Item(id: $id, name: $name, category: $category)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// BLoC Events
abstract class ItemsEvent {}

class LoadInitialItems extends ItemsEvent {}

class LoadMoreItems extends ItemsEvent {}

class RefreshItems extends ItemsEvent {}

// BLoC State
class ItemsState {
  final List<Item> items;
  final bool isLoading;
  final bool hasReachedMax;
  final String? error;

  const ItemsState({
    this.items = const [],
    this.isLoading = false,
    this.hasReachedMax = false,
    this.error,
  });

  ItemsState copyWith({
    List<Item>? items,
    bool? isLoading,
    bool? hasReachedMax,
    String? error,
  }) {
    return ItemsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: error ?? this.error,
    );
  }
}

// BLoC Implementation
class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  ItemsBloc() : super(const ItemsState()) {
    on<LoadInitialItems>(_onLoadInitialItems);
    on<LoadMoreItems>(_onLoadMoreItems);
    on<RefreshItems>(_onRefreshItems);
  }

  // Mock data generator
  List<Item> _generateMockItems(int startIndex, int count) {
    final categories = ['Work', 'Personal', 'Shopping', 'Travel'];
    return List.generate(count, (index) {
      final actualIndex = startIndex + index;
      return Item(
        id: actualIndex,
        name: 'Item $actualIndex',
        category: categories[actualIndex % categories.length],
        createdAt: DateTime.now().subtract(Duration(hours: actualIndex)),
      );
    });
  }

  Future<void> _onLoadInitialItems(
    LoadInitialItems event,
    Emitter<ItemsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      final newItems = _generateMockItems(0, 20);
      emit(state.copyWith(
        items: newItems,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load items: $e',
      ));
    }
  }

  Future<void> _onLoadMoreItems(
    LoadMoreItems event,
    Emitter<ItemsState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final startIndex = state.items.length;
      final newItems = _generateMockItems(startIndex, 20);

      // Simulate reaching max after 100 items
      final hasReachedMax = state.items.length + newItems.length >= 100;

      emit(state.copyWith(
        items: [...state.items, ...newItems],
        isLoading: false,
        hasReachedMax: hasReachedMax,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load more items: $e',
      ));
    }
  }

  Future<void> _onRefreshItems(
    RefreshItems event,
    Emitter<ItemsState> emit,
  ) async {
    emit(const ItemsState(isLoading: true));

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1000));

      final newItems = _generateMockItems(0, 20);
      emit(ItemsState(
        items: newItems,
      ));
    } catch (e) {
      emit(ItemsState(
        error: 'Failed to refresh items: $e',
      ));
    }
  }
}

// Example Widget
class ReactiveBlocExample extends StatelessWidget {
  const ReactiveBlocExample({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ItemsBloc()..add(LoadInitialItems()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reactive BLoC Example'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<ItemsBloc, ItemsState>(
          builder: (context, state) {
            // Show error if any
            if (state.error != null && state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ItemsBloc>().add(LoadInitialItems()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return InfiniteGroupedList<Item, String, String>.reactive(
              // Reactive state properties
              items: state.items,
              isLoading: state.isLoading,
              hasReachedMax: state.hasReachedMax,
              error: state.error,

              // Event trigger - decoupled from data fetching
              onLoadMoreTriggered: () {
                context.read<ItemsBloc>().add(LoadMoreItems());
              },

              // Refresh trigger
              onRefresh: () {
                context.read<ItemsBloc>().add(RefreshItems());
              },

              // UI builders
              itemBuilder: (item) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(item.category),
                    child: Text(
                      item.category[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(item.name),
                  subtitle: Text('Category: ${item.category}'),
                  trailing: Text(
                    '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),

              groupBy: (item) => item.category,
              groupCreator: (category) => category,

              groupTitleBuilder: (title, groupBy, isPinned, scrollPercentage) =>
                  Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isPinned ? _getCategoryColor(title) : Colors.grey[100],
                  border: Border(
                    bottom: BorderSide(
                      color: _getCategoryColor(title),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(title),
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (isPinned)
                      const Icon(
                        Icons.push_pin,
                        color: Colors.white,
                        size: 16,
                      ),
                  ],
                ),
              ),

              // Error widget
              errorWidget: (error) => Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error.toString(),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.read<ItemsBloc>().add(LoadMoreItems()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

              // Loading widget
              loadingWidget: const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Loading items...'),
                    ],
                  ),
                ),
              ),

              // Empty state
              noItemsFoundWidget: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No items found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Refresh indicator colors
              refreshIndicatorColor: Colors.blue,
              refreshIndicatorBackgroundColor: Colors.white,
            );
          },
        ),

        // Floating action button to demonstrate manual refresh
        floatingActionButton: BlocBuilder<ItemsBloc, ItemsState>(
          builder: (context, state) {
            return FloatingActionButton(
              onPressed: state.isLoading
                  ? null
                  : () => context.read<ItemsBloc>().add(RefreshItems()),
              backgroundColor: state.isLoading ? Colors.grey : Colors.blue,
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh, color: Colors.white),
            );
          },
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue;
      case 'Personal':
        return Colors.green;
      case 'Shopping':
        return Colors.orange;
      case 'Travel':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work;
      case 'Personal':
        return Icons.person;
      case 'Shopping':
        return Icons.shopping_cart;
      case 'Travel':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }
}
