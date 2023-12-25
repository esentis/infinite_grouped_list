import 'package:flutter/material.dart';
import 'package:infinite_grouped_list/infinite_grouped_list.dart';

class EmptyList extends StatelessWidget {
  const EmptyList({
    super.key,
    required this.widget,
    required this.hasError,
    required this.error,
  });

  final InfiniteGroupedList widget;
  final bool hasError;
  final dynamic error;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: widget.physics,
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: hasError
                ? widget.initialItemsErrorWidget?.call(error) ??
                    const Center(
                      child: Text(
                        'Something went wrong while fetching items',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                      ),
                    )
                : widget.noItemsFoundWidget ??
                    const Text(
                      'No items found',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
