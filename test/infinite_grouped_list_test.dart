import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_grouped_list/src/helpers/pagination_info.dart';
import 'package:infinite_grouped_list/src/infinite_grouped_list.dart';

void main() {
  testWidgets('InfiniteGroupedList widget test', (WidgetTester tester) async {
    int index = 0;
    final controller = InfiniteGroupedListController<String, String, String>();
    Future<List<String>> mockOnLoadMore(PaginationInfo paginationInfo) async {
      return List.generate(
        50,
        (i) => 'Item ${index++}',
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: InfiniteGroupedList<String, String, String>(
          onLoadMore: mockOnLoadMore,
          itemBuilder: (item) => Text(item),
          seperatorBuilder: (_) => const Divider(),
          groupTitleBuilder: (_, __, ___, ____) => Container(),
          groupBy: (item) => item,
          groupCreator: (groupBy) => groupBy,
          sortGroupBy: (_) {},
          controller: controller,
        ),
      ),
    );
    controller.loadItems();
    await tester.pumpAndSettle(); // Fetch the next batch of items
    controller.loadItems();

    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Verify that the items are displayed
    for (var i = 1; i <= 110; i++) {
      expect(
        find.text(
          'Item $i',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('InfiniteGroupedList.reactive widget test', (WidgetTester tester) async {
    bool loadMoreTriggered = false;
    final controller = InfiniteGroupedListController<String, String, String>();
    
    // Mock items for reactive mode
    final items = List.generate(10, (i) => 'Reactive Item $i');
    
    await tester.pumpWidget(
      MaterialApp(
        home: InfiniteGroupedList<String, String, String>.reactive(
          items: items,
          isLoading: false,
          hasReachedMax: false,
          onLoadMoreTriggered: () {
            loadMoreTriggered = true;
          },
          itemBuilder: (item) => Text(item),
          groupTitleBuilder: (_, __, ___, ____) => Container(),
          groupBy: (item) => item,
          groupCreator: (groupBy) => groupBy,
          controller: controller,
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // Verify that reactive items are displayed
    expect(find.text('Reactive Item 0'), findsOneWidget);
    expect(find.text('Reactive Item 9'), findsOneWidget);
    
    // Test reactive controller loadItems triggers callback
    controller.loadItems();
    expect(loadMoreTriggered, isTrue);
  });

  testWidgets('InfiniteGroupedList.reactiveGrid widget test', (WidgetTester tester) async {
    bool loadMoreTriggered = false;
    final controller = InfiniteGroupedListController<String, String, String>();
    
    // Mock items for reactive grid mode - use different groups
    final items = List.generate(6, (i) => 'Grid Item $i');
    
    await tester.pumpWidget(
      MaterialApp(
        home: InfiniteGroupedList<String, String, String>.reactiveGrid(
          items: items,
          isLoading: false,
          hasReachedMax: false,
          onLoadMoreTriggered: () {
            loadMoreTriggered = true;
          },
          itemBuilder: (item) => Text(item),
          groupTitleBuilder: (title, __, ___, ____) => Text('Group: $title'),
          groupBy: (item) => item.split(' ')[0], // Group by "Grid"
          groupCreator: (groupBy) => groupBy,
          controller: controller,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // Verify that reactive grid items are displayed
    expect(find.text('Grid Item 0'), findsOneWidget);
    expect(find.text('Grid Item 1'), findsOneWidget);
    
    // Test reactive controller loadItems triggers callback
    controller.loadItems();
    expect(loadMoreTriggered, isTrue);
  });

  testWidgets('Reactive mode controller throws errors for unsupported operations', (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();
    
    await tester.pumpWidget(
      MaterialApp(
        home: InfiniteGroupedList<String, String, String>.reactive(
          items: const ['Item 1'],
          isLoading: false,
          hasReachedMax: false,
          onLoadMoreTriggered: () {},
          itemBuilder: (item) => Text(item),
          groupTitleBuilder: (_, __, ___, ____) => Container(),
          groupBy: (item) => item,
          groupCreator: (groupBy) => groupBy,
          controller: controller,
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // Test that unsupported operations throw errors in reactive mode
    expect(
      () => controller.addItems(['New Item']),
      throwsA(isA<UnsupportedError>()),
    );
    
    expect(
      () => controller.remove('Item 1'),
      throwsA(isA<UnsupportedError>()),
    );
    
    expect(
      () => controller.removeWhere((item) => item == 'Item 1'),
      throwsA(isA<UnsupportedError>()),
    );
  });
}
