import 'package:flutter/material.dart';

class HabitBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  const HabitBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });

  static List<HabitBadge> getBadges({
    required int streakDays,
    required int totalTransactions,
    required bool underBudget,
  }) {
    return [
      HabitBadge(
        id: 'first_step',
        title: 'First Step',
        description: 'Record your very first transaction',
        icon: Icons.eco,
        color: const Color(0xFF10B981),
        isUnlocked: totalTransactions >= 1,
      ),
      HabitBadge(
        id: 'streak_3',
        title: '3-Day Fire',
        description: 'Maintain a 3-day logging streak',
        icon: Icons.local_fire_department,
        color: const Color(0xFFF97316),
        isUnlocked: streakDays >= 3,
      ),
      HabitBadge(
        id: 'streak_7',
        title: '7-Day Habit',
        description: 'A full week of consistent tracking',
        icon: Icons.bolt,
        color: const Color(0xFFF59E0B),
        isUnlocked: streakDays >= 7,
      ),
      HabitBadge(
        id: 'master_15',
        title: 'Pro Tracker',
        description: 'Log 15 or more transactions',
        icon: Icons.military_tech,
        color: const Color(0xFF8B5CF6),
        isUnlocked: totalTransactions >= 15,
      ),
      HabitBadge(
        id: 'budget_keeper',
        title: 'Budget Master',
        description: 'Stay within your monthly spending limit',
        icon: Icons.verified,
        color: const Color(0xFF3B82F6),
        isUnlocked: underBudget && totalTransactions >= 5,
      ),
    ];
  }
}
