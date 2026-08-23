import 'package:flutter/material.dart';
import 'package:infinite_grouped_list/src/infinite_grouped_list.dart';

class EmptyList extends StatelessWidget {
  const EmptyList({
    super.key,
    required this.widget,
    required this.hasError,
    required this.error,
  });

  final InfiniteGroupedList widget;
  final bool hasError;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: widget.physics,
      slivers: [
        SliverFillRemaining(
          child: Center(
            child: hasError
                ? widget.initialItemsErrorWidget?.call(error) ??
                    Center(
                      child: Text(
                        'Something went wrong while fetching items',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 20,
                        ),
                      ),
                    )
                : widget.noItemsFoundWidget ??
                    Text(
                      'No items found',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
