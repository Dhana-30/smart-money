import 'dart:math';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class DonutChartWidget extends StatelessWidget {
  final Map<String, double> categoryData;
  final double total;

  const DonutChartWidget({
    super.key,
    required this.categoryData,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (total <= 0 || categoryData.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text(
          'No expense data for this month',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: CustomPaint(
            painter: _DonutChartPainter(
              categoryData: categoryData,
              total: total,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        ...categoryData.entries.map((entry) {
          final cat = AppCategories.getCategory(TransactionType.expense, entry.key);
          final pct = ((entry.value / total) * 100).toStringAsFixed(1);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: cat.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(cat.icon, size: 16, color: cat.color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    cat.name,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                ),
                Text(
                  '₹${entry.value.toStringAsFixed(0)} ($pct%)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final Map<String, double> categoryData;
  final double total;

  _DonutChartPainter({
    required this.categoryData,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 26.0;

    double startAngle = -pi / 2;

    for (final entry in categoryData.entries) {
      final cat = AppCategories.getCategory(TransactionType.expense, entry.key);
      final sweepAngle = (entry.value / total) * 2 * pi;

      final paint = Paint()
        ..color = cat.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.total != total || oldDelegate.categoryData != categoryData;
  }
}

class DailyBarChartWidget extends StatelessWidget {
  final Map<int, double> dailyData;
  final int daysInMonth;

  const DailyBarChartWidget({
    super.key,
    required this.dailyData,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double maxVal = 0.0;
    for (int i = 1; i <= daysInMonth; i++) {
      final v = dailyData[i] ?? 0.0;
      if (v > maxVal) maxVal = v;
    }
    if (maxVal <= 0) maxVal = 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(daysInMonth, (index) {
              final day = index + 1;
              final val = dailyData[day] ?? 0.0;
              final heightRatio = (val / maxVal).clamp(0.04, 1.0);

              return Expanded(
                child: Tooltip(
                  message: 'Day $day: ₹${val.toStringAsFixed(0)}',
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 90 * heightRatio,
                          decoration: BoxDecoration(
                            color: val > 0
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (day == 1 || day % 5 == 0 || day == daysInMonth)
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 9,
                              color: theme.colorScheme.outline,
                            ),
                          )
                        else
                          const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
