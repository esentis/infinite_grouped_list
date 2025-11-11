import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_grouped_list/infinite_grouped_list.dart';

class _Item {
  const _Item(this.id, this.date);
  final int id;
  final DateTime date;
}

void main() {
  testWidgets('anchoring keeps group headers compatible with Flex widgets',
      (tester) async {
    final controller = InfiniteGroupedListController<_Item, DateTime, String>();

    Future<List<_Item>> load(PaginationInfo info) async {
      return List.generate(
        3,
        (index) => _Item(index, DateTime.utc(2024, 1, index + 1)),
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfiniteGroupedList<_Item, DateTime, String>(
            enableAnchoring: true,
            controller: controller,
            onLoadMore: load,
            groupBy: (item) => item.date,
            groupCreator: (_) => 'Group',
            groupTitleBuilder: (title, groupBy, isPinned, scrollPercentage) =>
                Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(color: Colors.blueGrey),
              child: const Row(
                children: [
                  Text('Group Header'),
                  Spacer(),
                  Icon(Icons.pin_drop),
                ],
              ),
            ),
            itemBuilder: (item) => Text('Item ${item.id}'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  });

  testWidgets('anchoring works in reactive mode as well', (tester) async {
    final controller = InfiniteGroupedListController<_Item, DateTime, String>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfiniteGroupedList<_Item, DateTime, String>.reactive(
            enableAnchoring: true,
            controller: controller,
            items: [
              _Item(1, DateTime.utc(2024)),
              _Item(2, DateTime.utc(2024)),
            ],
            isLoading: false,
            hasReachedMax: true,
            onLoadMoreTriggered: () {},
            groupBy: (item) => item.date,
            groupCreator: (_) => 'Group',
            groupTitleBuilder: (title, groupBy, isPinned, scrollPercentage) =>
                Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(color: Colors.blueGrey),
              child: const Row(
                children: [
                  Text('Group Header'),
                  Spacer(),
                  Icon(Icons.pin_drop),
                ],
              ),
            ),
            itemBuilder: (item) => Text('Item ${item.id}'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  });
}
