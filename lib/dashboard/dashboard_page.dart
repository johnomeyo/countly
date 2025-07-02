import 'package:countly/models/transaction.dart';
import 'package:countly/services/hive_storage.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:collection';

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
          show: false,
          horizontalInterval: 10000,
          getDrawingHorizontalLine:
              (value) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
        ),
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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedFilter = 'All';

  // Get the singleton instance of TransactionStorage
  final TransactionStorage _transactionStorage = TransactionStorage();
  // Stream to listen for real-time updates from Hive
  late Stream<List<Transaction>> _transactionsStream;

  // Internal list to hold all transactions from the stream
  List<Transaction> _allTransactions = [];

  List<String> get filters => ['All', 'Sale', 'Expense'];

  // Filter transactions based on the selected filter
  List<Transaction> get _filteredTransactions =>
      _selectedFilter == 'All'
          ? _allTransactions
          : _allTransactions.where((t) => t.type == _selectedFilter).toList();

  // Calculate total sales from all transactions (not just filtered)
  double get totalSales => _allTransactions
      .where((t) => t.type == 'Sale')
      .fold(0.0, (sum, t) => sum + t.total);

  // Calculate total expenses from all transactions (not just filtered)
  double get totalExpenses => _allTransactions
      .where((t) => t.type == 'Expense')
      .fold(0.0, (sum, t) => sum + t.total);

  // Category totals for the currently filtered transactions
  Map<String, double> get categoryTotals {
    final map = <String, double>{};
    for (var t in _filteredTransactions) {
      final key = t.category;
      map[key] = (map[key] ?? 0) + t.total;
    }
    return map;
  }

  // Brand distribution (sales quantity) for the currently filtered sales transactions
  Map<String, double> get brandDistribution {
    final map = <String, double>{};
    for (var t in _filteredTransactions.where((e) => e.type == 'Sale')) {
      final key = t.brand;
      map[key] = (map[key] ?? 0) + t.quantity;
    }
    return map;
  }

  // Daily totals for the currently filtered transactions
  Map<String, double> get dailyTotals {
    // SplayTreeMap maintains sorted order by keys (dates in this case)
    final map = SplayTreeMap<String, double>();
    for (var t in _filteredTransactions) {
      final date = t.timestamp.toIso8601String().substring(
        0,
        10,
      ); // Format date as 'YYYY-MM-DD'
      map[date] = (map[date] ?? 0) + t.total;
    }
    return map;
  }

  // Product sales count for all sales transactions
  Map<String, int> get productSalesCount {
    final map = <String, int>{};
    for (var t in _allTransactions.where((t) => t.type == 'Sale')) {
      final product = t.product;
      map[product] = (map[product] ?? 0) + t.quantity;
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
  void initState() {
    super.initState();
    // Initialize the stream from TransactionStorage
    _transactionsStream = _transactionStorage.transactionsStream;

    // Listen to the stream and update the internal _allTransactions list
    // This ensures _allTransactions is always in sync with Hive
    _transactionsStream.listen((transactions) {
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _allTransactions = transactions;
          // No explicit call to _filteredTransactions or other getters needed here,
          // as they are getters and will re-evaluate when _allTransactions changes.
        });
      }
    });

    // Optionally, load initial data synchronously if the stream takes time to emit the first event
    // The `listen` callback will eventually update `_allTransactions`
    _allTransactions = _transactionStorage.getAllTransactions();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate bestProduct using the latest `_allTransactions` data
    String bestProduct = 'N/A';
    if (productSalesCount.isNotEmpty) {
      bestProduct =
          productSalesCount.entries
              .reduce((a, b) => a.value >= b.value ? a : b)
              .key;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Business Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: _transactionsStream,
        // Provide initial data to avoid "Loading" state if no transactions yet
        initialData: _transactionStorage.getAllTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // This setState within StreamBuilder's builder will ensure that
          // _allTransactions is updated and thus all getters recalculate.
          // However, the `listen` in initState already handles this.
          // So, for simplicity, we'll just use the `snapshot.data` for calculations.
          // Note: If you have a separate `_allTransactions` list in state,
          // and you want StreamBuilder to manage it, the `listen` might be redundant.
          // For this setup, `_allTransactions` in the state is updated by `listen`,
          // and getters use that state variable, making the dashboard reactive.

          // Check if there's any data to display before showing charts
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No transaction data to display.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add some transactions to see your dashboard insights!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          // If we reach here, snapshot.hasData is true and data is not empty.
          // _allTransactions in the state is updated by the stream listener,
          // so all getters based on `_allTransactions` or `_filteredTransactions` will be correct.

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics Overview',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                FilterDropdown(
                  selectedFilter: _selectedFilter,
                  filters: filters,
                  onChanged:
                      (value) => setState(() => _selectedFilter = value!),
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
                  subtitle:
                      'Revenue breakdown across different product categories',
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
          );
        },
      ),
    );
  }
}

// All other reusable components (FilterDropdown, SummaryCard, BestProductCard, ChartContainer,
// BarChartWidget, LineChartWidget, PieChartWidget) remain largely the same,
// but ensure you replace `withValues(alpha: ...)` with `withAlpha(...)`
// in places like `SummaryCard` and `PieChartWidget` if you haven't already.
// For brevity, I'm only including the main DashboardPage changes.

// Example update for SummaryCard if needed
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
                    color: color.withAlpha(25), // Changed from withValues
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

// Example update for BestProductCard if needed
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
            color: Colors.blue.withAlpha(76), // Changed from withValues
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

// Example update for LineChartWidget if needed
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
          show: false,
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
              color: Colors.purple[400]!.withAlpha(
                25,
              ), // Changed from withValues
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

// Example update for PieChartWidget if needed
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
