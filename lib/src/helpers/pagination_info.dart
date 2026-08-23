class PaginationInfo {
  final int offset;
  final int page;
  final int limit;
  PaginationInfo({
    required this.offset,
    required this.page,
    required this.limit,
  });

  /// Returns a copy of this [PaginationInfo] with the given fields replaced.
  PaginationInfo copyWith({
    int? offset,
    int? page,
    int? limit,
  }) {
    return PaginationInfo(
      offset: offset ?? this.offset,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PaginationInfo &&
        other.offset == offset &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(offset, page, limit);

  @override
  String toString() =>
      'PaginationInfo(offset: $offset, page: $page, limit: $limit)';
}

/// The sort order of the items inside the groups.
enum SortOrder { ascending, descending }
