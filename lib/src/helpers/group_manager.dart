// lib/src/helpers/group_manager.dart

import 'package:infinite_grouped_list/infinite_grouped_list.dart';

/// A helper class that centralizes grouping, merging, sorting, and removal logic
/// for the InfiniteGroupedList.
///
/// [ItemType] is the type of your item. [GroupBy] is the value you group by.
/// [GroupTitle] is the value you display as the group header.
class GroupManager<ItemType, GroupBy, GroupTitle> {
  /// Function to extract the grouping key from an item.
  final GroupBy Function(ItemType item) groupBy;

  /// Function to create the displayed group title from the grouping key.
  final GroupTitle Function(GroupBy groupBy) groupCreator;

  /// Optional sort function; must return a Comparable.
  final Comparable Function(ItemType item)? sortFn;

  /// Order in which to sort groups.
  final SortOrder sortOrder;

  GroupManager({
    required this.groupBy,
    required this.groupCreator,
    this.sortFn,
    this.sortOrder = SortOrder.descending,
  });

  /// Creates initial groups from a full list of items.
  Map<GroupTitle, List<ItemType>> initialize(List<ItemType> items) {
    final groups = <GroupTitle, List<ItemType>>{};
    for (final item in items) {
      final key = groupCreator(groupBy(item));
      groups.putIfAbsent(key, () => []).add(item);
    }
    if (sortFn != null) _sortAll(groups);
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
      return sortOrder == SortOrder.ascending
          ? av.compareTo(bv)
          : bv.compareTo(av);
    });
  }
}
