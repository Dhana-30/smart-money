import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/finance_provider.dart';

class AddTransactionModal extends StatefulWidget {
  final FinanceProvider provider;
  final QuickPreset? initialPreset;
  final TransactionModel? existingTransaction;

  const AddTransactionModal({
    super.key,
    required this.provider,
    this.initialPreset,
    this.existingTransaction,
  });

  static Future<void> show(
    BuildContext context,
    FinanceProvider provider, {
    QuickPreset? preset,
    TransactionModel? existingTransaction,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddTransactionModal(
        provider: provider,
        initialPreset: preset,
        existingTransaction: existingTransaction,
      ),
    );
  }

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  late TransactionType _type;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _selectedCategoryId;
  late DateTime _selectedDate;
  String _selectedPaymentMethod = 'UPI / Online';

  final List<String> _paymentMethods = [
    'UPI / Online',
    'Cash',
    'Credit / Debit Card',
    'Bank Transfer',
  ];

  bool get _isEditing => widget.existingTransaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final tx = widget.existingTransaction!;
      _type = tx.type;
      final amtStr = tx.amount.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
      _amountController = TextEditingController(text: amtStr);
      _noteController = TextEditingController(text: tx.note);
      _selectedCategoryId = tx.categoryId;
      _selectedDate = tx.date;
      _selectedPaymentMethod = tx.paymentMethod ?? 'UPI / Online';
    } else {
      _type = TransactionType.expense;
      _amountController = TextEditingController(
        text: widget.initialPreset != null
            ? widget.initialPreset!.amount.toStringAsFixed(0)
            : '',
      );
      _noteController = TextEditingController(
        text: widget.initialPreset != null ? widget.initialPreset!.name : '',
      );
      _selectedCategoryId = widget.initialPreset?.categoryId ??
          AppCategories.expenseCategories.first.id;
      _selectedDate = widget.provider.selectedDate;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onSave() {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_isEditing) {
      final updatedTx = TransactionModel(
        id: widget.existingTransaction!.id,
        type: _type,
        categoryId: _selectedCategoryId,
        amount: amount,
        date: _selectedDate,
        note: _noteController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
      );
      widget.provider.updateTransaction(updatedTx);
    } else {
      final newTx = TransactionModel(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: _type,
        categoryId: _selectedCategoryId,
        amount: amount,
        date: _selectedDate,
        note: _noteController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
      );
      widget.provider.addTransaction(newTx);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = _type == TransactionType.expense
        ? AppCategories.expenseCategories
        : AppCategories.incomeCategories;

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomPadding + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isEditing ? 'Edit Transaction' : 'Add Transaction',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Segmented Type Button
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward, color: Colors.red),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward, color: Colors.green),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (set) {
                setState(() {
                  _type = set.first;
                  _selectedCategoryId = (_type == TransactionType.expense
                          ? AppCategories.expenseCategories
                          : AppCategories.incomeCategories)
                      .first
                      .id;
                });
              },
            ),
            const SizedBox(height: 16),

            // Amount Input
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                labelText: 'Amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Picker Title
            Text(
              'Select Category',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),

            // Category Grid
            SizedBox(
              height: 110,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat.id == _selectedCategoryId;

                  return InkWell(
                    onTap: () => setState(() => _selectedCategoryId = cat.id),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cat.color.withOpacity(0.2)
                            : theme.colorScheme.surfaceVariant.withOpacity(0.4),
                        border: Border.all(
                          color: isSelected ? cat.color : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat.icon, color: cat.color, size: 26),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Date Picker Row
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(
                DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
            const Divider(),

            // Payment Method Dropdown
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _paymentMethods.map((m) {
                return DropdownMenuItem(value: m, child: Text(m));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedPaymentMethod = val);
              },
            ),
            const SizedBox(height: 12),

            // Note Input
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note / Description (Optional)',
                hintText: 'e.g. Lunch with team',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons: Back & Submit
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _onSave,
                    icon: Icon(_isEditing ? Icons.check_circle_outline : Icons.check),
                    label: Text(
                      _isEditing ? 'Update' : 'Save',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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
