import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color cardBackground = Color(0xFF222222);
  static const Color divider = Color(0xFF2E2E2E);

  // Brand / accent
  static const Color primary = Color(0xFF00E5FF);      // Cyan
  static const Color primaryDark = Color(0xFF0097A7);
  static const Color secondary = Color(0xFF76FF03);    // Green (speed / good)
  static const Color warning = Color(0xFFFFAB00);      // Amber
  static const Color danger = Color(0xFFFF1744);       // Red

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF606060);

  // Gauge
  static const Color gaugeBackground = Color(0xFF111111);
  static const Color gaugeTrack = Color(0xFF2C2C2C);
  static const Color gaugeFill = primary;
  static const Color gaugeWarning = warning;
  static const Color gaugeDanger = danger;

  // Status
  static const Color connected = Color(0xFF00C853);
  static const Color disconnected = Color(0xFFB0B0B0);
  static const Color scanning = Color(0xFFFFAB00);
}
