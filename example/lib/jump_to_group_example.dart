import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_grouped_list/infinite_grouped_list.dart';

class JumpToGroupExample extends StatefulWidget {
  const JumpToGroupExample({super.key});

  @override
  State<JumpToGroupExample> createState() => _JumpToGroupExampleState();
}

class _JumpToGroupExampleState extends State<JumpToGroupExample> {
  final _controller =
      InfiniteGroupedListController<_Transaction, DateTime, String>();
  final _random = Random();
  DateTime _cursorDay = DateTime.now();
  bool _jumpInProgress = false;

  Future<List<_Transaction>> _fetchPage(PaginationInfo info) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return List.generate(info.limit, (index) {
      final tx = _Transaction(
        name: 'Tx #${info.offset + index + 1}',
        dateTime: _cursorDay.add(Duration(hours: _random.nextInt(23))),
        amount: (_random.nextDouble() * 120).roundToDouble(),
        icon: _icons[_random.nextInt(_icons.length)],
      );
      // Move to previous day every few items to keep batches grouped.
      if ((index + 1) % 3 == 0) {
        _cursorDay = _cursorDay.subtract(const Duration(days: 1));
      }
      return tx;
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _jumpToToday() async {
    setState(() => _jumpInProgress = true);
    final found = await _controller.jumpToGroup(
      predicate: (title, groupBy) => _isSameDay(groupBy, DateTime.now()),
      alignment: 0.0,
      animate: true,
      loadUntilFound: true,
    );
    if (!mounted) return;
    setState(() => _jumpInProgress = false);
    if (!found) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Today was not found in the feed yet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jump-to-Group Example'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _jumpInProgress ? null : _jumpToToday,
        icon: const Icon(Icons.today),
        label: Text(_jumpInProgress ? 'Jumping...' : 'Jump to Today'),
        backgroundColor: Colors.teal,
      ),
      body: InfiniteGroupedList<_Transaction, DateTime, String>(
        enableAnchoring: true,
        controller: _controller,
        groupBy: (item) => DateTime(
            item.dateTime.year, item.dateTime.month, item.dateTime.day),
        sortGroupBy: (item) => item.dateTime,
        groupCreator: (date) {
          final now = DateTime.now();
          if (_isSameDay(date, now)) return 'Today';
          if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
            return 'Yesterday';
          }
          return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
        },
        groupTitleBuilder: (title, _, __, ___) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[200],
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        seperatorBuilder: (_) => const Divider(height: 1),
        itemBuilder: (item) => ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.teal.withOpacity(0.1),
            child: Icon(item.icon, color: Colors.teal),
          ),
          title: Text(item.name),
          subtitle: Text("${item.dateTime.hour.toString().padLeft(2, '0')}:00"),
          trailing: Text('EUR ${item.amount.toStringAsFixed(2)}'),
        ),
        onLoadMore: _fetchPage,
        onNoMoreItemsFound: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reached the beginning of history.')),
          );
        },
      ),
    );
  }
}

class _Transaction {
  _Transaction({
    required this.name,
    required this.dateTime,
    required this.amount,
    required this.icon,
  });

  final String name;
  final DateTime dateTime;
  final double amount;
  final IconData icon;
}

const _icons = <IconData>[
  Icons.fastfood,
  Icons.directions_bus,
  Icons.shopping_bag,
  Icons.movie,
  Icons.medical_services,
  Icons.coffee,
];

const _monthNames = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
