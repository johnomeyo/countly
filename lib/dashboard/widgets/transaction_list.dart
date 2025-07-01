
import 'package:flutter/material.dart';

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

