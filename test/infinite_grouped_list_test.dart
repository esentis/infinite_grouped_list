import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_grouped_list/src/helpers/pagination_info.dart';
import 'package:infinite_grouped_list/src/infinite_grouped_list.dart';

class _TrackingScrollController extends ScrollController {
  bool disposed = false;

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

Widget _buildImperativeList({
  required InfiniteGroupedListController<String, String, String> controller,
  required Future<List<String>> Function(PaginationInfo paginationInfo)
      onLoadMore,
  ScrollController? scrollController,
  VoidCallback? onNoMoreItemsFound,
  bool enableAnchoring = false,
  bool showRefreshIndicator = true,
  bool showGroups = true,
  bool stickyGroups = true,
  bool isPaged = true,
  Widget Function(dynamic error)? loadMoreItemsErrorWidget,
  Widget Function(dynamic error)? initialItemsErrorWidget,
  Widget? noItemsFoundWidget,
  String Function(String item)? groupBy,
  String Function(String groupBy)? groupCreator,
  Widget Function(
          String title, String groupBy, bool isPinned, double scrollPercentage)?
      groupTitleBuilder,
  InfiniteGroupedListRefreshCallback? onRefresh,
  Widget? loadingWidget,
}) {
  return MaterialApp(
    home: SizedBox(
      height: 320,
      child: InfiniteGroupedList<String, String, String>(
        controller: controller,
        enableAnchoring: enableAnchoring,
        showRefreshIndicator: showRefreshIndicator,
        showGroups: showGroups,
        stickyGroups: stickyGroups,
        isPaged: isPaged,
        onLoadMore: onLoadMore,
        onNoMoreItemsFound: onNoMoreItemsFound,
        scrollController: scrollController,
        onRefresh: onRefresh,
        noItemsFoundWidget: noItemsFoundWidget,
        initialItemsErrorWidget: initialItemsErrorWidget,
        groupBy: groupBy ?? (_) => 'group',
        groupCreator: groupCreator ?? (groupBy) => groupBy,
        groupTitleBuilder: groupTitleBuilder ??
            (_, __, ___, ____) => Container(
                  height: 32,
                  color: Colors.grey.shade200,
                ),
        loadingWidget: loadingWidget ??
            const Center(
              child: CircularProgressIndicator(),
            ),
        itemBuilder: (item) => SizedBox(
          height: 48,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(item),
          ),
        ),
        separatorBuilder: (_) => const Divider(height: 1),
        loadMoreItemsErrorWidget: loadMoreItemsErrorWidget,
      ),
    ),
  );
}

Widget _buildImperativeGrid({
  required InfiniteGroupedListController<String, String, String> controller,
  required Future<List<String>> Function(PaginationInfo paginationInfo)
      onLoadMore,
}) {
  return MaterialApp(
    home: SizedBox(
      height: 320,
      child: InfiniteGroupedList<String, String, String>.gridView(
        controller: controller,
        onLoadMore: onLoadMore,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2,
        ),
        groupBy: (_) => 'grid',
        groupCreator: (groupBy) => groupBy,
        groupTitleBuilder: (_, __, ___, ____) => Container(
          height: 32,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (item) => Text(item),
      ),
    ),
  );
}

Widget _buildReactiveList({
  required InfiniteGroupedListController<String, String, String> controller,
  required List<String> items,
  required bool isLoading,
  required bool hasReachedMax,
  required VoidCallback onLoadMoreTriggered,
}) {
  return MaterialApp(
    home: SizedBox(
      height: 320,
      child: InfiniteGroupedList<String, String, String>.reactive(
        controller: controller,
        items: items,
        isLoading: isLoading,
        hasReachedMax: hasReachedMax,
        onLoadMoreTriggered: onLoadMoreTriggered,
        groupBy: (_) => 'group',
        groupCreator: (groupBy) => groupBy,
        groupTitleBuilder: (_, __, ___, ____) => Container(
          height: 32,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (item) => SizedBox(
          height: 48,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(item),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('list items receive full cross-axis constraints',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();
    const itemKey = Key('item');

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 360,
            height: 320,
            child: InfiniteGroupedList<String, String, String>(
              controller: controller,
              showGroups: false,
              showRefreshIndicator: false,
              onLoadMore: (_) async => <String>['Item 1'],
              groupBy: (_) => 'group',
              groupCreator: (groupBy) => groupBy,
              groupTitleBuilder: (_, __, ___, ____) => const SizedBox.shrink(),
              itemBuilder: (_) => const SizedBox(
                key: itemKey,
                width: 120,
                height: 48,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byKey(itemKey)).width, 360);
  });

  test('controller jumpToGroup validates its arguments', () {
    final controller = InfiniteGroupedListController<String, String, String>();

    expect(
      () => controller.jumpToGroup(),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => controller.jumpToGroup(
        title: 'A',
        predicate: (title, groupBy) => true,
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => controller.jumpToGroup(
        title: 'A',
        maxRetries: -1,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('detached controller jumpToGroup resolves to false', () async {
    final controller = InfiniteGroupedListController<String, String, String>();

    final found = await controller.jumpToGroup(title: 'Missing');

    expect(found, isFalse);
  });

  testWidgets('imperative widget loads initial and next pages',
      (WidgetTester tester) async {
    var index = 0;
    final controller = InfiniteGroupedListController<String, String, String>();

    Future<List<String>> onLoadMore(PaginationInfo paginationInfo) async {
      return List<String>.generate(
        20,
        (_) => 'Item ${index++}',
      );
    }

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: onLoadMore,
      ),
    );
    await tester.pumpAndSettle();

    await controller.loadItems();
    await tester.pumpAndSettle();

    expect(controller.getItems(), hasLength(40));
    expect(find.text('Item 0'), findsOneWidget);
    expect(controller.getItems().last, 'Item 39');
  });

  testWidgets('imperative gridView builds items', (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      _buildImperativeGrid(
        controller: controller,
        onLoadMore: (_) async => <String>['Grid 1', 'Grid 2', 'Grid 3'],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Grid 1'), findsOneWidget);
    expect(find.text('Grid 3'), findsOneWidget);
  });

  testWidgets('loadItems awaits imperative pagination completion',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();
    final secondPageCompleter = Completer<List<String>>();
    var calls = 0;

    Future<List<String>> onLoadMore(PaginationInfo paginationInfo) {
      calls++;
      if (calls == 1) {
        return Future<List<String>>.value(
          List<String>.generate(20, (index) => 'Item $index'),
        );
      }
      return secondPageCompleter.future;
    }

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: onLoadMore,
      ),
    );
    await tester.pumpAndSettle();

    final loadFuture = controller.loadItems();
    await tester.pump();

    expect(controller.getItems(), hasLength(20));

    secondPageCompleter.complete(<String>['Item 20']);
    await loadFuture;
    await tester.pumpAndSettle();

    expect(controller.getItems(), hasLength(21));
    expect(controller.getItems().last, 'Item 20');
  });

  testWidgets('addItems respects the provided insertion index',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 320,
          child: InfiniteGroupedList<String, String, String>(
            controller: controller,
            onLoadMore: (_) async => <String>['A', 'C'],
            groupBy: (_) => 'group',
            groupCreator: (groupBy) => groupBy,
            groupTitleBuilder: (title, _, __, ___) => Text(title),
            itemBuilder: (item) => Text(item),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    controller.addItems(<String>['B'], index: 1);
    await tester.pump();

    expect(controller.getItems(), orderedEquals(<String>['A', 'B', 'C']));
  });

  testWidgets('controller remove and removeWhere update imperative items',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: (_) async => <String>['A', 'B', 'C'],
      ),
    );
    await tester.pumpAndSettle();

    controller.remove('B');
    await tester.pump();
    expect(controller.getItems(), orderedEquals(<String>['A', 'C']));

    controller.removeWhere((item) => item != 'C');
    await tester.pump();
    expect(controller.getItems(), orderedEquals(<String>['C']));
  });

  testWidgets(
      'reactive scrolling triggers load more once until external state updates',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();
    var triggerCount = 0;
    var isLoading = false;
    var items = List<String>.generate(30, (index) => 'Reactive Item $index');

    Future<void> pumpReactiveList() async {
      await tester.pumpWidget(
        _buildReactiveList(
          controller: controller,
          items: items,
          isLoading: isLoading,
          hasReachedMax: false,
          onLoadMoreTriggered: () {
            triggerCount++;
          },
        ),
      );
      await tester.pump();
    }

    await pumpReactiveList();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
    await tester.pump();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();

    expect(triggerCount, 1);

    isLoading = true;
    await pumpReactiveList();

    isLoading = false;
    items = <String>[
      ...items,
      'Reactive Item 30',
      'Reactive Item 31',
    ];
    await pumpReactiveList();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pump();

    expect(triggerCount, 2);
  });

  testWidgets('imperative refresh awaits the optional onRefresh callback',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();
    final refreshCompleter = Completer<void>();
    var loadCalls = 0;

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: (_) async {
          loadCalls++;
          return <String>['Item $loadCalls'];
        },
        onRefresh: () => refreshCompleter.future,
      ),
    );
    await tester.pumpAndSettle();

    final refreshFuture = controller.refresh();
    await tester.pump();

    expect(loadCalls, 1);

    refreshCompleter.complete();
    await refreshFuture;
    await tester.pumpAndSettle();

    expect(loadCalls, 2);
    expect(controller.getItems(), orderedEquals(<String>['Item 2']));
  });

  testWidgets('refresh reloads even when a load-more is already in flight',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();
    final secondPageCompleter = Completer<List<String>>();
    final loadedOffsets = <int>[];

    Future<List<String>> onLoadMore(PaginationInfo paginationInfo) {
      loadedOffsets.add(paginationInfo.offset);
      if (loadedOffsets.length == 1) {
        return Future<List<String>>.value(
          List<String>.generate(20, (index) => 'A$index'),
        );
      }
      if (loadedOffsets.length == 2) {
        // Scroll-triggered load-more that stays pending while refresh fires.
        return secondPageCompleter.future;
      }
      // The reload triggered by refresh().
      return Future<List<String>>.value(<String>['Refreshed']);
    }

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: onLoadMore,
      ),
    );
    await tester.pumpAndSettle();
    expect(loadedOffsets, orderedEquals(<int>[0]));

    // Kick off a load-more that will not complete yet.
    final loadFuture = controller.loadItems();
    await tester.pump();
    expect(loadedOffsets, hasLength(2));

    // Refresh while the load-more is still in flight.
    final refreshFuture = controller.refresh();
    await tester.pump();

    // Let the in-flight load-more settle; refresh must still perform its reload.
    secondPageCompleter
        .complete(List<String>.generate(20, (index) => 'B$index'));
    await loadFuture;
    await refreshFuture;
    await tester.pumpAndSettle();

    expect(loadedOffsets, hasLength(3));
    expect(loadedOffsets.last, 0);
    expect(controller.getItems(), orderedEquals(<String>['Refreshed']));
  });

  testWidgets(
      'separator renders between items but not after the last item of a group',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 800,
          child: InfiniteGroupedList<String, String, String>(
            controller: controller,
            showRefreshIndicator: false,
            onLoadMore: (_) async => <String>['G1-a', 'G1-b', 'G1-c', 'G2-a'],
            groupBy: (item) => item.split('-').first,
            groupCreator: (groupBy) => groupBy,
            groupTitleBuilder: (title, _, __, ___) => SizedBox(
              height: 24,
              child: Text('H:$title'),
            ),
            separatorBuilder: (_) => const Divider(height: 1),
            itemBuilder: (item) => SizedBox(height: 40, child: Text(item)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // All items are laid out inside the tall viewport.
    expect(find.text('G1-a'), findsOneWidget);
    expect(find.text('G1-c'), findsOneWidget);
    expect(find.text('G2-a'), findsOneWidget);

    // Group G1 (3 items) has 2 separators, group G2 (1 item) has none, so a
    // trailing separator after the last item of each group would over-count.
    expect(find.byType(Divider), findsNWidgets(2));
  });

  testWidgets('controller replacement detaches old controller callbacks',
      (WidgetTester tester) async {
    final oldController =
        InfiniteGroupedListController<String, String, String>();
    final newController =
        InfiniteGroupedListController<String, String, String>();
    final oldScrollController = _TrackingScrollController();
    final newScrollController = _TrackingScrollController();
    var loadCalls = 0;

    Future<List<String>> onLoadMore(PaginationInfo paginationInfo) async {
      loadCalls++;
      return <String>['Item $loadCalls'];
    }

    await tester.pumpWidget(
      _buildImperativeList(
        controller: oldController,
        scrollController: oldScrollController,
        onLoadMore: onLoadMore,
      ),
    );
    await tester.pumpAndSettle();

    expect(oldController.getItems(), orderedEquals(<String>['Item 1']));

    await tester.pumpWidget(
      _buildImperativeList(
        controller: newController,
        scrollController: newScrollController,
        onLoadMore: onLoadMore,
      ),
    );
    await tester.pumpAndSettle();

    expect(newController.getItems(), orderedEquals(<String>['Item 1']));
    expect(oldController.getItems(), isEmpty);

    await oldController.loadItems();
    await tester.pumpAndSettle();

    expect(loadCalls, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(oldScrollController.disposed, isFalse);
    expect(newScrollController.disposed, isFalse);
  });

  testWidgets('shows a custom empty state without a refresh indicator',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: (_) async => <String>[],
        showRefreshIndicator: false,
        noItemsFoundWidget: const Text('Nothing here'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing here'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsNothing);
  });

  testWidgets('shows a custom initial error widget when the first page fails',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: (_) async => throw Exception('boom'),
        initialItemsErrorWidget: (error) => Text('Initial error: $error'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Initial error:'), findsOneWidget);
  });

  testWidgets('failed refresh keeps rendered and controller items consistent',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();
    var calls = 0;

    Future<List<String>> onLoadMore(PaginationInfo paginationInfo) async {
      calls++;
      if (calls == 1) {
        return <String>['Item 1'];
      }
      throw Exception('refresh failed');
    }

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: onLoadMore,
      ),
    );
    await tester.pumpAndSettle();

    await controller.refresh();
    await tester.pumpAndSettle();

    expect(controller.getItems(), orderedEquals(<String>['Item 1']));
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Oops something went wrong !'), findsOneWidget);
  });

  testWidgets('short first page marks the list as exhausted once',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();
    var noMoreCalls = 0;
    var loadCalls = 0;

    Future<List<String>> onLoadMore(PaginationInfo paginationInfo) async {
      loadCalls++;
      return <String>['Only Item'];
    }

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: onLoadMore,
        onNoMoreItemsFound: () {
          noMoreCalls++;
        },
      ),
    );
    await tester.pumpAndSettle();

    await controller.loadItems();
    await tester.pumpAndSettle();

    expect(loadCalls, 1);
    expect(noMoreCalls, 1);
  });

  testWidgets('shows a custom load more error widget after incremental failure',
      (WidgetTester tester) async {
    final controller =
        InfiniteGroupedListController<String, String, String>(limit: 1);
    var calls = 0;

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: (_) async {
          calls++;
          if (calls == 1) {
            return <String>['Only item'];
          }
          throw Exception('load more failed');
        },
        loadMoreItemsErrorWidget: (error) => Text('Load more error: $error'),
      ),
    );
    await tester.pumpAndSettle();

    await controller.loadItems();
    await tester.pumpAndSettle();

    expect(find.textContaining('Load more error:'), findsOneWidget);
  });

  testWidgets(
      'jumpToGroup returns false and exposes the error when loading additional pages fails',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();
    var calls = 0;

    Future<List<String>> onLoadMore(PaginationInfo paginationInfo) async {
      calls++;
      if (calls == 1) {
        return <String>['Group A'];
      }
      throw Exception('network');
    }

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        enableAnchoring: true,
        onLoadMore: onLoadMore,
        groupBy: (item) => item,
        groupCreator: (groupBy) => groupBy,
        groupTitleBuilder: (title, _, __, ___) => Container(
          height: 32,
          color: Colors.grey.shade200,
          child: Text(title),
        ),
        loadMoreItemsErrorWidget: (error) => const Text('Load more error'),
      ),
    );
    await tester.pumpAndSettle();

    final found = await controller.jumpToGroup(
      predicate: (title, groupBy) => title == 'Missing Group',
      loadUntilFound: true,
    );
    await tester.pumpAndSettle();

    expect(found, isFalse);
  });

  testWidgets(
      'jumpToGroup uses 3 retries by default when loadUntilFound is true',
      (WidgetTester tester) async {
    final controller =
        InfiniteGroupedListController<String, String, String>(limit: 1);
    var calls = 0;

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        enableAnchoring: true,
        onLoadMore: (_) async {
          calls++;
          return <String>['Group $calls'];
        },
        groupBy: (item) => item,
        groupCreator: (groupBy) => groupBy,
        groupTitleBuilder: (title, _, __, ___) => Container(
          height: 32,
          color: Colors.grey.shade200,
          child: Text(title),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final found = await controller.jumpToGroup(
      predicate: (title, groupBy) => title == 'Missing Group',
      loadUntilFound: true,
    );
    await tester.pumpAndSettle();

    expect(found, isFalse);
    expect(calls, 4);
  });

  testWidgets('jumpToGroup respects a custom maxRetries value',
      (WidgetTester tester) async {
    final controller =
        InfiniteGroupedListController<String, String, String>(limit: 1);
    var calls = 0;

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        enableAnchoring: true,
        onLoadMore: (_) async {
          calls++;
          return <String>['Group $calls'];
        },
        groupBy: (item) => item,
        groupCreator: (groupBy) => groupBy,
        groupTitleBuilder: (title, _, __, ___) => Container(
          height: 32,
          color: Colors.grey.shade200,
          child: Text(title),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final found = await controller.jumpToGroup(
      predicate: (title, groupBy) => title == 'Missing Group',
      loadUntilFound: true,
      maxRetries: 1,
    );
    await tester.pumpAndSettle();

    expect(found, isFalse);
    expect(calls, 2);
  });

  testWidgets('jumpToGroup succeeds by title when anchoring is enabled',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        enableAnchoring: true,
        onLoadMore: (_) async => <String>['A', 'B'],
        groupBy: (item) => item,
        groupCreator: (groupBy) => groupBy,
        groupTitleBuilder: (title, _, __, ___) => Container(
          height: 32,
          color: Colors.grey.shade200,
          child: Text('Header $title'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final found = await controller.jumpToGroup(
      title: 'B',
      animate: false,
    );

    expect(found, isTrue);
  });

  testWidgets('jumpToGroup throws when anchoring is disabled',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: (_) async => <String>['A'],
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      controller.jumpToGroup(title: 'A'),
      throwsA(isA<StateError>()),
    );
  });

  testWidgets(
      'reactive jumpToGroup with loadUntilFound throws unsupported error',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 320,
          child: InfiniteGroupedList<String, String, String>.reactive(
            controller: controller,
            enableAnchoring: true,
            items: const <String>['A'],
            isLoading: false,
            hasReachedMax: false,
            onLoadMoreTriggered: () {},
            groupBy: (item) => item,
            groupCreator: (groupBy) => groupBy,
            groupTitleBuilder: (title, _, __, ___) => Container(
              height: 32,
              color: Colors.grey.shade200,
              child: Text(title),
            ),
            itemBuilder: (item) => Text(item),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      controller.jumpToGroup(
        predicate: (title, groupBy) => false,
        loadUntilFound: true,
      ),
      throwsA(isA<UnsupportedError>()),
    );
  });

  testWidgets('showGroups false hides group headers',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: (_) async => <String>['Item 1'],
        showGroups: false,
        groupBy: (item) => item,
        groupCreator: (groupBy) => groupBy,
        groupTitleBuilder: (title, _, __, ___) => Text('Header $title'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Header Item 1'), findsNothing);
    expect(find.text('Item 1'), findsOneWidget);
  });

  testWidgets('custom loading widget is shown while the first page is pending',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();
    final completer = Completer<List<String>>();

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        onLoadMore: (_) => completer.future,
        loadingWidget: const Text('Loading now'),
      ),
    );
    await tester.pump();

    expect(find.text('Loading now'), findsOneWidget);

    completer.complete(<String>['Loaded']);
    await tester.pumpAndSettle();

    expect(find.text('Loaded'), findsOneWidget);
  });

  testWidgets('didUpdateWidget re-groups existing items when grouping changes',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    Widget buildWidget(String Function(String item) groupBy) {
      return MaterialApp(
        home: SizedBox(
          height: 320,
          child: InfiniteGroupedList<String, String, String>(
            controller: controller,
            onLoadMore: (_) async => <String>['A-1', 'B-1'],
            groupBy: groupBy,
            groupCreator: (groupBy) => groupBy,
            groupTitleBuilder: (title, _, __, ___) => Text('Header $title'),
            itemBuilder: (item) => Text(item),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildWidget((_) => 'all'));
    await tester.pumpAndSettle();

    expect(find.text('Header all'), findsOneWidget);

    await tester.pumpWidget(buildWidget((item) => item.split('-').first));
    await tester.pumpAndSettle();

    expect(find.text('Header all'), findsNothing);
    expect(find.text('Header A'), findsOneWidget);
    expect(find.text('Header B'), findsOneWidget);
  });

  testWidgets('isPaged false prevents scroll-based pagination',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();
    var calls = 0;

    await tester.pumpWidget(
      _buildImperativeList(
        controller: controller,
        isPaged: false,
        onLoadMore: (_) async {
          calls++;
          return List<String>.generate(20, (index) => 'Item $index');
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1200));
    await tester.pumpAndSettle();

    expect(calls, 1);
  });

  testWidgets('InfiniteGroupedList.reactiveGrid widget test',
      (WidgetTester tester) async {
    var loadMoreTriggered = false;
    final controller = InfiniteGroupedListController<String, String, String>();
    final items = List<String>.generate(6, (i) => 'Grid Item $i');

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          height: 320,
          child: InfiniteGroupedList<String, String, String>.reactiveGrid(
            items: items,
            isLoading: false,
            hasReachedMax: false,
            onLoadMoreTriggered: () {
              loadMoreTriggered = true;
            },
            itemBuilder: (item) => Text(item),
            groupTitleBuilder: (title, __, ___, ____) => Text('Group: $title'),
            groupBy: (item) => item.split(' ')[0],
            groupCreator: (groupBy) => groupBy,
            controller: controller,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Grid Item 0'), findsOneWidget);
    expect(find.text('Grid Item 1'), findsOneWidget);

    await controller.loadItems();
    expect(loadMoreTriggered, isTrue);
  });

  testWidgets(
      'reactive mode controller throws errors for unsupported operations',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      _buildReactiveList(
        controller: controller,
        items: const <String>['Item 1'],
        isLoading: false,
        hasReachedMax: false,
        onLoadMoreTriggered: () {},
      ),
    );
    await tester.pumpAndSettle();

    expect(
      () => controller.addItems(<String>['New Item']),
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
