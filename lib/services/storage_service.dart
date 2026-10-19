import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class StorageService {
  static const String _keyTransactions = 'sm_transactions';
  static const String _keyBudget = 'sm_monthly_budget';
  static const String _keyAlarmEnabled = 'sm_alarm_enabled';
  static const String _keyAlarmHour = 'sm_alarm_hour';
  static const String _keyAlarmMinute = 'sm_alarm_minute';
  static const String _keyDarkMode = 'sm_dark_mode';

  static Future<List<TransactionModel>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyTransactions);
    if (jsonStr == null || jsonStr.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((item) => TransactionModel.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveTransactions(List<TransactionModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((i) => i.toJson()).toList();
    await prefs.setString(_keyTransactions, jsonEncode(list));
  }

  static Future<double> loadMonthlyBudget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyBudget) ?? 30000.0;
  }

  static Future<void> saveMonthlyBudget(double budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBudget, budget);
  }

  static Future<Map<String, dynamic>> loadAlarmSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_keyAlarmEnabled) ?? true,
      'hour': prefs.getInt(_keyAlarmHour) ?? 21,
      'minute': prefs.getInt(_keyAlarmMinute) ?? 0,
    };
  }

  static Future<void> saveAlarmSettings({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAlarmEnabled, enabled);
    await prefs.setInt(_keyAlarmHour, hour);
    await prefs.setInt(_keyAlarmMinute, minute);
  }

  static const String _keySmsDetection = 'sm_sms_detection';

  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }

  static Future<bool> loadSmsDetection() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySmsDetection) ?? true;
  }

  static Future<void> saveSmsDetection(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySmsDetection, enabled);
  }

  static const String _keyStartingIncome = 'sm_starting_income';
  static const String _keyTargetSavings = 'sm_target_savings';
  static const String _keyEodEnabled = 'sm_eod_enabled';
  static const String _keyEodHour = 'sm_eod_hour';
  static const String _keyEodMinute = 'sm_eod_minute';
  static const String _keyReportPhone = 'sm_report_phone';

  static Future<double> loadStartingIncome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyStartingIncome) ?? 50000.0;
  }

  static Future<void> saveStartingIncome(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyStartingIncome, val);
  }

  static Future<double> loadTargetSavings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyTargetSavings) ?? 15000.0;
  }

  static Future<void> saveTargetSavings(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTargetSavings, val);
  }

  static Future<Map<String, dynamic>> loadEodSummarySettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_keyEodEnabled) ?? true,
      'hour': prefs.getInt(_keyEodHour) ?? 21,
      'minute': prefs.getInt(_keyEodMinute) ?? 30,
    };
  }

  static Future<void> saveEodSummarySettings({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEodEnabled, enabled);
    await prefs.setInt(_keyEodHour, hour);
    await prefs.setInt(_keyEodMinute, minute);
  }

  static Future<String> loadReportPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyReportPhone) ?? '+91 9876543210';
  }

  static Future<void> saveReportPhoneNumber(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyReportPhone, phone);
  }
}
