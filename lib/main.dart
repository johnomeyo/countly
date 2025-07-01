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
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Here is your business summary for today.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const SummaryCardGrid(),
            const SizedBox(height: 24),
            Text(
              'Recent Transactions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Expanded(child: TransactionList()),
          ],
        ),
      ),
    );
  }
}

class SummaryCardGrid extends StatelessWidget {
  const SummaryCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        SummaryCard(
          title: 'Income',
          amount: 'KES 12,000',
          icon: Icons.arrow_downward,
          color: Colors.green,
        ),
        SummaryCard(
          title: 'Expenses',
          amount: 'KES 4,500',
          icon: Icons.arrow_upward,
          color: Colors.red,
        ),
        SummaryCard(
          title: 'Profit',
          amount: 'KES 7,500',
          icon: Icons.trending_up,
          color: Colors.blue,
        ),
        SummaryCard(
          title: 'Sales',
          amount: 'KES 18,000',
          icon: Icons.sell,
          color: Colors.orange,
        ),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              amount,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  final List<Map<String, dynamic>> transactions = [
    {'title': 'MPESA Payment', 'amount': 'KES 2,000', 'type': 'income'},
    {'title': 'Bought Supplies', 'amount': 'KES 1,200', 'type': 'expense'},
    {'title': 'Customer Payment', 'amount': 'KES 3,000', 'type': 'income'},

    {'title': 'Utility Bill', 'amount': 'KES 800', 'type': 'expense'},
    {'title': 'Salary Payment', 'amount': 'KES 5,000', 'type': 'expense'},
    {'title': 'Refund Issued', 'amount': 'KES 1,500', 'type': 'expense'},
    {'title': 'New Client Contract', 'amount': 'KES 4,000', 'type': 'income'},
    {'title': 'Office Rent', 'amount': 'KES 6,000', 'type': 'expense'},
    {'title': 'Equipment Purchase', 'amount': 'KES 3,500', 'type': 'expense'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return ListTile(
          leading: Icon(
            tx['type'] == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
            color: tx['type'] == 'income' ? Colors.green : Colors.red,
          ),
          title: Text(tx['title']),
          trailing: Text(
            tx['amount'],
            style: TextStyle(
              color: tx['type'] == 'income' ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
