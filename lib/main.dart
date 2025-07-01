import 'package:countly/dashboard/dashboard_page.dart';
import 'package:countly/transactions/add_transactions_page.dart';
import 'package:flutter/material.dart';

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
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      // theme: ThemeData(

      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      // ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to SmallBiz Manager')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Let’s get started!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose what you want to do:',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const ActionButtons(),
          ],
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeActionButton(
          icon: Icons.attach_money,
          label: 'Add Transaction',
          onTap: () {
            // Navigate to transaction form
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTransactionPage()),
            );
          },
        ),
        const SizedBox(height: 16),
        HomeActionButton(
          icon: Icons.analytics,
          label: 'View Dashboard',
          onTap: () {
            // Navigate to dashboard
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          },
        ),
        const SizedBox(height: 16),
        HomeActionButton(
          icon: Icons.receipt_long,
          label: 'Manage Records',
          onTap: () {
            // Navigate to transaction history
          },
        ),
      ],
    );
  }
}

class HomeActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HomeActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        onPressed: onTap,
      ),
    );
  }
}
