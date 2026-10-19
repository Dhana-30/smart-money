import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/finance_provider.dart';
import '../widgets/custom_charts.dart';

class AnalyticsTab extends StatelessWidget {
  final FinanceProvider provider;

  const AnalyticsTab({super.key, required this.provider});

  Future<void> _exportCsv(BuildContext context) async {
    try {
      final csvData = provider.generateCsv();
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/smart_money_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
      );
      await file.writeAsString(csvData);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'SmartMoney Transaction Export',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV Export created (Sharing not supported in current environment: $e)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = DateFormat('MMMM yyyy').format(provider.selectedMonth);
    final daysInMonth = DateTime(
      provider.selectedMonth.year,
      provider.selectedMonth.month + 1,
      0,
    ).day;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Analytics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                monthName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. Donut Chart Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Category Breakdown',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '₹${provider.monthExpense.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DonutChartWidget(
                    categoryData: provider.categoryExpenses,
                    total: provider.monthExpense,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Daily Bar Chart Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Expense Trend',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DailyBarChartWidget(
                    dailyData: provider.dailyExpensesInMonth,
                    daysInMonth: daysInMonth,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Export Section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                child: Icon(Icons.table_chart, color: theme.colorScheme.primary),
              ),
              title: const Text(
                'Export to CSV',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Compatible with Excel and Google Sheets'),
              trailing: ElevatedButton(
                onPressed: () => _exportCsv(context),
                child: const Text('Export'),
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
