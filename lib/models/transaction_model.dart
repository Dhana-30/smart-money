import 'package:flutter/material.dart';

enum TransactionType { expense, income }

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String note;
  final String paymentMethod;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.note = '',
    this.paymentMethod = 'Online / UPI',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'categoryId': categoryId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: json['type'] == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      categoryId: json['categoryId'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? 'Online / UPI',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class QuickPreset {
  final String id;
  final String name;
  final IconData icon;
  final double amount;
  final String categoryId;

  const QuickPreset({
    required this.id,
    required this.name,
    required this.icon,
    required this.amount,
    required this.categoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'amount': amount,
      'categoryId': categoryId,
    };
  }
}

class AppCategories {
  static const List<CategoryItem> expenseCategories = [
    CategoryItem(
      id: 'food',
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Color(0xFFF97316),
    ),
    CategoryItem(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_basket,
      color: Color(0xFF10B981),
    ),
    CategoryItem(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_car,
      color: Color(0xFF3B82F6),
    ),
    CategoryItem(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFFEC4899),
    ),
    CategoryItem(
      id: 'bills',
      name: 'Bills & Utilities',
      icon: Icons.lightbulb,
      color: Color(0xFFEAB308),
    ),
    CategoryItem(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie,
      color: Color(0xFF8B5CF6),
    ),
    CategoryItem(
      id: 'health',
      name: 'Health & Medical',
      icon: Icons.medical_services,
      color: Color(0xFFEF4444),
    ),
    CategoryItem(
      id: 'education',
      name: 'Education',
      icon: Icons.school,
      color: Color(0xFF06B6D4),
    ),
    CategoryItem(
      id: 'other_exp',
      name: 'Other Expense',
      icon: Icons.category,
      color: Color(0xFF64748B),
    ),
  ];

  static const List<CategoryItem> incomeCategories = [
    CategoryItem(
      id: 'salary',
      name: 'Salary',
      icon: Icons.work,
      color: Color(0xFF10B981),
    ),
    CategoryItem(
      id: 'business',
      name: 'Business',
      icon: Icons.store,
      color: Color(0xFF3B82F6),
    ),
    CategoryItem(
      id: 'investment',
      name: 'Investments',
      icon: Icons.trending_up,
      color: Color(0xFF8B5CF6),
    ),
    CategoryItem(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.laptop_mac,
      color: Color(0xFFF59E0B),
    ),
    CategoryItem(
      id: 'gift',
      name: 'Gift / Allowance',
      icon: Icons.card_giftcard,
      color: Color(0xFFEC4899),
    ),
    CategoryItem(
      id: 'other_inc',
      name: 'Other Income',
      icon: Icons.attach_money,
      color: Color(0xFF14B8A6),
    ),
  ];

  static CategoryItem getCategory(TransactionType type, String categoryId) {
    final list = type == TransactionType.expense
        ? expenseCategories
        : incomeCategories;
    return list.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryItem(
        id: categoryId,
        name: categoryId,
        icon: Icons.label,
        color: const Color(0xFF64748B),
      ),
    );
  }

  static const List<QuickPreset> defaultPresets = [
    QuickPreset(
      id: 'p1',
      name: 'Coffee',
      icon: Icons.coffee,
      amount: 40.0,
      categoryId: 'food',
    ),
    QuickPreset(
      id: 'p2',
      name: 'Lunch',
      icon: Icons.fastfood,
      amount: 150.0,
      categoryId: 'food',
    ),
    QuickPreset(
      id: 'p3',
      name: 'Auto / Cab',
      icon: Icons.local_taxi,
      amount: 100.0,
      categoryId: 'transport',
    ),
    QuickPreset(
      id: 'p4',
      name: 'Groceries',
      icon: Icons.shopping_cart,
      amount: 350.0,
      categoryId: 'groceries',
    ),
    QuickPreset(
      id: 'p5',
      name: 'Snacks',
      icon: Icons.bakery_dining,
      amount: 60.0,
      categoryId: 'food',
    ),
  ];
}
