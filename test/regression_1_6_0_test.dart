import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_grouped_list/infinite_grouped_list.dart';

/// Offset-based fake backend over `0..total-1`.
Future<List<int>> Function(PaginationInfo) _pagedSource(
  int total,
  void Function() onCall,
) {
  final source = List<int>.generate(total, (i) => i);
  return (info) async {
    onCall();
    return source.skip(info.offset).take(info.limit).toList();
  };
}

void main() {
  group('pagination continues when content does not fill the viewport', () {
    // The test binding runs as Android, i.e. clamping physics: content shorter
    // than the viewport cannot be scrolled, so no scroll event ever fires.

    testWidgets('imperative mode loads pages until the viewport is filled',
        (WidgetTester tester) async {
      var calls = 0;
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: InfiniteGroupedList<int, int, String>(
            scrollController: scrollController,
            onLoadMore: _pagedSource(200, () => calls++),
            itemBuilder: (i) => SizedBox(height: 10, child: Text('$i')),
            groupBy: (_) => 0,
            groupCreator: (_) => 'all',
            groupTitleBuilder: (_, __, ___, ____) => const SizedBox(height: 20),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Each 20-item page is 200px. Loading stops once the content (20px
      // header + pages) exceeds the 600px viewport plus the 100px threshold.
      expect(calls, 4);
      expect(scrollController.position.maxScrollExtent, greaterThan(100));
    });

    testWidgets('imperative mode stops filling once the data is exhausted',
        (WidgetTester tester) async {
      var calls = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: InfiniteGroupedList<int, int, String>(
            onLoadMore: _pagedSource(30, () => calls++),
            itemBuilder: (i) => SizedBox(height: 10, child: Text('$i')),
            groupBy: (_) => 0,
            groupCreator: (_) => 'all',
            groupTitleBuilder: (_, __, ___, ____) => const SizedBox(height: 20),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      // Page 2 returns 10 < limit items, which marks the list exhausted.
      expect(calls, 2);
      expect(find.text('29'), findsOneWidget);
    });

    testWidgets('imperative mode refills after removals shrink the content',
        (WidgetTester tester) async {
      var calls = 0;
      final controller = InfiniteGroupedListController<int, int, String>();

      await tester.pumpWidget(
        MaterialApp(
          home: InfiniteGroupedList<int, int, String>(
            controller: controller,
            onLoadMore: _pagedSource(200, () => calls++),
            itemBuilder: (i) => SizedBox(height: 10, child: Text('$i')),
            groupBy: (_) => 0,
            groupCreator: (_) => 'all',
            groupTitleBuilder: (_, __, ___, ____) => const SizedBox(height: 20),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final callsBeforeRemoval = calls;

      controller.removeWhere((i) => i < 70);
      await tester.pumpAndSettle();

      expect(calls, greaterThan(callsBeforeRemoval));
    });

    testWidgets('reactive mode requests more items without a scroll',
        (WidgetTester tester) async {
      var triggers = 0;

      Widget build({required bool hasReachedMax}) {
        return MaterialApp(
          home: InfiniteGroupedList<String, String, String>.reactive(
            items: const <String>['A', 'B', 'C'],
            isLoading: false,
            hasReachedMax: hasReachedMax,
            onLoadMoreTriggered: () => triggers++,
            itemBuilder: (item) => SizedBox(height: 48, child: Text(item)),
            groupBy: (_) => 'all',
            groupCreator: (groupBy) => groupBy,
            groupTitleBuilder: (_, __, ___, ____) => const SizedBox(height: 32),
          ),
        );
      }

      await tester.pumpWidget(build(hasReachedMax: false));
      await tester.pumpAndSettle();

      // Requested once; the in-flight guard holds until new state arrives.
      expect(triggers, 1);

      await tester.pumpWidget(build(hasReachedMax: true));
      await tester.pumpAndSettle();

      expect(triggers, 1);
    });
  });

  group('grid items fill their cells', () {
    Widget buildGrid({Widget Function(int item)? separatorBuilder}) {
      return MaterialApp(
        home: Center(
          child: SizedBox(
            width: 300,
            height: 600,
            child: InfiniteGroupedList<int, int, String>.gridView(
              onLoadMore: (_) async => <int>[0, 1, 2],
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (i) => Card(
                key: ValueKey<String>('card$i'),
                margin: EdgeInsets.zero,
                child: Center(child: Text('$i')),
              ),
              separatorBuilder: separatorBuilder,
              groupBy: (_) => 0,
              groupCreator: (_) => 'all',
              groupTitleBuilder: (_, __, ___, ____) =>
                  const SizedBox(height: 20),
            ),
          ),
        ),
      );
    }

    testWidgets('without a separator the item takes the whole cell',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildGrid());
      await tester.pumpAndSettle();

      expect(
        tester.getSize(find.byKey(const ValueKey<String>('card1'))),
        const Size(100, 100),
      );
    });

    testWidgets('with a separator the item takes the space that remains',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        buildGrid(separatorBuilder: (_) => const SizedBox(height: 10)),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('card0'))),
        const Size(100, 90),
      );
      // The last item of a group has no separator.
      expect(
        tester.getSize(find.byKey(const ValueKey<String>('card2'))),
        const Size(100, 100),
      );
    });
  });

  group('re-grouping only happens when needed', () {
    testWidgets(
        'imperative: with a groupingKey, inline closures do not re-group on '
        'parent rebuilds', (WidgetTester tester) async {
      var creatorCalls = 0;

      Widget build(Object groupingKey, String Function(String) groupBy) {
        return MaterialApp(
          home: InfiniteGroupedList<String, String, String>(
            groupingKey: groupingKey,
            onLoadMore: (_) async => <String>['A-1', 'B-1'],
            groupBy: groupBy,
            groupCreator: (groupBy) {
              creatorCalls++;
              return groupBy;
            },
            groupTitleBuilder: (title, _, __, ___) => Text('Header $title'),
            itemBuilder: (item) => Text(item),
          ),
        );
      }

      await tester.pumpWidget(build('all', (_) => 'all'));
      await tester.pumpAndSettle();
      expect(find.text('Header all'), findsOneWidget);

      creatorCalls = 0;
      // Parent rebuild: new closure instances, same grouping key.
      await tester.pumpWidget(build('all', (_) => 'all'));
      await tester.pumpAndSettle();
      expect(creatorCalls, 0);

      // Changing the key re-groups with the new callbacks.
      await tester.pumpWidget(
        build('prefix', (item) => item.split('-').first),
      );
      await tester.pumpAndSettle();
      expect(find.text('Header all'), findsNothing);
      expect(find.text('Header A'), findsOneWidget);
      expect(find.text('Header B'), findsOneWidget);
    });

    testWidgets('changing groupSortOrder re-groups even with a groupingKey',
        (WidgetTester tester) async {
      Widget build(SortOrder order) {
        return MaterialApp(
          home: InfiniteGroupedList<int, int, String>(
            groupingKey: 'same',
            groupSortOrder: order,
            sortGroupBy: (i) => i,
            onLoadMore: (_) async => <int>[1, 2],
            groupBy: (_) => 0,
            groupCreator: (_) => 'all',
            groupTitleBuilder: (_, __, ___, ____) => const SizedBox(height: 20),
            itemBuilder: (i) => SizedBox(height: 40, child: Text('$i')),
          ),
        );
      }

      await tester.pumpWidget(build(SortOrder.ascending));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('1')).dy,
        lessThan(tester.getTopLeft(find.text('2')).dy),
      );

      await tester.pumpWidget(build(SortOrder.descending));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('2')).dy,
        lessThan(tester.getTopLeft(find.text('1')).dy),
      );
    });

    group('reactive', () {
      late int creatorCalls;

      // Stable references, so only the data changes between pumps.
      String groupBy(String item) => item.split('-').first;
      String sortBy(String item) => item;
      String groupCreator(String groupBy) {
        creatorCalls++;
        return groupBy;
      }

      Widget build(List<String> items, {bool isLoading = false}) {
        return MaterialApp(
          home: InfiniteGroupedList<String, String, String>.reactive(
            items: items,
            isLoading: isLoading,
            hasReachedMax: true,
            onLoadMoreTriggered: () {},
            groupBy: groupBy,
            groupCreator: groupCreator,
            sortGroupBy: sortBy,
            groupSortOrder: SortOrder.ascending,
            groupTitleBuilder: (title, _, __, ___) => Text('Header $title'),
            itemBuilder: (item) => SizedBox(height: 30, child: Text(item)),
          ),
        );
      }

      setUp(() => creatorCalls = 0);

      testWidgets('a loading-only change does not re-group',
          (WidgetTester tester) async {
        final items = List<String>.generate(100, (i) => 'A-$i');
        await tester.pumpWidget(build(items));
        await tester.pumpAndSettle();

        creatorCalls = 0;
        await tester.pumpWidget(build(items, isLoading: true));
        await tester.pump();

        expect(creatorCalls, 0);
      });

      testWidgets('an appended page only groups the new items',
          (WidgetTester tester) async {
        final items = List<String>.generate(100, (i) => 'A-$i');
        await tester.pumpWidget(build(items));
        await tester.pumpAndSettle();

        creatorCalls = 0;
        await tester.pumpWidget(build(<String>[...items, 'B-0', 'B-1', 'C-0']));
        await tester.pumpAndSettle();

        expect(creatorCalls, 3);
      });

      testWidgets('a non-append change falls back to a full re-group',
          (WidgetTester tester) async {
        final items = List<String>.generate(100, (i) => 'A-$i');
        await tester.pumpWidget(build(items));
        await tester.pumpAndSettle();

        creatorCalls = 0;
        await tester.pumpWidget(build(<String>['B-0', ...items.skip(1)]));
        await tester.pumpAndSettle();

        expect(creatorCalls, 100);
        expect(find.text('Header B'), findsOneWidget);
      });

      testWidgets('appended groups keep first-encounter order and sorting',
          (WidgetTester tester) async {
        await tester.pumpWidget(build(<String>['B-2', 'A-1']));
        await tester.pumpAndSettle();

        await tester.pumpWidget(build(<String>['B-2', 'A-1', 'B-1', 'C-1']));
        await tester.pumpAndSettle();

        double top(String text) => tester.getTopLeft(find.text(text)).dy;
        expect(top('Header B'), lessThan(top('B-1')));
        expect(top('B-1'), lessThan(top('B-2')));
        expect(top('B-2'), lessThan(top('Header A')));
        expect(top('A-1'), lessThan(top('Header C')));
      });

      testWidgets('an external list mutated in place is still picked up',
          (WidgetTester tester) async {
        final items = <String>['A-1'];
        await tester.pumpWidget(build(items, isLoading: true));
        await tester.pump();

        // Same list instance, grown in place (ChangeNotifier-style state).
        items.add('A-2');
        await tester.pumpWidget(build(items));
        await tester.pumpAndSettle();

        expect(find.text('A-2'), findsOneWidget);
      });
    });
  });

  testWidgets('reactive controller.loadItems() retries while an error is set',
      (WidgetTester tester) async {
    var triggers = 0;
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      MaterialApp(
        home: InfiniteGroupedList<String, String, String>.reactive(
          controller: controller,
          items: List<String>.generate(30, (i) => 'Item $i'),
          isLoading: false,
          hasReachedMax: false,
          error: Exception('network'),
          onLoadMoreTriggered: () => triggers++,
          itemBuilder: (item) => SizedBox(height: 48, child: Text(item)),
          groupBy: (_) => 'all',
          groupCreator: (groupBy) => groupBy,
          groupTitleBuilder: (_, __, ___, ____) => const SizedBox(height: 32),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scrolling to the end does not auto-retry while the error is shown...
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -5000));
    await tester.pumpAndSettle();
    expect(triggers, 0);

    // ...but an explicit retry does, once, until new state arrives.
    await controller.loadItems();
    await controller.loadItems();
    expect(triggers, 1);
  });

  testWidgets('jumpToGroup works when group headers are hidden',
      (WidgetTester tester) async {
    final controller = InfiniteGroupedListController<String, String, String>();

    await tester.pumpWidget(
      MaterialApp(
        home: InfiniteGroupedList<String, String, String>(
          controller: controller,
          enableAnchoring: true,
          showGroups: false,
          onLoadMore: (info) async => info.page > 1
              ? <String>[]
              : <String>[
                  for (final group in <String>['A', 'B', 'C', 'D', 'E'])
                    for (var i = 0; i < 6; i++) '$group-$i',
                ],
          groupBy: (item) => item.split('-').first,
          groupCreator: (groupBy) => groupBy,
          groupTitleBuilder: (title, _, __, ___) => Text('Header $title'),
          itemBuilder: (item) => SizedBox(height: 48, child: Text(item)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Pump while the jump is pending so a missing header context resolves
    // to `false` instead of waiting on an unpumped frame forever.
    final jump = controller.jumpToGroup(title: 'C', animate: false);
    await tester.pumpAndSettle();

    expect(await jump, isTrue);
    expect(tester.getTopLeft(find.text('C-0')).dy, 0);
  });
}
