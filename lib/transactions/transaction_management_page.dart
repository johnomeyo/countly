// import 'package:countly/models/transaction.dart';
// import 'package:countly/services/hive_storage.dart';
// import 'package:flutter/material.dart';

// class TransactionManagementPage extends StatefulWidget {
//   const TransactionManagementPage({super.key});

//   @override
//   State<TransactionManagementPage> createState() =>
//       _TransactionManagementPageState();
// }

// class _TransactionManagementPageState extends State<TransactionManagementPage> {
//   // Use Transaction objects instead of Maps
//   List<Transaction> allTransactions = [];
//   List<Transaction> filteredTransactions = [];

//   String searchQuery = '';
//   String filterType = 'All'; // 'All', 'Sale', 'Expense'

//   // Get the singleton instance of TransactionStorage
//   final TransactionStorage _transactionStorage = TransactionStorage();
//   // Stream to listen for real-time updates from Hive
//   late Stream<List<Transaction>> _transactionsStream;

//   @override
//   void initState() {
//     super.initState();
//     // Initialize the stream from TransactionStorage
//     _transactionsStream = _transactionStorage.transactionsStream;

//     // Listen to the stream and update the state
//     _transactionsStream.listen((transactions) {
//       setState(() {
//         allTransactions = transactions;
//         applyFilters(); // Re-apply filters whenever data changes
//       });
//     });

//     allTransactions = _transactionStorage.getAllTransactions();
//     applyFilters();
//   }

//   void applyFilters() {

//     final currentFiltered =
//         allTransactions.where((t) {
//           final matchesType = filterType == 'All' || t.type == filterType;
//           final matchesSearch =
//               t.product.toLowerCase().contains(searchQuery.toLowerCase()) ||
//               t.brand.toLowerCase().contains(searchQuery.toLowerCase());
//           return matchesType && matchesSearch;
//         }).toList();

//     if (filteredTransactions.length != currentFiltered.length ||
//         !listEquals(filteredTransactions, currentFiltered)) {
//       setState(() {
//         filteredTransactions = currentFiltered;
//       });
//     }
//   }

//   // Helper function to compare two lists of Transactions (shallow comparison)
//   bool listEquals(List<Transaction> a, List<Transaction> b) {
//     if (a.length != b.length) return false;
//     for (int i = 0; i < a.length; i++) {
//       if (a[i] != b[i])
//         return false; // This compares object references, might need deep comparison for value equality
//     }
//     return true;
//   }

//   double get totalSales => filteredTransactions
//       .where((t) => t.type == 'Sale')
//       .fold(0.0, (sum, t) => sum + t.total);

//   double get totalExpenses => filteredTransactions
//       .where((t) => t.type == 'Expense')
//       .fold(0.0, (sum, t) => sum + t.total);

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       backgroundColor: theme.colorScheme.surface,
//       appBar: AppBar(
//         title: const Text('Transaction Management'),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // TransactionSummaryCard now takes `Transaction` objects for calculation
//           TransactionSummaryCard(
//             totalSales: totalSales,
//             totalExpenses: totalExpenses,
//           ),
//           TransactionFilters(
//             searchQuery: searchQuery,
//             filterType: filterType,
//             onSearchChanged: (value) {
//               searchQuery = value;
//               applyFilters(); // Trigger filter re-application on search change
//             },
//             onFilterChanged: (value) {
//               if (value != null) {
//                 filterType = value;
//                 applyFilters(); // Trigger filter re-application on filter change
//               }
//             },
//           ),
//           // Use StreamBuilder to react to changes in transactions
//           Expanded(
//             // child: StreamBuilder<List<Transaction>>(
//             //   stream: _transactionsStream, // Listen to the stream
//             //   builder: (context, snapshot) {
//             //     if (snapshot.connectionState == ConnectionState.waiting) {
//             //       return const Center(child: Text("Loading transactions..."));
//             //     }
//             //     if (snapshot.hasError) {
//             //       return Center(child: Text('Error: ${snapshot.error}'));
//             //     }
//             //     // No data yet, or an empty box
//             //     if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             //       return const EmptyTransactionState();
//             //     }

//             //     // If data exists, it's already filtered in `filteredTransactions`
//             //     // because `applyFilters` is called on stream updates.
//             //     return TransactionList(transactions: filteredTransactions);
//             //   },
//             // ),
//             child: TransactionList(transactions: filteredTransactions),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ignore_for_file: use_build_context_synchronously

import 'dart:io'; // For saving the file
import 'dart:typed_data'; // For Uint8List

import 'package:countly/models/transaction.dart';
import 'package:countly/services/hive_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' show Printing;

class TransactionManagementPage extends StatefulWidget {
  const TransactionManagementPage({super.key});

  @override
  State<TransactionManagementPage> createState() =>
      _TransactionManagementPageState();
}

class _TransactionManagementPageState extends State<TransactionManagementPage> {
  List<Transaction> allTransactions = [];
  List<Transaction> filteredTransactions = [];

  String searchQuery = '';
  String filterType = 'All'; // 'All', 'Sale', 'Expense'

  final TransactionStorage _transactionStorage = TransactionStorage();
  late Stream<List<Transaction>> _transactionsStream;

  @override
  void initState() {
    super.initState();
    _transactionsStream = _transactionStorage.transactionsStream;

    _transactionsStream.listen((transactions) {
      setState(() {
        allTransactions = transactions;
        applyFilters(); // Re-apply filters whenever data changes
      });
    });

    // Initial load, ensuring filteredTransactions is populated
    allTransactions = _transactionStorage.getAllTransactions();
    applyFilters();
  }

  void applyFilters() {
    final currentFiltered =
        allTransactions.where((t) {
          final matchesType = filterType == 'All' || t.type == filterType;
          final matchesSearch =
              t.product.toLowerCase().contains(searchQuery.toLowerCase()) ||
              t.brand.toLowerCase().contains(searchQuery.toLowerCase());
          return matchesType && matchesSearch;
        }).toList();

    // Only update state if the list has actually changed
    // This helps prevent unnecessary rebuilds
    if (filteredTransactions.length != currentFiltered.length ||
        !_listEquals(filteredTransactions, currentFiltered)) {
      setState(() {
        filteredTransactions = currentFiltered;
      });
    }
  }

  // Helper function for shallow comparison of Transaction lists
  bool _listEquals(List<Transaction> a, List<Transaction> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        // This assumes Transaction objects have a meaningful operator== or are the same instance
        // If Transaction is a custom class, ensure operator== and hashCode are overridden
        return false;
      }
    }
    return true;
  }

  double get totalSales => filteredTransactions
      .where((t) => t.type == 'Sale')
      .fold(0.0, (sum, t) => sum + t.total);

  double get totalExpenses => filteredTransactions
      .where((t) => t.type == 'Expense')
      .fold(0.0, (sum, t) => sum + t.total);

  // Function to generate the PDF
  Future<Uint8List> _generatePdf(
    List<Transaction> transactions,
    String title,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build:
            (pw.Context context) => [
              pw.Center(
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              if (searchQuery.isNotEmpty)
                pw.Text(
                  'Search Query: "$searchQuery"',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              if (filterType != 'All')
                pw.Text(
                  'Filtered by Type: "$filterType"',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              if (searchQuery.isNotEmpty || filterType != 'All')
                pw.SizedBox(height: 10),

              if (transactions.isEmpty)
                pw.Center(
                  child: pw.Text(
                    'No transactions to display for the current filters.',
                  ),
                ),
              if (transactions.isNotEmpty)
                pw.Table.fromTextArray(
                  headers: [
                    'Date',
                    'Product',
                    'Brand',
                    'Quantity',
                    'Price',
                    'Total',
                    'Type',
                  ],
                  data:
                      transactions
                          .map(
                            (t) => [
                              '${t.timestamp.day}/${t.timestamp.month}/${t.timestamp.year}',
                              t.product,
                              t.brand,
                              t.quantity.toString(),
                              t.unitPrice.toStringAsFixed(2),
                              t.total.toStringAsFixed(2),
                              t.type,
                            ],
                          )
                          .toList(),
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  cellPadding: const pw.EdgeInsets.all(5),
                ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Sales: ${totalSales.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Total Expenses: ${totalExpenses.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Net Balance: ${(totalSales - totalExpenses).toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color:
                      (totalSales - totalExpenses) >= 0
                          ? PdfColors.green800
                          : PdfColors.red800,
                ),
              ),
            ],
      ),
    );

    return pdf.save();
  }

  // Function to handle downloading and sharing the PDF
  void _downloadTransactionsPdf() async {
    try {
      // Show a loading indicator
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generating PDF...')));

      final Uint8List pdfBytes = await _generatePdf(
        filteredTransactions,
        'Transaction Report (Filtered)',
      );

      // Get the application's temporary directory
      final output = await getTemporaryDirectory();
      final String filePath = '${output.path}/transaction_report.pdf';
      final file = File(filePath);

      // Write the PDF bytes to the file
      await file.writeAsBytes(pdfBytes);

      // Dismiss loading indicator
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show options to open or share
      // Using Printing package for a robust solution across platforms
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'transaction_report.pdf',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate PDF: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Transaction Management'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadTransactionsPdf,
            tooltip: 'Download Report',
          ),
        ],
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
              setState(() {
                searchQuery = value;
                applyFilters(); // Trigger filter re-application on search change
              });
            },
            onFilterChanged: (value) {
              if (value != null) {
                setState(() {
                  filterType = value;
                  applyFilters(); // Trigger filter re-application on filter change
                });
              }
            },
          ),
          // TransactionList now directly uses filteredTransactions
          Expanded(
            child:
                filteredTransactions.isEmpty &&
                        (searchQuery.isNotEmpty || filterType != 'All')
                    ? const Center(
                      child: Text("No transactions match your filters."),
                    )
                    : (allTransactions.isEmpty
                        ? const EmptyTransactionState() // Show empty state only if there are no transactions at all
                        : TransactionList(transactions: filteredTransactions)),
          ),
        ],
      ),
    );
  }
}

class TransactionSummaryCard extends StatelessWidget {
  final double totalSales;
  final double totalExpenses;

  const TransactionSummaryCard({
    super.key,
    required this.totalSales,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netProfit = totalSales - totalExpenses;

    return Container(
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
            color: theme.colorScheme.shadow.withAlpha(25),
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
                amount: totalSales,
                icon: Icons.trending_up,
                color: Colors.green,
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: theme.colorScheme.outline.withAlpha(
                76,
              ), // Adjusted alpha value
            ),
            Expanded(
              child: SummaryItem(
                title: 'Expenses',
                amount: totalExpenses,
                icon: Icons.trending_down,
                color: Colors.red,
              ),
            ),
            Container(
              width: 1,
              height: 60,
              color: theme.colorScheme.outline.withAlpha(
                76,
              ), // Adjusted alpha value
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
    );
  }
}

// Reusable Summary Item Component (No changes needed, already StatelessWidget)
class SummaryItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ksh ${amount.toStringAsFixed(0)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// Reusable Filters Component (No significant functional changes, updated withAlpha)
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
  // Use a TextEditingController for better control over the TextField
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant TransactionFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          color: theme.colorScheme.outline.withAlpha(
            51,
          ), // Adjusted alpha value
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(
              12,
            ), // Adjusted alpha value
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
              controller: _searchController, // Use controller
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
                    color: theme.colorScheme.outline.withAlpha(
                      76,
                    ), // Adjusted alpha value
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
                fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(
                  76,
                ), // Adjusted alpha value
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(
                76,
              ), // Adjusted alpha value
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withAlpha(
                  76,
                ), // Adjusted alpha value
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

// Reusable Transaction List Component (Now takes List<Transaction>)
class TransactionList extends StatelessWidget {
  final List<Transaction> transactions; // Changed type

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const EmptyTransactionState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return TransactionCard(
          transaction: transactions[index], // Pass Transaction object
          index:
              index, // Index still useful for potential staggered loading if re-added
        );
      },
    );
  }
}

// Reusable Transaction Card Component (Animations Removed, now takes Transaction object)
class TransactionCard extends StatelessWidget {
  final Transaction transaction; // Changed type
  final int
  index; // Kept index for potential future use or just for a reference

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSale = transaction.type == 'Sale';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha(25), // Adjusted alpha
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withAlpha(20), // Adjusted alpha
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
                color: (isSale ? Colors.green : Colors.red).withAlpha(
                  25,
                ), // Adjusted alpha
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
                    transaction.product, // Access property directly
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.brand, // Access property directly
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TransactionDetailChip(
                        label:
                            'Qty: ${transaction.quantity}', // Access property directly
                        icon: Icons.inventory_2_outlined,
                      ),
                      const SizedBox(width: 8),
                      TransactionDetailChip(
                        label: transaction.category, // Access property directly
                        icon: Icons.category_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(
                      transaction.timestamp,
                    ), // Pass DateTime object
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
                  'Ksh ${transaction.total.toStringAsFixed(0)}', // Access property directly
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSale ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@Ksh ${transaction.unitPrice.toStringAsFixed(0)}', // Access property directly
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Changed to accept DateTime object directly
  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

// Reusable Detail Chip Component (No changes needed, already StatelessWidget)
class TransactionDetailChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const TransactionDetailChip({
    super.key,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(
          76,
        ), // Adjusted alpha
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
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

// Empty State Component (No changes needed, already StatelessWidget)
class EmptyTransactionState extends StatelessWidget {
  const EmptyTransactionState({super.key});

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
            color: theme.colorScheme.onSurfaceVariant.withAlpha(
              127,
            ), // Adjusted alpha
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
