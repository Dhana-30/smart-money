import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/finance_provider.dart';

class MonthlyTab extends StatelessWidget {
  final FinanceProvider provider;
  final VoidCallback onSelectDay;

  const MonthlyTab({
    super.key,
    required this.provider,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthYearStr = DateFormat('MMMM yyyy').format(provider.selectedMonth);

    final monthTx = provider.monthWiseTransactions;
    final dailyMap = <int, List<TransactionModel>>{};
    for (final t in monthTx) {
      dailyMap.putIfAbsent(t.date.day, () => []).add(t);
    }

    final year = provider.selectedMonth.year;
    final month = provider.selectedMonth.month;
    final firstDayWeekday = DateTime(year, month, 1).weekday % 7; // Sunday = 0
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // 1. Month Navigator
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      provider.setSelectedMonth(
                        DateTime(year, month - 1, 1),
                      );
                    },
                  ),
                  Column(
                    children: [
                      Text(
                        monthYearStr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Tap a date to inspect day logs',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      provider.setSelectedMonth(
                        DateTime(year, month + 1, 1),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Month Summary Balance
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MONTHLY NET SAVINGS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${provider.monthBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Income',
                              style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Text(
                            '+₹${provider.monthIncome.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFA7F3D0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Expense',
                              style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Text(
                            '-₹${provider.monthExpense.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFFECACA),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Calendar Grid Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  // Weekday Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map((day) => Expanded(
                              child: Text(
                                day,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 10),

                  // Calendar Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: firstDayWeekday + daysInMonth,
                    itemBuilder: (context, index) {
                      if (index < firstDayWeekday) {
                        return const SizedBox.shrink();
                      }

                      final dayNum = index - firstDayWeekday + 1;
                      final dayDate = DateTime(year, month, dayNum);
                      final isSelected = DateFormat('yyyy-MM-dd')
                              .format(provider.selectedDate) ==
                          DateFormat('yyyy-MM-dd').format(dayDate);

                      final isToday = DateFormat('yyyy-MM-dd')
                              .format(DateTime.now()) ==
                          DateFormat('yyyy-MM-dd').format(dayDate);

                      final list = dailyMap[dayNum] ?? [];
                      final hasExp =
                          list.any((t) => t.type == TransactionType.expense);
                      final hasInc =
                          list.any((t) => t.type == TransactionType.income);

                      return InkWell(
                        onTap: () {
                          provider.setSelectedDate(dayDate);
                          onSelectDay();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.18)
                                : theme.colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isToday
                                  ? theme.colorScheme.primary
                                  : isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                              width: isToday ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayNum',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isToday || isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (hasExp)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  if (hasInc)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 1),
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
