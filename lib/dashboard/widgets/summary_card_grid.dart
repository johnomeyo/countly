import 'package:countly/dashboard/widgets/summary_card.dart';
import 'package:flutter/material.dart';

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
