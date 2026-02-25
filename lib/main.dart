import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MonBudgetApp()));
}

final compteurProvider = StateProvider<int>((ref) => 0);

class MonBudgetApp extends StatelessWidget {
  const MonBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // automatique selon téléphone
      title: 'MonBudget',
      home:const HomePage(),
    );
  }
}


class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compteur = ref.watch(compteurProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Test Riverpod")),
      body: Center(
        child: Text(
          '$compteur',
          style: const TextStyle(fontSize: 40),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(compteurProvider.notifier).state++;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}