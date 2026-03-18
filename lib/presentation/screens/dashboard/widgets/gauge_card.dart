import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Circular gauge card for Speed and RPM.
class GaugeCard extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double maxValue;
  final double warningThreshold;
  final double dangerThreshold;
  final IconData icon;

  /// If set, divide value by [divisor] and prefix unit with [unitPrefix]
  /// e.g. RPM: value=3000, divisor=1000, unitPrefix='k' → "3.0 krpm"
  final double? divisor;
  final String? unitPrefix;

  const GaugeCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.maxValue,
    required this.warningThreshold,
    required this.dangerThreshold,
    required this.icon,
    this.divisor,
    this.unitPrefix,
  });

  Color get _valueColor {
    if (value >= dangerThreshold) return AppColors.gaugeDanger;
    if (value >= warningThreshold) return AppColors.gaugeWarning;
    return AppColors.gaugeFill;
  }

  String get _displayValue {
    if (divisor != null) {
      return (value / divisor!).toStringAsFixed(1);
    }
    return value.toStringAsFixed(0);
  }

  String get _displayUnit => '${unitPrefix ?? ''}$unit';

  @override
  Widget build(BuildContext context) {
    final progress = (value / maxValue).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Label
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),

            // Ring gauge via fl_chart PieChart
            SizedBox(
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -220,
                      sectionsSpace: 0,
                      centerSpaceRadius: 38,
                      sections: [
                        PieChartSectionData(
                          value: progress * 280,
                          color: _valueColor,
                          radius: 10,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: (1 - progress) * 280 + 80,
                          color: AppColors.gaugeTrack,
                          radius: 10,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  // Center value
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _displayValue,
                        style: TextStyle(
                          color: _valueColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _displayUnit,
                        style: const TextStyle(
                            color: AppColors.textHint, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
