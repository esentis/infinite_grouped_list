import 'package:infinite_grouped_list/src/helpers/pagination_info.dart';

/// A helper class that centralizes grouping, merging, sorting, and removal logic
/// for the InfiniteGroupedList.
///
/// [ItemType] is the type of your item. [GroupBy] is the value you group by.
/// [GroupTitle] is the value you display as the group header.
class GroupManager<ItemType, GroupBy, GroupTitle> {
  /// Function to extract the grouping key from an item.
  GroupBy Function(ItemType item) groupBy;

  /// Function to create the displayed group title from the grouping key.
  GroupTitle Function(GroupBy groupBy) groupCreator;

  /// Optional sort function; must return a Comparable.
  Comparable Function(ItemType item)? sortFn;

  /// Order in which to sort groups.
  SortOrder sortOrder;

  GroupManager({
    required this.groupBy,
    required this.groupCreator,
    this.sortFn,
    this.sortOrder = SortOrder.descending,
  });

  int _nextSequence = 0;
  final Map<ItemType, int> _insertionSequences = <ItemType, int>{};

  /// Returns when [item] was first seen by this manager.
  ///
  /// Dart's `List.sort` is not stable, so items whose sort keys compare equal
  /// would otherwise be reordered every time their group is re-sorted as new
  /// pages are merged in. The sequence number breaks those ties by arrival
  /// order, keeping the relative order of equal-keyed items deterministic.
  int _sequenceOf(ItemType item) =>
      _insertionSequences.putIfAbsent(item, () => _nextSequence++);

  /// Creates initial groups from a full list of items.
  Map<GroupTitle, List<ItemType>> initialize(List<ItemType> items) {
    final groups = <GroupTitle, List<ItemType>>{};
    final seen = <ItemType>{};
    for (final item in items) {
      final key = groupCreator(groupBy(item));
      groups.putIfAbsent(key, () => []).add(item);
      // Assign sequences eagerly, in list order, so the tie-break reflects
      // arrival order rather than the comparator's invocation order.
      _sequenceOf(item);
      seen.add(item);
    }
    if (sortFn != null) _sortAll(groups);
    // Drop sequence entries for items that are no longer part of the dataset
    // so bookkeeping does not grow unbounded across refreshes.
    _insertionSequences.removeWhere((item, _) => !seen.contains(item));
    return groups;
  }

  /// Merges [newItems] into [existingGroups], creating new groups as needed.
  /// Only sorts the groups that have new additions.
  void merge(
    Map<GroupTitle, List<ItemType>> existingGroups,
    List<ItemType> newItems,
  ) {
    final touchedGroups = <GroupTitle>{};
    for (final item in newItems) {
      final key = groupCreator(groupBy(item));
      if (existingGroups.containsKey(key)) {
        existingGroups[key]!.add(item);
      } else {
        existingGroups[key] = [item];
      }
      // Eager, arrival-ordered sequence assignment (see _sequenceOf).
      _sequenceOf(item);
      touchedGroups.add(key);
    }
    if (sortFn != null) {
      for (final key in touchedGroups) {
        _sortList(existingGroups[key]!);
      }
    }
  }

  /// Removes items matching [predicate] from both [groups] and [allItems].
  void removeWhere(
    Map<GroupTitle, List<ItemType>> groups,
    List<ItemType> allItems,
    bool Function(ItemType) predicate,
  ) {
    final empty = <GroupTitle>[];
    for (final entry in groups.entries) {
      entry.value.removeWhere(predicate);
      if (entry.value.isEmpty) empty.add(entry.key);
    }
    for (final key in empty) {
      groups.remove(key);
    }
    allItems.removeWhere(predicate);
    _insertionSequences.removeWhere((item, _) => predicate(item));
  }

  /// Removes the first matching [item] from [groups] and [allItems].
  ///
  /// Returns true when an item was removed.
  bool removeItem(
    Map<GroupTitle, List<ItemType>> groups,
    List<ItemType> allItems,
    ItemType item,
  ) {
    GroupTitle? emptyGroup;
    var removed = false;

    for (final entry in groups.entries) {
      final index = entry.value.indexOf(item);
      if (index == -1) {
        continue;
      }

      entry.value.removeAt(index);
      removed = true;

      if (entry.value.isEmpty) {
        emptyGroup = entry.key;
      }
      break;
    }

    if (!removed) {
      return false;
    }

    allItems.remove(item);
    _insertionSequences.remove(item);
    if (emptyGroup != null) {
      groups.remove(emptyGroup);
    }
    return true;
  }

  void _sortAll(Map<GroupTitle, List<ItemType>> groups) {
    for (final entry in groups.entries) {
      _sortList(entry.value);
    }
  }

  void _sortList(List<ItemType> list) {
    list.sort((a, b) {
      final av = sortFn!(a);
      final bv = sortFn!(b);
      final result = sortOrder == SortOrder.ascending
          ? av.compareTo(bv)
          : bv.compareTo(av);
      if (result != 0) {
        return result;
      }
      // Stable tie-break: equal keys keep the order in which items arrived.
      return _sequenceOf(a).compareTo(_sequenceOf(b));
    });
  }
}
