import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TempCard extends StatelessWidget {
  final int coolantTempC;
  const TempCard({super.key, required this.coolantTempC});

  Color get _color {
    if (coolantTempC >= 105) return AppColors.danger;
    if (coolantTempC >= 90) return AppColors.warning;
    if (coolantTempC < 60) return AppColors.primary;
    return AppColors.secondary;
  }

  String get _status {
    if (coolantTempC >= 105) return 'SOBRETEMPERATURA';
    if (coolantTempC >= 90) return 'Normal';
    if (coolantTempC < 40) return 'Frío';
    if (coolantTempC < 60) return 'Calentando…';
    return 'Temperatura normal';
  }

  @override
  Widget build(BuildContext context) {
    final progress = ((coolantTempC + 40) / 160).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.thermostat, color: _color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Motor',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 12)),
                      const Spacer(),
                      Text(_status,
                          style: TextStyle(
                              color: _color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$coolantTempC',
                        style: TextStyle(
                            color: _color,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(bottom: 4, left: 2),
                        child: Text('°C',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.gaugeTrack,
                      valueColor: AlwaysStoppedAnimation<Color>(_color),
                      minHeight: 6,
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
}
