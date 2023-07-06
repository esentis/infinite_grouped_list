import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_grouped_list/infinite_grouped_list.dart';

enum TransactionType {
  transport,
  food,
  shopping,
  entertainment,
  health,
  other,
}

class Transaction {
  final String name;
  final DateTime dateTime;
  final double amount;
  final TransactionType type;
  Transaction({
    required this.name,
    required this.dateTime,
    required this.amount,
    required this.type,
  });

  @override
  String toString() {
    return '{name: $name, dateTime: $dateTime}';
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool dontThrowError = false;

  DateTime baseDate = DateTime.now();

  Future<List<Transaction>> onLoadMore(int offset) async {
    await Future.delayed(const Duration(seconds: 1));

    return List<Transaction>.generate(
      20,
      (index) {
        final tempDate = baseDate;
        baseDate = baseDate.subtract(const Duration(days: 1));
        return Transaction(
          name: 'Transaction num #$index',
          dateTime: tempDate,
          amount: Random().nextDouble() * 1000,
          type: TransactionType.values[Random().nextInt(6)],
        );
      },
    );
  }

  Widget getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.transport:
        return const Icon(Icons.directions_bus);
      case TransactionType.food:
        return const Icon(Icons.fastfood);
      case TransactionType.shopping:
        return const Icon(Icons.shopping_bag);
      case TransactionType.entertainment:
        return const Icon(Icons.movie);
      case TransactionType.health:
        return const Icon(Icons.medical_services);
      default:
        return const Icon(Icons.money);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        shadowColor: Colors.grey.withOpacity(0.2),
        title: const Text('Infinite Grouped List'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 5,
      ),
      body: InfiniteGroupedList.gridView(
        groupBy: (item) => item.dateTime,
        sortGroupBy: (item) => item.dateTime,
        groupTitleBuilder: (title, groupBy, isPinned, scrollPercentage) =>
            Padding(
          padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        itemBuilder: (item) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getTransactionIcon(item.type),
                Text(item.name),
                Text(
                  '${item.amount.toStringAsFixed(2)}€',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        onLoadMore: (info) => onLoadMore(info.offset),
        groupCreator: (dateTime) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));
          final lastWeek = today.subtract(const Duration(days: 7));
          final lastMonth = DateTime(today.year, today.month - 1, today.day);

          if (today.day == dateTime.day &&
              today.month == dateTime.month &&
              today.year == dateTime.year) {
            return 'Today';
          } else if (yesterday.day == dateTime.day &&
              yesterday.month == dateTime.month &&
              yesterday.year == dateTime.year) {
            return 'Yesterday';
          } else if (lastWeek.isBefore(dateTime) &&
              dateTime.isBefore(yesterday)) {
            return 'Last Week';
          } else if (lastMonth.isBefore(dateTime) &&
              dateTime.isBefore(lastWeek)) {
            return 'Last Month';
          } else {
            // Convert the DateTime to a string for grouping
            return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
          }
        },
      ),
    );
  }
}
