import 'package:countly/services/hive_storage.dart';
import 'package:countly/transactions/transaction_management_page.dart';
import 'package:flutter/material.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = TransactionStorage().getAllTransactions();
    return Scaffold(
      // body: ListView.builder(
      //   itemCount: transactions.length,
      //   itemBuilder: (context, index) {
      //   return ListTile(
      //     title: Text(transactions[index].type ),
      //     subtitle: Text('Subtitle for item $index'),
      //     leading: Icon(Icons.label),
      //     trailing: Icon(Icons.arrow_forward),
      //     onTap: () {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(content: Text('Tapped on Item $index')),
      //       );
      //     },
      //   );
      // }),
      body: TransactionList(transactions: transactions),
      appBar: AppBar(title: Text('Demo Page')),

    );
  }
}
