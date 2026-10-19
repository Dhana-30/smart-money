import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/finance_provider.dart';
import '../widgets/add_transaction_modal.dart';
import '../widgets/end_of_day_summary_dialog.dart';

class DashboardTab extends StatelessWidget {
  final FinanceProvider provider;
  final VoidCallback onNavigateToDaily;

  const DashboardTab({
    super.key,
    required this.provider,
    required this.onNavigateToDaily,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final recentTx = provider.transactions.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Habit Streak Banner
          _buildStreakBanner(context),
          const SizedBox(height: 12),

          // 2. Alarm Status Pill
          _buildAlarmReminderPill(context),
          const SizedBox(height: 14),

          // 3. Month Starting Income & Locked Savings Allocation Card
          _buildIncomeSavingsAllocationCard(context, currencyFormat),
          const SizedBox(height: 14),

          // 4. Quick Actions: End-of-Day Summary & Send CSV Report
          _buildQuickActionButtons(context),
          const SizedBox(height: 14),

          // 5. Total Balance Card
          _buildBalanceCard(context, currencyFormat),
          const SizedBox(height: 14),

          // 6. Monthly Budget Progress Card
          _buildBudgetCard(context, currencyFormat),
          const SizedBox(height: 20),

          // 7. Quick 1-Tap Presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '⚡ Quick 1-Tap Presets',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => AddTransactionModal.show(context, provider),
                child: const Text('+ Custom'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPresetsList(context),
          const SizedBox(height: 20),

          // 8. Recent Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onNavigateToDaily,
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentTx.isEmpty)
            _buildEmptyState(context)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentTx.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _buildTransactionTile(ctx, recentTx[i]),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildStreakBanner(BuildContext context) {
    final streak = provider.streakCount;
    final loggedToday = provider.hasLoggedToday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak Day Streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  loggedToday
                      ? 'Streak safe! You logged today.'
                      : 'Log today to keep your streak burning!',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => AddTransactionModal.show(context, provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red[800],
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('+ Log Now', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmReminderPill(BuildContext context) {
    final theme = Theme.of(context);
    final isLogged = provider.hasLoggedToday;
    final timeStr = provider.alarmTime.format(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLogged ? Colors.green : Colors.amber,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.alarm,
                size: 18,
                color: isLogged ? Colors.green : Colors.amber[800],
              ),
              const SizedBox(width: 8),
              Text(
                provider.isAlarmEnabled
                    ? 'Daily Reminder set for $timeStr'
                    : 'Alarm is disabled',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Text(
            isLogged ? '✓ Logged Today' : '⏳ Pending',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isLogged ? Colors.green : Colors.amber[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeSavingsAllocationCard(BuildContext context, NumberFormat fmt) {
    final theme = Theme.of(context);
    final income = provider.startingMonthlyIncome;
    final savings = provider.targetSavings;
    final allocatedPool = provider.allocatedExpensePool;
    final remainingPool = provider.remainingSpendablePool;
    final safeDaily = provider.safeDailySpend;
    final daysLeft = provider.daysRemainingInMonth;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.blue.withOpacity(0.3), width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.06),
              Colors.indigo.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Income & Savings Allocation',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _showIncomeAllocationModal(context),
                  icon: const Icon(Icons.tune, size: 16),
                  label: const Text('Adjust', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Top Row: Income vs Locked Savings
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Month Income', style: TextStyle(fontSize: 11, color: theme.colorScheme.outline)),
                        const SizedBox(height: 2),
                        Text(fmt.format(income), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Locked Savings', style: TextStyle(fontSize: 11, color: Colors.amber)),
                            const SizedBox(width: 4),
                            Icon(Icons.lock, size: 12, color: Colors.amber[800]),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(fmt.format(savings), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber[800])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle: Spendable Expense Pool
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spendable Expense Pool',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Income (${fmt.format(income)}) - Savings (${fmt.format(savings)})',
                        style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                  Text(
                    fmt.format(allocatedPool),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Bottom highlight: Remaining Spendable Balance & Safe Daily Limit
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: remainingPool >= 0
                    ? Colors.green.withOpacity(0.12)
                    : Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    remainingPool >= 0 ? Icons.check_circle : Icons.warning_amber,
                    color: remainingPool >= 0 ? Colors.green : Colors.red,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remaining Spendable: ${fmt.format(remainingPool)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: remainingPool >= 0 ? Colors.green[800] : Colors.red[800],
                          ),
                        ),
                        Text(
                          'Safe spend: ${fmt.format(safeDaily)}/day • $daysLeft days remaining',
                          style: TextStyle(
                            fontSize: 11,
                            color: remainingPool >= 0 ? Colors.green[900] : Colors.red[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.analytics_outlined, size: 18),
            label: const Text(
              'End-of-Day Summary',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () => EndOfDaySummaryDialog.show(context, provider),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
              foregroundColor: const Color(0xFF047857),
            ),
            icon: const Icon(Icons.share, size: 18, color: Color(0xFF10B981)),
            label: const Text(
              'Send Monthly CSV',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () => provider.sendMonthlyCsvToPhone(context),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, NumberFormat fmt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF0D9488)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL BALANCE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fmt.format(provider.totalBalance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '↓ Total Income',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      Text(
                        '+${fmt.format(provider.totalIncome)}',
                        style: const TextStyle(
                          color: Color(0xFFA7F3D0),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.white30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '↑ Total Expense',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      Text(
                        '-${fmt.format(provider.totalExpense)}',
                        style: const TextStyle(
                          color: Color(0xFFFECACA),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, NumberFormat fmt) {
    final theme = Theme.of(context);
    final pct = provider.budgetProgressPercent;
    final pctInt = (pct * 100).toInt();

    Color barColor = Colors.green;
    if (pct > 0.9) {
      barColor = Colors.red;
    } else if (pct > 0.7) {
      barColor = Colors.amber;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Expense Pool Used',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '$pctInt% Spent ${pct >= 1.0 ? '⚠️ Pool Depleted!' : ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: barColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${fmt.format(provider.monthExpense)}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                ),
                Text(
                  'Allocated Pool: ${fmt.format(provider.allocatedExpensePool)}',
                  style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsList(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppCategories.defaultPresets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final p = AppCategories.defaultPresets[i];
          return ActionChip(
            avatar: Icon(p.icon, size: 16),
            label: Text('${p.name} ₹${p.amount.toInt()}'),
            onPressed: () => AddTransactionModal.show(context, provider, preset: p),
          );
        },
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, TransactionModel t) {
    final theme = Theme.of(context);
    final cat = AppCategories.getCategory(t.type, t.categoryId);
    final isExp = t.type == TransactionType.expense;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cat.color.withOpacity(0.2),
          child: Icon(cat.icon, color: cat.color),
        ),
        title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${DateFormat('dd MMM').format(t.date)}${t.note.isNotEmpty ? ' • ${t.note}' : ''}',
          style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isExp ? '-' : '+'}₹${t.amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isExp ? Colors.red : Colors.green,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
              tooltip: 'Edit Transaction',
              onPressed: () => AddTransactionModal.show(
                context,
                provider,
                existingTransaction: t,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              tooltip: 'Delete',
              onPressed: () => provider.deleteTransaction(t.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              'No transactions yet',
              style: TextStyle(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => AddTransactionModal.show(context, provider),
              child: const Text('+ Record Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  void _showIncomeAllocationModal(BuildContext context) {
    final incomeCtrl = TextEditingController(
      text: provider.startingMonthlyIncome.toStringAsFixed(0),
    );
    final savingsCtrl = TextEditingController(
      text: provider.targetSavings.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
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
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Month Starting Allocation',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Set your month income and decide how much to lock away for savings. The remainder forms your spendable expense pool.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: incomeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Starting Monthly Income (₹)',
                prefixIcon: Icon(Icons.arrow_downward, color: Colors.green),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: savingsCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Target Locked Savings (₹)',
                prefixIcon: Icon(Icons.lock, color: Colors.amber),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Back'),
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Save Allocation'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final inc = double.tryParse(incomeCtrl.text.trim()) ?? 0;
                      final sav = double.tryParse(savingsCtrl.text.trim()) ?? 0;
                      if (sav > inc) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Target savings cannot exceed starting income!')),
                        );
                        return;
                      }
                      provider.setIncomeAllocation(income: inc, savings: sav);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Allocation updated successfully!')),
                      );
                    },
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
