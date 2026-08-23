import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_grouped_list/src/helpers/group_manager.dart';
import 'package:infinite_grouped_list/src/helpers/pagination_info.dart';

class _Item {
  const _Item(this.id, this.group, this.sortValue);

  final String id;
  final String group;
  final int sortValue;

  @override
  bool operator ==(Object other) {
    return other is _Item &&
        other.id == id &&
        other.group == group &&
        other.sortValue == sortValue;
  }

  @override
  int get hashCode => Object.hash(id, group, sortValue);
}

void main() {
  GroupManager<_Item, String, String> buildManager({
    Comparable Function(_Item item)? sortFn,
    SortOrder sortOrder = SortOrder.descending,
  }) {
    return GroupManager<_Item, String, String>(
      groupBy: (item) => item.group,
      groupCreator: (groupBy) => groupBy.toUpperCase(),
      sortFn: sortFn,
      sortOrder: sortOrder,
    );
  }

  test('initialize groups items and applies ascending sort', () {
    final manager = buildManager(
      sortFn: (item) => item.sortValue,
      sortOrder: SortOrder.ascending,
    );

    final groups = manager.initialize(const <_Item>[
      _Item('b', 'alpha', 2),
      _Item('a', 'alpha', 1),
      _Item('c', 'beta', 3),
    ]);

    expect(groups.keys, orderedEquals(<String>['ALPHA', 'BETA']));
    expect(
      groups['ALPHA'],
      orderedEquals(const <_Item>[
        _Item('a', 'alpha', 1),
        _Item('b', 'alpha', 2),
      ]),
    );
    expect(groups['BETA'], orderedEquals(const <_Item>[_Item('c', 'beta', 3)]));
  });

  test('initialize preserves insertion order when no sort function is provided',
      () {
    final manager = buildManager();

    final groups = manager.initialize(const <_Item>[
      _Item('b', 'alpha', 2),
      _Item('a', 'alpha', 1),
    ]);

    expect(
      groups['ALPHA'],
      orderedEquals(const <_Item>[
        _Item('b', 'alpha', 2),
        _Item('a', 'alpha', 1),
      ]),
    );
  });

  test(
      'merge appends to existing groups, creates new ones, and sorts touched groups',
      () {
    final manager = buildManager(
      sortFn: (item) => item.sortValue,
    );
    final groups = manager.initialize(const <_Item>[
      _Item('a', 'alpha', 1),
      _Item('b', 'beta', 2),
    ]);

    manager.merge(groups, const <_Item>[
      _Item('c', 'alpha', 3),
      _Item('d', 'gamma', 4),
    ]);

    expect(
      groups['ALPHA'],
      orderedEquals(const <_Item>[
        _Item('c', 'alpha', 3),
        _Item('a', 'alpha', 1),
      ]),
    );
    expect(groups['BETA'], orderedEquals(const <_Item>[_Item('b', 'beta', 2)]));
    expect(
        groups['GAMMA'], orderedEquals(const <_Item>[_Item('d', 'gamma', 4)]));
  });

  test('sorting is stable for items with equal keys merged across pages', () {
    final manager = buildManager(sortFn: (item) => item.sortValue);
    final groups = <String, List<_Item>>{};

    // Two pages whose items all share the same sort key, like paginated loads.
    manager.merge(groups, [
      for (var i = 0; i < 20; i++) _Item('i$i', 'alpha', 7),
    ]);
    manager.merge(groups, [
      for (var i = 20; i < 60; i++) _Item('i$i', 'alpha', 7),
    ]);

    // Dart's List.sort is unstable for >= 40 equal elements, so without an
    // insertion-order tie-break this exact expectation fails.
    expect(
      groups['ALPHA']!.map((item) => item.id),
      orderedEquals([for (var i = 0; i < 60; i++) 'i$i']),
    );
  });

  test('initialize keeps arrival order for items with equal sort keys', () {
    final manager = buildManager(sortFn: (item) => item.sortValue);

    final groups = manager.initialize([
      for (var i = 0; i < 60; i++) _Item('i$i', 'alpha', 7),
    ]);

    // Dart's List.sort is unstable for >= 40 equal elements, so without an
    // insertion-order tie-break this exact expectation fails.
    expect(
      groups['ALPHA']!.map((item) => item.id),
      orderedEquals([for (var i = 0; i < 60; i++) 'i$i']),
    );
  });

  test('removeWhere removes matching items and drops empty groups', () {
    final manager = buildManager();
    final allItems = <_Item>[
      const _Item('a', 'alpha', 1),
      const _Item('b', 'beta', 2),
      const _Item('c', 'beta', 3),
    ];
    final groups = manager.initialize(allItems);

    manager.removeWhere(
      groups,
      allItems,
      (item) => item.group == 'beta',
    );

    expect(groups.keys, orderedEquals(<String>['ALPHA']));
    expect(allItems, orderedEquals(const <_Item>[_Item('a', 'alpha', 1)]));
  });

  test('removeItem returns false when the item is not present', () {
    final manager = buildManager();
    final allItems = <_Item>[const _Item('a', 'alpha', 1)];
    final groups = manager.initialize(allItems);

    final removed = manager.removeItem(
      groups,
      allItems,
      const _Item('missing', 'alpha', 99),
    );

    expect(removed, isFalse);
    expect(allItems, orderedEquals(const <_Item>[_Item('a', 'alpha', 1)]));
    expect(groups.keys, orderedEquals(<String>['ALPHA']));
  });

  test('removeItem removes the last item from a group and deletes the group',
      () {
    final manager = buildManager();
    final allItems = <_Item>[
      const _Item('a', 'alpha', 1),
      const _Item('b', 'beta', 2),
    ];
    final groups = manager.initialize(allItems);

    final removed = manager.removeItem(
      groups,
      allItems,
      const _Item('b', 'beta', 2),
    );

    expect(removed, isTrue);
    expect(groups.keys, orderedEquals(<String>['ALPHA']));
    expect(allItems, orderedEquals(const <_Item>[_Item('a', 'alpha', 1)]));
  });
}
