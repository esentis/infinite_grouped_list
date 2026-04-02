import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_grouped_list/src/helpers/empty_list.dart';
import 'package:infinite_grouped_list/src/infinite_grouped_list.dart';

InfiniteGroupedList<String, String, String> _baseWidget({
  Widget? noItemsFoundWidget,
  Widget Function(dynamic error)? initialItemsErrorWidget,
}) {
  return InfiniteGroupedList<String, String, String>(
    onLoadMore: (_) async => <String>[],
    noItemsFoundWidget: noItemsFoundWidget,
    initialItemsErrorWidget: initialItemsErrorWidget,
    groupBy: (item) => item,
    groupCreator: (groupBy) => groupBy,
    groupTitleBuilder: (title, _, __, ___) => Text(title),
    itemBuilder: (item) => Text(item),
  );
}

void main() {
  testWidgets('shows the default empty state message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EmptyList(
          widget: _baseWidget(),
          hasError: false,
          error: null,
        ),
      ),
    );

    expect(find.text('No items found'), findsOneWidget);
  });

  testWidgets('shows a custom empty state widget when provided',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EmptyList(
          widget: _baseWidget(
            noItemsFoundWidget: const Text('Custom empty state'),
          ),
          hasError: false,
          error: null,
        ),
      ),
    );

    expect(find.text('Custom empty state'), findsOneWidget);
  });

  testWidgets('shows the default initial error widget', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EmptyList(
          widget: _baseWidget(),
          hasError: true,
          error: Exception('boom'),
        ),
      ),
    );

    expect(
        find.text('Something went wrong while fetching items'), findsOneWidget);
  });

  testWidgets('shows a custom initial error widget when provided',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EmptyList(
          widget: _baseWidget(
            initialItemsErrorWidget: (error) => Text('Error: $error'),
          ),
          hasError: true,
          error: 'boom',
        ),
      ),
    );

    expect(find.text('Error: boom'), findsOneWidget);
  });
}
