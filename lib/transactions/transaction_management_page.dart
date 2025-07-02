import 'package:flutter/material.dart';

class TransactionManagementPage extends StatefulWidget {
  const TransactionManagementPage({super.key});

  @override
  State<TransactionManagementPage> createState() =>
      _TransactionManagementPageState();
}

class _TransactionManagementPageState extends State<TransactionManagementPage> {
  final List<Map<String, dynamic>> allTransactions = [
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

  List<Map<String, dynamic>> filteredTransactions = [];
  String searchQuery = '';
  String filterType = 'All';

  @override
  void initState() {
    super.initState();
    filteredTransactions = allTransactions;
  }

  void applyFilters() {
    setState(() {
      filteredTransactions =
          allTransactions.where((t) {
            final matchesType = filterType == 'All' || t['type'] == filterType;
            final matchesSearch =
                t['product'].toString().toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                t['brand'].toString().toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
            return matchesType && matchesSearch;
          }).toList();
    });
  }

  double get totalSales => filteredTransactions
      .where((t) => t['type'] == 'Sale')
      .fold(0.0, (sum, t) => sum + t['total']);

  double get totalExpenses => filteredTransactions
      .where((t) => t['type'] == 'Expense')
      .fold(0.0, (sum, t) => sum + t['total']);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Transaction Management',
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          TransactionSummaryCard(
            totalSales: totalSales,
            totalExpenses: totalExpenses,
          ),
          TransactionFilters(
            searchQuery: searchQuery,
            filterType: filterType,
            onSearchChanged: (value) {
              searchQuery = value;
              applyFilters();
            },
            onFilterChanged: (value) {
              if (value != null) {
                filterType = value;
                applyFilters();
              }
            },
          ),
          Expanded(child: TransactionList(transactions: filteredTransactions)),
        ],
      ),
    );
  }
}

// Reusable Summary Card Component
class TransactionSummaryCard extends StatefulWidget {
  final double totalSales;
  final double totalExpenses;

  const TransactionSummaryCard({
    super.key,
    required this.totalSales,
    required this.totalExpenses,
  });

  @override
  State<TransactionSummaryCard> createState() => _TransactionSummaryCardState();
}

class _TransactionSummaryCardState extends State<TransactionSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Add a small delay to prevent immediate animation on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netProfit = widget.totalSales - widget.totalExpenses;

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideAnimation.value)),
          child: Opacity(
            opacity: _slideAnimation.value.clamp(0.0, 1.0),
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: SummaryItem(
                        title: 'Sales',
                        amount: widget.totalSales,
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: SummaryItem(
                        title: 'Expenses',
                        amount: widget.totalExpenses,
                        icon: Icons.trending_down,
                        color: Colors.red,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                    Expanded(
                      child: SummaryItem(
                        title: 'Net Profit',
                        amount: netProfit,
                        icon: Icons.account_balance_wallet,
                        color: netProfit >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Reusable Summary Item Component
class SummaryItem extends StatefulWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;

  const SummaryItem({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  State<SummaryItem> createState() => _SummaryItemState();
}

class _SummaryItemState extends State<SummaryItem> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(widget.icon, color: widget.color, size: 28),
        const SizedBox(height: 8),
        Text(
          widget.title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ksh ${widget.amount.toStringAsFixed(0)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// Reusable Filters Component
class TransactionFilters extends StatefulWidget {
  final String searchQuery;
  final String filterType;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onFilterChanged;

  const TransactionFilters({
    super.key,
    required this.searchQuery,
    required this.filterType,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  State<TransactionFilters> createState() => _TransactionFiltersState();
}

class _TransactionFiltersState extends State<TransactionFilters> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search products or brands',
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: DropdownButton<String>(
              value: widget.filterType,
              underline: const SizedBox(),
              icon: Icon(
                Icons.filter_list,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Types')),
                DropdownMenuItem(value: 'Sale', child: Text('Sales Only')),
                DropdownMenuItem(
                  value: 'Expense',
                  child: Text('Expenses Only'),
                ),
              ],
              onChanged: widget.onFilterChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Transaction List Component
class TransactionList extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    if (widget.transactions.isEmpty) {
      return const EmptyTransactionState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.transactions.length,
      itemBuilder: (context, index) {
        return TransactionCard(
          transaction: widget.transactions[index],
          index: index,
        );
      },
    );
  }
}

// Reusable Transaction Card Component
class TransactionCard extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final int index;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.index,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Add a small delay to prevent immediate animation on build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transaction = widget.transaction;
    final isSale = transaction['type'] == 'Sale';

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - _slideAnimation.value), 0),
          child: Opacity(
            opacity: _slideAnimation.value.clamp(0.0, 1.0),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isSale ? Colors.green : Colors.red).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSale ? Icons.trending_up : Icons.trending_down,
                        color: isSale ? Colors.green : Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction['product'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction['brand'],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TransactionDetailChip(
                                label: 'Qty: ${transaction['quantity']}',
                                icon: Icons.inventory_2_outlined,
                              ),
                              const SizedBox(width: 8),
                              TransactionDetailChip(
                                label: transaction['category'],
                                icon: Icons.category_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(transaction['timestamp']),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Ksh ${transaction['total'].toStringAsFixed(0)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSale ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@Ksh ${transaction['unitPrice']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(String timestamp) {
    final date = DateTime.parse(timestamp);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Reusable Detail Chip Component
class TransactionDetailChip extends StatefulWidget {
  final String label;
  final IconData icon;

  const TransactionDetailChip({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  State<TransactionDetailChip> createState() => _TransactionDetailChipState();
}

class _TransactionDetailChipState extends State<TransactionDetailChip> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            widget.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Empty State Component
class EmptyTransactionState extends StatefulWidget {
  const EmptyTransactionState({super.key});

  @override
  State<EmptyTransactionState> createState() => _EmptyTransactionStateState();
}

class _EmptyTransactionStateState extends State<EmptyTransactionState> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
