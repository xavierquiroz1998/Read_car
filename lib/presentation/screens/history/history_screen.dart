import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/trip_session.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(historyProvider.notifier).reload(),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
          child: Text(e.toString(),
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
        data: (trips) {
          if (trips.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 64, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text('Sin viajes registrados',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text(
                    'Los viajes se guardan automáticamente\ncuando se desconecta el OBD2.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          // Summary stats at the top
          final totalKm = trips.fold(0.0, (s, t) => s + t.totalDistanceKm);
          final totalFuel = trips.fold(0.0, (s, t) => s + t.totalFuelUsedL);
          final avgConsumption = totalKm > 0 ? totalFuel / totalKm * 100 : 0.0;

          return Column(
            children: [
              _SummaryBanner(
                totalTrips: trips.length,
                totalKm: totalKm,
                avgConsumption: avgConsumption,
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: trips.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (_, i) => _TripCard(trip: trips[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final int totalTrips;
  final double totalKm;
  final double avgConsumption;

  const _SummaryBanner({
    required this.totalTrips,
    required this.totalKm,
    required this.avgConsumption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BannerStat(label: 'Viajes', value: '$totalTrips'),
          _BannerStat(
              label: 'Km totales', value: totalKm.toStringAsFixed(1)),
          _BannerStat(
              label: 'Consumo prom.',
              value: '${avgConsumption.toStringAsFixed(1)} L/100'),
        ],
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  const _BannerStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textHint, fontSize: 11)),
      ],
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripSession trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date & duration
            Row(
              children: [
                const Icon(Icons.event, size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Text(fmt.format(trip.startTime),
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const Spacer(),
                Text(
                  _formatDuration(trip.duration),
                  style: const TextStyle(
                      color: AppColors.primary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    icon: Icons.route,
                    label: 'Distancia',
                    value: '${trip.totalDistanceKm.toStringAsFixed(1)} km',
                  ),
                ),
                Expanded(
                  child: _Stat(
                    icon: Icons.speed,
                    label: 'Vel. promedio',
                    value: '${trip.avgSpeedKmh.toStringAsFixed(0)} km/h',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    icon: Icons.local_gas_station,
                    label: 'Combustible',
                    value: '${trip.totalFuelUsedL.toStringAsFixed(2)} L',
                  ),
                ),
                Expanded(
                  child: _Stat(
                    icon: Icons.eco,
                    label: 'L/100km',
                    value: trip.avgFuelConsumptionLPer100km
                        .toStringAsFixed(1),
                  ),
                ),
              ],
            ),

            // DTC warning if any codes were detected
            if (trip.dtcsDetected.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 14, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    '${trip.dtcsDetected.length} código(s) DTC: ${trip.dtcsDetected.join(', ')}',
                    style: const TextStyle(
                        color: AppColors.warning, fontSize: 11),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 10)),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
