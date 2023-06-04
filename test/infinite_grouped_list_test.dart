import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_grouped_list/helpers/pagination_info.dart';
import 'package:infinite_grouped_list/infinite_grouped_list.dart';

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
}
