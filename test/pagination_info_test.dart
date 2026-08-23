import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_grouped_list/src/helpers/pagination_info.dart';

void main() {
  test('equal pagination infos are equal and share a hash code', () {
    final a = PaginationInfo(offset: 10, page: 2, limit: 20);
    final b = PaginationInfo(offset: 10, page: 2, limit: 20);

    expect(a, equals(b));
    expect(a.hashCode, b.hashCode);
  });

  test('differing fields break equality', () {
    final base = PaginationInfo(offset: 0, page: 1, limit: 20);

    expect(base == base.copyWith(offset: 1), isFalse);
    expect(base == base.copyWith(page: 2), isFalse);
    expect(base == base.copyWith(limit: 40), isFalse);
    expect(base == Object(), isFalse);
  });

  test('copyWith replaces only the provided fields', () {
    final base = PaginationInfo(offset: 5, page: 3, limit: 50);

    final copied = base.copyWith(offset: 25);

    expect(copied.offset, 25);
    expect(copied.page, 3);
    expect(copied.limit, 50);
  });

  test('toString exposes the fields', () {
    final info = PaginationInfo(offset: 7, page: 4, limit: 30);

    expect(info.toString(), 'PaginationInfo(offset: 7, page: 4, limit: 30)');
  });
}
