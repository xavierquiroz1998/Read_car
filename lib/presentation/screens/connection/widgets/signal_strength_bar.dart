import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Escala de señal RSSI para Bluetooth:
///   Excelente : >= -60 dBm   (4 barras, verde)
///   Buena     : >= -70 dBm   (3 barras, verde claro)
///   Regular   : >= -80 dBm   (2 barras, amarillo)
///   Débil     :  < -80 dBm   (1 barra,  rojo)
class SignalStrengthBar extends StatelessWidget {
  final int rssi;
  final double barWidth;
  final double maxBarHeight;
  final double spacing;

  const SignalStrengthBar({
    super.key,
    required this.rssi,
    this.barWidth = 5,
    this.maxBarHeight = 18,
    this.spacing = 2,
  });

  static SignalLevel levelFromRssi(int rssi) {
    if (rssi >= -60) return SignalLevel.excellent;
    if (rssi >= -70) return SignalLevel.good;
    if (rssi >= -80) return SignalLevel.fair;
    return SignalLevel.weak;
  }

  @override
  Widget build(BuildContext context) {
    final level = levelFromRssi(rssi);
    final activeBars = level.bars;
    final color = level.color;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final barHeight = maxBarHeight * ((i + 1) / 4);
        final isActive = i < activeBars;
        return Padding(
          padding: EdgeInsets.only(left: i == 0 ? 0 : spacing),
          child: Container(
            width: barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: isActive ? color : AppColors.gaugeTrack,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

enum SignalLevel {
  excellent(4, AppColors.connected, 'Excelente'),
  good(3, Color(0xFF69F0AE), 'Buena'),
  fair(2, AppColors.warning, 'Regular'),
  weak(1, AppColors.danger, 'Débil');

  final int bars;
  final Color color;
  final String label;

  const SignalLevel(this.bars, this.color, this.label);
}
