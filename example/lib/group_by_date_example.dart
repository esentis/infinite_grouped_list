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
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
      body: InfiniteGroupedList(
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
        seperatorBuilder: (item) => const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.black12,
          ),
        ),
        itemBuilder: (item) => ListTile(
          title: Text(item.name),
          leading: item.type == TransactionType.transport
              ? const Icon(Icons.directions_bus)
              : item.type == TransactionType.food
                  ? const Icon(Icons.fastfood)
                  : item.type == TransactionType.shopping
                      ? const Icon(Icons.shopping_bag)
                      : item.type == TransactionType.entertainment
                          ? const Icon(Icons.movie)
                          : item.type == TransactionType.health
                              ? const Icon(Icons.medical_services)
                              : const Icon(Icons.money),
          trailing: Text(
            '${item.amount.toStringAsFixed(2)}€',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(item.dateTime.toIso8601String()),
        ),
        onLoadMore: (info) => onLoadMore(info.offset),
        loadMoreItemsErrorWidget: GestureDetector(
          child: const Text(
            'Something went wrong,\ntap to retry',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
              decorationColor: Colors.blue,
              color: Colors.blue,
            ),
          ),
        ),
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
