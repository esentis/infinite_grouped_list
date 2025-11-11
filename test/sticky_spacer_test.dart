import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SliverStickyHeader with Spacer in header builds',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverStickyHeader.builder(
                builder: _headerBuilder,
                sliver: const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  });
}

Widget _headerBuilder(BuildContext context, SliverStickyHeaderState state) {
  return const Row(
    children: [
      Text('Title'),
      Spacer(),
      Icon(Icons.pin_drop),
    ],
  );
}
