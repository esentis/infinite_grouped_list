class PaginationInfo {
  final int offset;
  final int page;
  final int limit;
  PaginationInfo({
    required this.offset,
    required this.page,
    required this.limit,
  });
}

/// The sort order of the items inside the groups.
enum SortOrder { ascending, descending }
