import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:collection';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> transactions = [
    {
      'type': 'Sale',
      'category': 'Eyeglasses',
      'product': 'Classic Frame Glasses',
      'brand': 'Ray-Ban',
      'quantity': 4,
      'unitPrice': 5500,
      'total': 22000.0,
      'timestamp': '2025-07-01T10:30:00',
    },
    {
      'type': 'Sale',
      'category': 'Sunglasses',
      'product': 'Polarized Aviators',
      'brand': 'Oakley',
      'quantity': 3,
      'unitPrice': 8500,
      'total': 25500.0,
      'timestamp': '2025-07-01T12:00:00',
    },
    {
      'type': 'Sale',
      'category': 'Contact Lenses',
      'product': 'Daily Wear Lenses - Pack of 30',
      'brand': 'Acuvue',
      'quantity': 5,
      'unitPrice': 3500,
      'total': 17500.0,
      'timestamp': '2025-07-01T13:15:00',
    },
    {
      'type': 'Sale',
      'category': 'Accessories',
      'product': 'Lens Cleaning Kit',
      'brand': 'Zeiss',
      'quantity': 6,
      'unitPrice': 800,
      'total': 4800.0,
      'timestamp': '2025-07-01T15:00:00',
    },
    {
      'type': 'Sale',
      'category': 'Eyeglasses',
      'product': 'Square Frame Blue Light Glasses',
      'brand': 'Lenskart',
      'quantity': 2,
      'unitPrice': 3000,
      'total': 6000.0,
      'timestamp': '2025-07-01T16:45:00',
    },
    {
      'type': 'Expense',
      'category': 'Stock Refill',
      'product': 'Classic Frame Glasses',
      'brand': 'Ray-Ban',
      'quantity': 10,
      'unitPrice': 4000,
      'total': 40000.0,
      'timestamp': '2025-06-30T11:00:00',
    },
    {
      'type': 'Expense',
      'category': 'Stock Refill',
      'product': 'Polarized Aviators',
      'brand': 'Oakley',
      'quantity': 5,
      'unitPrice': 6000,
      'total': 30000.0,
      'timestamp': '2025-06-30T14:00:00',
    },
    {
      'type': 'Expense',
      'category': 'Accessories',
      'product': 'Lens Cleaning Kit',
      'brand': 'Zeiss',
      'quantity': 10,
      'unitPrice': 600,
      'total': 6000.0,
      'timestamp': '2025-06-29T10:00:00',
    },
    {
      'type': 'Sale',
      'category': 'Sunglasses',
      'product': 'Round Retro Sunglasses',
      'brand': 'Gucci',
      'quantity': 1,
      'unitPrice': 12000,
      'total': 12000.0,
      'timestamp': '2025-07-01T17:30:00',
    },
    {
      'type': 'Sale',
      'category': 'Contact Lenses',
      'product': 'Monthly Color Lenses - Pair',
      'brand': 'FreshLook',
      'quantity': 3,
      'unitPrice': 2200,
      'total': 6600.0,
      'timestamp': '2025-07-01T18:10:00',
    },
  ];

  List<String> get filters => ['All', 'Sale', 'Expense'];

  List<Map<String, dynamic>> get filteredTransactions =>
      _selectedFilter == 'All'
          ? transactions
          : transactions.where((t) => t['type'] == _selectedFilter).toList();

  double get totalSales => transactions
      .where((t) => t['type'] == 'Sale')
      .fold(0.0, (sum, t) => sum + t['total']);

  double get totalExpenses => transactions
      .where((t) => t['type'] == 'Expense')
      .fold(0.0, (sum, t) => sum + t['total']);

  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (var t in filteredTransactions) {
      final key = t['category'];
      map[key] = (map[key] ?? 0) + t['total'];
    }
    return map;
  }

  Map<String, double> get brandDistribution {
    final map = <String, double>{};
    for (var t in filteredTransactions.where((e) => e['type'] == 'Sale')) {
      final key = t['brand'];
      map[key] = (map[key] ?? 0) + t['quantity'];
    }
    return map;
  }

  Map<String, double> get dailyTotals {
    final map = SplayTreeMap<String, double>();
    for (var t in filteredTransactions) {
      final date = t['timestamp'].toString().substring(0, 10);
      map[date] = (map[date] ?? 0) + t['total'];
    }
    return map;
  }

  Map<String, int> get productSalesCount {
    final map = <String, int>{};
    for (var t in transactions.where((t) => t['type'] == 'Sale')) {
      final product = t['product'];
      map[product] =
          (map[product] ?? 0) + int.tryParse(t['quantity'].toString())!;
    }
    return map;
  }

  String get chartTitle {
    switch (_selectedFilter) {
      case 'Sale':
        return 'Sales';
      case 'Expense':
        return 'Expenses';
      default:
        return 'All Transactions';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bestProduct =
        productSalesCount.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
            .key;

    return Scaffold(
      // backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Business Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics Overview',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            FilterDropdown(
              selectedFilter: _selectedFilter,
              filters: filters,
              onChanged: (value) => setState(() => _selectedFilter = value!),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Total Sales',
                    value: totalSales,
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SummaryCard(
                    title: 'Total Expenses',
                    value: totalExpenses,
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            BestProductCard(product: bestProduct),
            const SizedBox(height: 32),

            ChartContainer(
              title: '$chartTitle by Category',
              subtitle: 'Revenue breakdown across different product categories',
              child: BarChartWidget(data: categoryTotals),
            ),
            const SizedBox(height: 32),

            ChartContainer(
              title: 'Daily $chartTitle Trend',
              subtitle: 'Track your daily performance over time',
              child: LineChartWidget(data: dailyTotals),
            ),
            const SizedBox(height: 32),

            if (_selectedFilter != 'Expense')
              ChartContainer(
                title: 'Brand Distribution',
                subtitle: 'Sales quantity breakdown by brand',
                child: PieChartWidget(data: brandDistribution),
              ),
          ],
        ),
      ),
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String?> onChanged;

  const FilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.filters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: DropdownButton<String>(
        value: selectedFilter,
        onChanged: onChanged,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.blue),

        items:
            filters
                .map(
                  (filter) => DropdownMenuItem(
                    value: filter,
                    child: Row(
                      children: [
                        Icon(
                          filter == 'All'
                              ? Icons.dashboard
                              : filter == 'Sale'
                              ? Icons.shopping_cart
                              : Icons.receipt_long,
                          size: 20,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text('Filter: $filter'),
                      ],
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final Color color;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.more_vert, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Ksh ${value.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class BestProductCard extends StatelessWidget {
  final String product;

  const BestProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: const Icon(Icons.star, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Best Selling Product',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  product,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const ChartContainer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(height: 220, child: child),
          ],
        ),
      ),
    );
  }
}

class BarChartWidget extends StatelessWidget {
  final Map<String, double> data;

  const BarChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final barGroups =
        data.entries.map((entry) {
          final index = data.keys.toList().indexOf(entry.key);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value,
                width: 20,
                color: Colors.blue[400]!,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget:
                  (value, meta) => Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data.keys.elementAt(value.toInt()),
                      // style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget:
                  (value, meta) => Text(
                    '${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 10000,
          getDrawingHorizontalLine:
              (value) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
        ),
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final Map<String, double> data;

  const LineChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No data available',
          // style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final spots =
        data.entries.toList().asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.value);
        }).toList();

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < data.length) {
                  final date = data.keys.elementAt(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      date.substring(5, 10),
                      // style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget:
                  (value, meta) => Text(
                    '${(value / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine:
              (value) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.purple[400]!,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.purple[400]!.withValues(alpha: 0.1),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter:
                  (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 4,
                    color: Colors.purple[400]!,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartWidget extends StatelessWidget {
  final Map<String, double> data;

  const PieChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'No sales data available',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    final colors = [
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.orange[400]!,
      Colors.purple[400]!,
      Colors.red[400]!,
      Colors.teal[400]!,
    ];

    final sections =
        data.entries.map((entry) {
          final index = data.keys.toList().indexOf(entry.key);
          final color = colors[index % colors.length];
          return PieChartSectionData(
            value: entry.value,
            title: '${entry.value.toInt()}',
            color: color,
            radius: 80,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              // color: Colors.white,
            ),
          );
        }).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                data.entries.map((entry) {
                  final index = data.keys.toList().indexOf(entry.key);
                  final color = colors[index % colors.length];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
