import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/vehicle_data.dart';
import '../../navigation/routes.dart';
import '../../providers/bluetooth_provider.dart';
import '../../providers/vehicle_data_provider.dart';
import 'widgets/fuel_card.dart';
import 'widgets/gauge_card.dart';
import 'widgets/temp_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(vehicleDataProvider);
    final connectionState = ref.watch(connectionProvider);

    // Redirect to connection screen if disconnected
    ref.listen(connectionProvider, (_, next) {
      if (next.status == ConnectionStatus.disconnected) {
        context.go(Routes.connection);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Demo mode badge
          if (kDemoMode)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.warning, width: 1),
              ),
              child: const Text(
                'DEMO',
                style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
            ),
          // Connection indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.connected,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  connectionState.connectedDevice?.name ?? 'OBD2',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
      body: dataAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => _ErrorView(
          message: e.toString(),
          onRetry: () => context.go(Routes.connection),
        ),
        data: (data) => _DashboardContent(data: data),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  final VehicleData data;
  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consumption = ref.watch(fuelConsumptionProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Speed & RPM gauges ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: GaugeCard(
                    label: 'Velocidad',
                    value: data.speedKmh.toDouble(),
                    unit: 'km/h',
                    maxValue: 240,
                    warningThreshold: 120,
                    dangerThreshold: 160,
                    icon: Icons.speed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GaugeCard(
                    label: 'RPM',
                    value: data.rpm,
                    unit: 'rpm',
                    maxValue: 8000,
                    warningThreshold: 5000,
                    dangerThreshold: 6500,
                    icon: Icons.rotate_right,
                    divisor: 1000,
                    unitPrefix: 'k',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Fuel card ─────────────────────────────────────────────────
            FuelCard(
              fuelLevelPercent: data.fuelLevelPercent,
              consumptionLPer100km: consumption,
              engineLoadPercent: data.engineLoadPercent,
            ),
            const SizedBox(height: 12),

            // ── Temperature card ──────────────────────────────────────────
            TempCard(coolantTempC: data.coolantTempC),

            const SizedBox(height: 12),

            // ── Stats row ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Carga motor',
                    value:
                        '${data.engineLoadPercent.toStringAsFixed(0)}%',
                    icon: Icons.battery_charging_full,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Actualizado',
                    value: _timeAgo(data.timestamp),
                    icon: Icons.access_time,
                    iconColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t).inSeconds;
    if (diff < 2) return 'ahora';
    return 'hace ${diff}s';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textHint, fontSize: 11)),
                Text(value,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bluetooth_disabled,
                size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            const Text('Conexión perdida',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reconectar'),
            ),
          ],
        ),
      ),
    );
  }
}
