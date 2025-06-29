import 'package:example/group_by_date_example.dart';
import 'package:example/group_by_date_grid_example.dart';
import 'package:example/group_by_type_example.dart';
import 'package:example/reactive_bloc_example.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Grouped List Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleSelectionPage(),
    );
  }
}

class ExampleSelectionPage extends StatelessWidget {
  const ExampleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Grouped List Examples'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose an example to explore:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildExampleCard(
              context,
              title: 'Reactive BLoC Example',
              subtitle:
                  'Demonstrates reactive state management with BLoC pattern',
              icon: Icons.memory,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ReactiveBlocExample()),
              ),
              isNew: true,
            ),
            const SizedBox(height: 16),
            _buildExampleCard(
              context,
              title: 'Group by Date Example',
              subtitle: 'Groups items by date with imperative pattern',
              icon: Icons.date_range,
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GroupByDateExample()),
              ),
            ),
            const SizedBox(height: 16),
            _buildExampleCard(
              context,
              title: 'Group by Type Example',
              subtitle: 'Groups items by category/type',
              icon: Icons.category,
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GroupByTypeExample()),
              ),
            ),
            const SizedBox(height: 16),
            _buildExampleCard(
              context,
              title: 'Grid View Example',
              subtitle: 'Groups items in a grid layout by date',
              icon: Icons.grid_view,
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GroupByDateGridExample()),
              ),
            ),
            const Spacer(),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'New: Reactive Pattern Support',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The InfiniteGroupedList now supports reactive state management patterns like BLoC, Provider, and Riverpod with the new .reactive() and .reactiveGrid() constructors!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isNew = false,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
