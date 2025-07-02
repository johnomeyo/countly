
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _unitPriceController = TextEditingController();

  String _transactionType = 'Sale';
  bool _isLoading = false;

  void _submitTransaction() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final String category = _categoryController.text.trim();
        final String product = _productNameController.text.trim();
        final String brand = _brandController.text.trim();
        final int quantity = int.parse(_quantityController.text.trim());
        final double unitPrice = double.parse(_unitPriceController.text.trim());
        final double total = quantity * unitPrice;

        final transactionData = {
          'type': _transactionType,
          'category': category,
          'product': product,
          'brand': brand,
          'quantity': quantity,
          'unitPrice': unitPrice,
          'total': total,
          'timestamp': DateTime.now().toIso8601String(),
        };

        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        print("Transaction Data: $transactionData");

        if (mounted) {
          _showSuccessDialog();
          _resetForm();
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Error saving transaction. Please try again.');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _categoryController.clear();
    _productNameController.clear();
    _brandController.clear();
    _quantityController.clear();
    _unitPriceController.clear();
    setState(() => _transactionType = 'Sale');
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) =>
              SuccessDialog(onContinue: () => Navigator.of(context).pop()),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _productNameController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar:AppBar(
        title: Text(
          'Add Transaction',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TransactionTypeCard(
                  selectedType: _transactionType,
                  onTypeChanged: (value) {
                    setState(() => _transactionType = value);
                  },
                ),
                const SizedBox(height: 24),

                FormSection(
                  title: 'Product Details',
                  children: [
                    CustomTextFormField(
                      controller: _categoryController,
                      label: 'Product Category',
                      hint: 'e.g., Electronics, Clothing',
                      icon: Icons.category_outlined,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _productNameController,
                      label: 'Product Name',
                      hint: 'Enter product name',
                      icon: Icons.inventory_2_outlined,
                    ),
                    const SizedBox(height: 16),
                    CustomTextFormField(
                      controller: _brandController,
                      label: 'Brand',
                      hint: 'Enter brand name',
                      icon: Icons.business_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                FormSection(
                  title: 'Transaction Details',
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: _quantityController,
                            label: 'Quantity',
                            hint: '0',
                            icon: Icons.numbers,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextFormField(
                            controller: _unitPriceController,
                            label: 'Unit Price',
                            hint: '0.00',
                            icon: Icons.attach_money,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                ActionButton(
                  onPressed: _isLoading ? null : _submitTransaction,
                  isLoading: _isLoading,
                  label: 'Save Transaction',
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// Transaction Type Selection Card
class TransactionTypeCard extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const TransactionTypeCard({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
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
            Text(
              'Transaction Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TransactionTypeOption(
                    title: 'Sale',
                    subtitle: 'Record a sale',
                    icon: Icons.trending_up,
                    isSelected: selectedType == 'Sale',
                    color: Colors.green,
                    onTap: () => onTypeChanged('Sale'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TransactionTypeOption(
                    title: 'Expense',
                    subtitle: 'Record an expense',
                    icon: Icons.trending_down,
                    isSelected: selectedType == 'Expense',
                    color: Colors.red,
                    onTap: () => onTypeChanged('Expense'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Transaction Type Option
class TransactionTypeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const TransactionTypeOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Form Section Widget
class FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const FormSection({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// Custom Text Form Field
class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator:
          validator ??
          (value) => value?.isEmpty == true ? 'This field is required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

// Action Button
class ActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const ActionButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        // style: ElevatedButton.styleFrom(
        //   backgroundColor: theme.colorScheme.primary,
        //   foregroundColor: theme.colorScheme.onPrimary,
        //   elevation: 2,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        // ),
        child:
            isLoading
                ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary,
                    ),
                  ),
                )
                : Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
      ),
    );
  }
}

// Success Dialog
class SuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const SuccessDialog({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 48,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Success!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transaction saved successfully',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
