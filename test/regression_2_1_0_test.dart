import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_grouped_list/infinite_grouped_list.dart';
import 'package:material_ui/material_ui.dart';

Widget _imperative({
  required InfiniteGroupedListController<int, int, String> controller,
  required Future<List<int>> Function(PaginationInfo) onLoadMore,
  Key? key,
}) {
  return MaterialApp(
    home: InfiniteGroupedList<int, int, String>(
      key: key,
      controller: controller,
      onLoadMore: onLoadMore,
      groupBy: (_) => 0,
      groupCreator: (_) => 'all',
      groupTitleBuilder: (_, _, _, _) => const SizedBox(height: 20),
      itemBuilder: (i) => SizedBox(height: 400, child: Text('item $i')),
    ),
  );
}

Widget _reactive({
  InfiniteGroupedListRefreshCallback? onRefresh,
  bool? showRefreshIndicator,
}) {
  return MaterialApp(
    home: InfiniteGroupedList<int, int, String>.reactive(
      items: const [1, 2, 3],
      isLoading: false,
      hasReachedMax: true,
      onLoadMoreTriggered: () {},
      onRefresh: onRefresh,
      showRefreshIndicator: showRefreshIndicator,
      groupBy: (_) => 0,
      groupCreator: (_) => 'all',
      groupTitleBuilder: (_, _, _, _) => const SizedBox(height: 20),
      itemBuilder: (i) => Text('item $i'),
    ),
  );
}

void main() {
  testWidgets(
    'a shared controller stays attached when the list remounts with a new key',
    (WidgetTester tester) async {
      final controller = InfiniteGroupedListController<int, int, String>(
        limit: 2,
      );
      final calls = <PaginationInfo>[];
      Future<List<int>> onLoadMore(PaginationInfo info) async {
        calls.add(info);
        return [info.offset, info.offset + 1];
      }

      await tester.pumpWidget(
        _imperative(
          key: const ValueKey('a'),
          controller: controller,
          onLoadMore: onLoadMore,
        ),
      );
      await tester.pumpAndSettle();

      // A new key creates a new State; the old one is disposed afterwards and
      // must not detach the controller the new State has already claimed.
      await tester.pumpWidget(
        _imperative(
          key: const ValueKey('b'),
          controller: controller,
          onLoadMore: onLoadMore,
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.getItems(), [0, 1]);

      calls.clear();
      await controller.loadItems();
      await tester.pumpAndSettle();

      expect(calls.single.offset, 2);
      expect(controller.getItems(), [0, 1, 2, 3]);
    },
  );

  testWidgets('retry after a failed refresh reloads the first page', (
    WidgetTester tester,
  ) async {
    final controller = InfiniteGroupedListController<int, int, String>(
      limit: 2,
    );
    final calls = <PaginationInfo>[];
    var fail = false;
    var base = 0;
    Future<List<int>> onLoadMore(PaginationInfo info) async {
      calls.add(info);
      if (fail) throw Exception('offline');
      return [base + info.offset, base + info.offset + 1];
    }

    await tester.pumpWidget(
      _imperative(controller: controller, onLoadMore: onLoadMore),
    );
    await tester.pumpAndSettle();
    expect(controller.getItems(), [0, 1]);

    fail = true;
    await controller.refresh();
    await tester.pumpAndSettle();
    // The stale items stay visible while the refresh error is shown.
    expect(controller.getItems(), [0, 1]);

    fail = false;
    base = 100; // the server data changed meanwhile
    calls.clear();
    await controller.loadItems();
    await tester.pumpAndSettle();

    expect(calls.first.offset, 0);
    expect(calls.first.page, 1);
    expect(controller.getItems(), [100, 101]);

    // Pagination continues from the refreshed first page.
    calls.clear();
    await controller.loadItems();
    await tester.pumpAndSettle();
    expect(calls.single.offset, 2);
    expect(calls.single.page, 2);
    expect(controller.getItems(), [100, 101, 102, 103]);
  });

  group('reactive pull-to-refresh', () {
    testWidgets('is hidden when there is no onRefresh', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_reactive());
      expect(find.byType(RefreshIndicator), findsNothing);
    });

    testWidgets('is shown when onRefresh is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_reactive(onRefresh: () {}));
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('respects an explicit showRefreshIndicator', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_reactive(showRefreshIndicator: true));
      expect(find.byType(RefreshIndicator), findsOneWidget);

      await tester.pumpWidget(
        _reactive(onRefresh: () {}, showRefreshIndicator: false),
      );
      expect(find.byType(RefreshIndicator), findsNothing);
    });
  });
}
