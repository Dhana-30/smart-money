import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/transaction_model.dart';
import '../models/habit_badge.dart';
import '../services/storage_service.dart';
import '../services/alarm_service.dart';

class FinanceProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  double _monthlyBudget = 30000.0;
  double _startingMonthlyIncome = 50000.0;
  double _targetSavings = 15000.0;
  String _reportPhoneNumber = '+91 9876543210';
  bool _isEodSummaryEnabled = true;
  TimeOfDay _eodSummaryTime = const TimeOfDay(hour: 21, minute: 30);
  bool _isDarkMode = false;
  bool _isAlarmEnabled = true;
  bool _isSmsDetectionEnabled = true;
  TimeOfDay _alarmTime = const TimeOfDay(hour: 21, minute: 0);

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = true;

  List<TransactionModel> get transactions => _transactions;
  double get monthlyBudget => _monthlyBudget;
  double get startingMonthlyIncome => _startingMonthlyIncome;
  double get targetSavings => _targetSavings;
  String get reportPhoneNumber => _reportPhoneNumber;
  bool get isEodSummaryEnabled => _isEodSummaryEnabled;
  TimeOfDay get eodSummaryTime => _eodSummaryTime;
  double get allocatedExpensePool => _startingMonthlyIncome - _targetSavings;
  double get remainingSpendablePool => allocatedExpensePool - monthExpense;
  bool get isDarkMode => _isDarkMode;
  bool get isAlarmEnabled => _isAlarmEnabled;
  bool get isSmsDetectionEnabled => _isSmsDetectionEnabled;
  TimeOfDay get alarmTime => _alarmTime;
  DateTime get selectedDate => _selectedDate;
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;

  int get daysRemainingInMonth {
    final now = DateTime.now();
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    return (totalDays - now.day + 1).clamp(1, 31);
  }

  double get safeDailySpend {
    if (daysRemainingInMonth <= 0) return 0.0;
    return (remainingSpendablePool / daysRemainingInMonth).clamp(0.0, double.infinity);
  }

  FinanceProvider() {
    _initData();
  }

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    _transactions = await StorageService.loadTransactions();
    _startingMonthlyIncome = await StorageService.loadStartingIncome();
    _targetSavings = await StorageService.loadTargetSavings();
    _monthlyBudget = allocatedExpensePool;
    _isDarkMode = await StorageService.loadDarkMode();
    _isSmsDetectionEnabled = await StorageService.loadSmsDetection();
    _reportPhoneNumber = await StorageService.loadReportPhoneNumber();

    final eodData = await StorageService.loadEodSummarySettings();
    _isEodSummaryEnabled = eodData['enabled'] as bool;
    _eodSummaryTime = TimeOfDay(
      hour: eodData['hour'] as int,
      minute: eodData['minute'] as int,
    );

    final alarmData = await StorageService.loadAlarmSettings();
    _isAlarmEnabled = alarmData['enabled'] as bool;
    _alarmTime = TimeOfDay(
      hour: alarmData['hour'] as int,
      minute: alarmData['minute'] as int,
    );

    await AlarmService().init();

    _isLoading = false;
    notifyListeners();
  }

  // --- Calculations ---

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalBalance => totalIncome - totalExpense;

  // Day-wise metrics
  List<TransactionModel> get dayWiseTransactions {
    final fmt = DateFormat('yyyy-MM-dd');
    final selStr = fmt.format(_selectedDate);
    return _transactions.where((t) => fmt.format(t.date) == selStr).toList();
  }

  double get dayIncome => dayWiseTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get dayExpense => dayWiseTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get dayBalance => dayIncome - dayExpense;

  // Month-wise metrics
  List<TransactionModel> get monthWiseTransactions {
    final ym = DateFormat('yyyy-MM').format(_selectedMonth);
    return _transactions
        .where((t) => DateFormat('yyyy-MM').format(t.date) == ym)
        .toList();
  }

  double get monthIncome => monthWiseTransactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthExpense => monthWiseTransactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get monthBalance => monthIncome - monthExpense;

  double get budgetProgressPercent {
    if (_monthlyBudget <= 0) return 0.0;
    return (monthExpense / _monthlyBudget).clamp(0.0, 1.0);
  }

  // Streak & Habit Calculations
  bool get hasLoggedToday {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _transactions
        .any((t) => DateFormat('yyyy-MM-dd').format(t.date) == todayStr);
  }

  int get streakCount {
    if (_transactions.isEmpty) return 0;

    final fmt = DateFormat('yyyy-MM-dd');
    final uniqueDates = _transactions
        .map((t) => fmt.format(t.date))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final todayStr = fmt.format(DateTime.now());
    final yesterdayStr =
        fmt.format(DateTime.now().subtract(const Duration(days: 1)));

    if (!uniqueDates.contains(todayStr) &&
        !uniqueDates.contains(yesterdayStr)) {
      return 0;
    }

    int count = 0;
    DateTime checkDate = uniqueDates.contains(todayStr)
        ? DateTime.now()
        : DateTime.now().subtract(const Duration(days: 1));

    while (true) {
      final dateStr = fmt.format(checkDate);
      if (uniqueDates.contains(dateStr)) {
        count++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return count;
  }

  List<HabitBadge> get badges => HabitBadge.getBadges(
        streakDays: streakCount,
        totalTransactions: _transactions.length,
        underBudget: monthExpense <= _monthlyBudget,
      );

  Map<String, double> get categoryExpenses {
    final map = <String, double>{};
    for (final t in monthWiseTransactions) {
      if (t.type == TransactionType.expense) {
        map[t.categoryId] = (map[t.categoryId] ?? 0.0) + t.amount;
      }
    }
    return map;
  }

  Map<int, double> get dailyExpensesInMonth {
    final map = <int, double>{};
    for (final t in monthWiseTransactions) {
      if (t.type == TransactionType.expense) {
        final day = t.date.day;
        map[day] = (map[day] ?? 0.0) + t.amount;
      }
    }
    return map;
  }

  // --- Mutations & Actions ---

  Future<void> addTransaction(TransactionModel item) async {
    _transactions.insert(0, item);
    await StorageService.saveTransactions(_transactions);
    AlarmService().playChimeSound();
    notifyListeners();
  }

  Future<void> updateTransaction(TransactionModel updatedItem) async {
    final index = _transactions.indexWhere((t) => t.id == updatedItem.id);
    if (index != -1) {
      _transactions[index] = updatedItem;
      await StorageService.saveTransactions(_transactions);
      AlarmService().playChimeSound();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await StorageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> setIncomeAllocation({
    required double income,
    required double savings,
  }) async {
    _startingMonthlyIncome = income;
    _targetSavings = savings;
    _monthlyBudget = allocatedExpensePool;
    await StorageService.saveStartingIncome(income);
    await StorageService.saveTargetSavings(savings);
    notifyListeners();
  }

  Future<void> setEodSummarySettings({
    required bool enabled,
    required TimeOfDay time,
  }) async {
    _isEodSummaryEnabled = enabled;
    _eodSummaryTime = time;
    await StorageService.saveEodSummarySettings(
      enabled: enabled,
      hour: time.hour,
      minute: time.minute,
    );
    notifyListeners();
  }

  Future<void> setReportPhoneNumber(String phone) async {
    _reportPhoneNumber = phone;
    await StorageService.saveReportPhoneNumber(phone);
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }

  Future<void> setMonthlyBudget(double budget) async {
    _monthlyBudget = budget;
    await StorageService.saveMonthlyBudget(budget);
    notifyListeners();
  }

  Future<void> setAlarmSettings({
    required bool enabled,
    required TimeOfDay time,
  }) async {
    _isAlarmEnabled = enabled;
    _alarmTime = time;
    await StorageService.saveAlarmSettings(
      enabled: enabled,
      hour: time.hour,
      minute: time.minute,
    );

    if (enabled) {
      await AlarmService().scheduleDailyAlarm(
        hour: time.hour,
        minute: time.minute,
      );
    } else {
      await AlarmService().cancelAlarm();
    }

    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await StorageService.saveDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setSmsDetectionEnabled(bool enabled) async {
    _isSmsDetectionEnabled = enabled;
    await StorageService.saveSmsDetection(enabled);
    notifyListeners();
  }

  Future<void> loadDemoData() async {
    final now = DateTime.now();
    _transactions = [
      TransactionModel(
        id: 'd1',
        type: TransactionType.income,
        categoryId: 'salary',
        amount: 50000,
        date: now,
        note: 'Monthly salary credit',
      ),
      TransactionModel(
        id: 'd2',
        type: TransactionType.expense,
        categoryId: 'food',
        amount: 250,
        date: now,
        note: 'Lunch at cafe',
      ),
      TransactionModel(
        id: 'd3',
        type: TransactionType.expense,
        categoryId: 'transport',
        amount: 120,
        date: now,
        note: 'Metro & auto fare',
      ),
      TransactionModel(
        id: 'd4',
        type: TransactionType.expense,
        categoryId: 'groceries',
        amount: 1400,
        date: now.subtract(const Duration(days: 1)),
        note: 'Weekly provisions & dairy',
      ),
      TransactionModel(
        id: 'd5',
        type: TransactionType.expense,
        categoryId: 'bills',
        amount: 1850,
        date: now.subtract(const Duration(days: 2)),
        note: 'Electricity bill',
      ),
      TransactionModel(
        id: 'd6',
        type: TransactionType.income,
        categoryId: 'freelance',
        amount: 12000,
        date: now.subtract(const Duration(days: 3)),
        note: 'Flutter UI App Project',
      ),
      TransactionModel(
        id: 'd7',
        type: TransactionType.expense,
        categoryId: 'shopping',
        amount: 2200,
        date: now.subtract(const Duration(days: 4)),
        note: 'Sneakers & tee',
      ),
    ];

    await StorageService.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _transactions.clear();
    await StorageService.saveTransactions(_transactions);
    notifyListeners();
  }

  String generateCsv() {
    final buffer = StringBuffer();
    buffer.writeln('ID,Date,Type,Category,Amount,PaymentMethod,Note');
    for (final t in _transactions) {
      final cat = AppCategories.getCategory(t.type, t.categoryId);
      final noteClean = t.note.replaceAll('"', '""');
      buffer.writeln(
        '"${t.id}","${DateFormat('yyyy-MM-dd').format(t.date)}","${t.type.name}","${cat.name}",${t.amount},"${t.paymentMethod}","$noteClean"',
      );
    }
    return buffer.toString();
  }

  Future<void> sendMonthlyCsvToPhone(BuildContext context) async {
    try {
      final csvContent = generateCsv();
      final tempDir = await getTemporaryDirectory();
      final monthStr = DateFormat('yyyy_MM').format(_selectedMonth);
      final file = File('${tempDir.path}/monthly_expenses_$monthStr.csv');
      await file.writeAsString(csvContent);

      final cleanPhone = _reportPhoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      final summary = '📊 *SmartMoney Monthly Expenses Report ($monthStr)*\n'
          '• Total Income: ₹${totalIncome.toStringAsFixed(2)}\n'
          '• Total Expense: ₹${monthExpense.toStringAsFixed(2)}\n'
          '• Remaining Spendable Pool: ₹${remainingSpendablePool.toStringAsFixed(2)}\n'
          'Designated Phone: $cleanPhone\n'
          'Attached is your complete itemized CSV statement.';

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        text: summary,
        subject: 'Monthly Expenses CSV Report - $monthStr',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share CSV: $e')),
        );
      }
    }
  }
}
