import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../providers/finance_provider.dart';
import '../services/sms_parser_service.dart';

class PaymentDetectionDialog extends StatefulWidget {
  final ParsedPaymentMessage parsed;
  final FinanceProvider provider;

  const PaymentDetectionDialog({
    super.key,
    required this.parsed,
    required this.provider,
  });

  static Future<void> show(
    BuildContext context,
    FinanceProvider provider,
    ParsedPaymentMessage parsed,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PaymentDetectionDialog(
        parsed: parsed,
        provider: provider,
      ),
    );
  }

  @override
  State<PaymentDetectionDialog> createState() => _PaymentDetectionDialogState();
}

class _PaymentDetectionDialogState extends State<PaymentDetectionDialog> {
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.parsed.suggestedCategory;
  }

  void _onConfirm(TransactionType type) {
    final newTx = TransactionModel(
      id: 'tx_sms_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      categoryId: _selectedCategoryId,
      amount: widget.parsed.amount,
      date: DateTime.now(),
      note: '${widget.parsed.merchant} (${widget.parsed.source})',
      paymentMethod: widget.parsed.source,
    );

    widget.provider.addTransaction(newTx);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ Recorded ₹${widget.parsed.amount.toStringAsFixed(0)} as ${type == TransactionType.expense ? "Debited (Expense)" : "Credited (Income)"}!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parsed = widget.parsed;
    final isCredit = parsed.defaultType == 'income';

    final allCategories = [
      ...AppCategories.expenseCategories,
      ...AppCategories.incomeCategories,
    ];

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.payment, size: 28, color: Colors.blue),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Payment Detected',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        parsed.source,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isCredit
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isCredit ? 'Likely Credited' : 'Likely Debited',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isCredit ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${parsed.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'At / Ref: ${parsed.merchant}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: allCategories.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Row(
                    children: [
                      Icon(c.icon, size: 18, color: c.color),
                      const SizedBox(width: 8),
                      Text(c.name, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategoryId = val);
              },
            ),
            const SizedBox(height: 14),

            const Text(
              'How should this amount be recorded?',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Back'),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () => _onConfirm(TransactionType.expense),
              child: const Text('- Debited'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () => _onConfirm(TransactionType.income),
              child: const Text('+ Credited'),
            ),
          ],
        ),
      ],
    );
  }
}
