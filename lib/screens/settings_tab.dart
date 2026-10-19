import 'package:flutter/material.dart';
import '../providers/finance_provider.dart';
import '../services/alarm_service.dart';
import '../widgets/end_of_day_summary_dialog.dart';

class SettingsTab extends StatefulWidget {
  final FinanceProvider provider;

  const SettingsTab({super.key, required this.provider});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  late TextEditingController _incomeController;
  late TextEditingController _savingsController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _incomeController = TextEditingController(
      text: widget.provider.startingMonthlyIncome.toStringAsFixed(0),
    );
    _savingsController = TextEditingController(
      text: widget.provider.targetSavings.toStringAsFixed(0),
    );
    _phoneController = TextEditingController(
      text: widget.provider.reportPhoneNumber,
    );
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _savingsController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = widget.provider;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Month Starting Income & Savings Allocation Card
          Text(
            'Month Starting Income & Savings Allocation',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Decide your starting income and locked savings. Remaining amount becomes your spendable pool for debits & credits.',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Card(
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
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _incomeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Monthly Income',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _savingsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Locked Savings',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Spendable Expense Pool:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '₹${provider.allocatedExpensePool.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Save Income & Savings Target'),
                      onPressed: () {
                        final inc = double.tryParse(_incomeController.text.trim()) ?? 0;
                        final sav = double.tryParse(_savingsController.text.trim()) ?? 0;
                        if (sav > inc) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Savings cannot exceed income!')),
                          );
                          return;
                        }
                        provider.setIncomeAllocation(income: inc, savings: sav);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Income & Savings updated!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. End-of-Day Summary Settings
          Text(
            'End-of-Day Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Displays your daily expenses and remaining spendable balance at your chosen time.',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.schedule, color: Colors.blue),
                  title: const Text('Daily End-of-Day Popup'),
                  subtitle: const Text('Show day-wise total and remaining balance'),
                  value: provider.isEodSummaryEnabled,
                  onChanged: (val) {
                    provider.setEodSummarySettings(
                      enabled: val,
                      time: provider.eodSummaryTime,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.alarm),
                  title: const Text('Summary Time'),
                  subtitle: Text(provider.eodSummaryTime.format(context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: provider.eodSummaryTime,
                    );
                    if (picked != null) {
                      provider.setEodSummarySettings(
                        enabled: provider.isEodSummaryEnabled,
                        time: picked,
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('Preview Summary Dialog'),
                  subtitle: const Text('Test how the End-of-Day popup appears'),
                  trailing: ElevatedButton(
                    onPressed: () => EndOfDaySummaryDialog.show(context, provider),
                    child: const Text('Preview Now'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Monthly CSV Report to Phone
          Text(
            'Monthly CSV Report to Phone',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Exports month-end itemized expenses as CSV directly to your specified phone number.',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 8),
          Card(
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
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Report Phone Number',
                            prefixIcon: Icon(Icons.phone_android),
                            hintText: '+91 9876543210',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final phone = _phoneController.text.trim();
                          if (phone.isNotEmpty) {
                            provider.setReportPhoneNumber(phone);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Phone number saved!')),
                            );
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Send Monthly CSV Report Now'),
                      onPressed: () => provider.sendMonthlyCsvToPhone(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 4. Daily Alarm & Consistency Section
          Text(
            'Consistency & Daily Alarm',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active),
                  title: const Text('Daily Log Reminder'),
                  subtitle: const Text('Alarm & notification to record expenses'),
                  value: provider.isAlarmEnabled,
                  onChanged: (val) {
                    provider.setAlarmSettings(
                      enabled: val,
                      time: provider.alarmTime,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Alarm Time'),
                  subtitle: Text(provider.alarmTime.format(context)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: provider.alarmTime,
                    );
                    if (picked != null) {
                      provider.setAlarmSettings(
                        enabled: provider.isAlarmEnabled,
                        time: picked,
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.volume_up),
                  title: const Text('Preview Chime Sound'),
                  subtitle: const Text('Test the notification sound now'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      AlarmService().playChimeSound();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔔 Alarm chime playing!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: const Text('Test Sound'),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.mark_email_unread_outlined),
                  title: const Text('Auto-Detect Payment Messages'),
                  subtitle: const Text('Zero-paste background SMS listener for GPay, PhonePe & Banks'),
                  value: provider.isSmsDetectionEnabled,
                  onChanged: (val) {
                    provider.setSmsDetectionEnabled(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. Habit Badges Section
          Text(
            'Habit Badges 🏆',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.1,
            ),
            itemCount: provider.badges.length,
            itemBuilder: (context, index) {
              final badge = provider.badges[index];
              final unlocked = badge.isUnlocked;

              return Card(
                elevation: 0,
                color: unlocked
                    ? badge.color.withOpacity(0.12)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: unlocked ? badge.color : theme.colorScheme.outlineVariant,
                    width: unlocked ? 1.5 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: unlocked ? badge.color : Colors.grey,
                        child: Icon(badge.icon, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              badge.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: unlocked ? badge.color : Colors.grey,
                              ),
                            ),
                            Text(
                              unlocked ? 'Unlocked ✓' : 'Locked 🔒',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // 6. App & Data Management Section
          Text(
            'App & Data',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  value: provider.isDarkMode,
                  onChanged: (val) => provider.toggleDarkMode(),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.auto_fix_high),
                  title: const Text('Load Demo Transactions'),
                  subtitle: const Text('Fills sample data to test charts, savings & streaks'),
                  trailing: OutlinedButton(
                    onPressed: () {
                      provider.loadDemoData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demo transactions loaded!')),
                      );
                    },
                    child: const Text('Load Demo'),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Reset All Data', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Erase all entries and streak history'),
                  trailing: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Reset All Data?'),
                          content: const Text(
                              'This will permanently delete all your logged transactions and reset your streak.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        provider.clearAllData();
                      }
                    },
                    child: const Text('Reset'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
