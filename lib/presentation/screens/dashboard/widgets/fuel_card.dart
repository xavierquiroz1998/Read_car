import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/fuel_calculator.dart';

class FuelCard extends StatelessWidget {
  final double fuelLevelPercent;
  final double? consumptionLPer100km;
  final double engineLoadPercent;

  const FuelCard({
    super.key,
    required this.fuelLevelPercent,
    required this.consumptionLPer100km,
    required this.engineLoadPercent,
  });

  Color get _fuelColor {
    if (fuelLevelPercent <= 10) return AppColors.danger;
    if (fuelLevelPercent <= 25) return AppColors.warning;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final kmPerL = consumptionLPer100km != null
        ? FuelCalculator.lPer100kmToKmPerL(consumptionLPer100km!)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.local_gas_station,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                const Text('Combustible',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
                const Spacer(),
                Text(
                  '${fuelLevelPercent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _fuelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Fuel level bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fuelLevelPercent / 100,
                backgroundColor: AppColors.gaugeTrack,
                valueColor: AlwaysStoppedAnimation<Color>(_fuelColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 14),

            // Consumption metrics
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Consumo actual',
                    value: consumptionLPer100km != null
                        ? '${consumptionLPer100km!.toStringAsFixed(1)} L/100km'
                        : '—',
                    sublabel: consumptionLPer100km != null
                        ? '${kmPerL!.toStringAsFixed(1)} km/L'
                        : 'Vehículo detenido',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Metric(
                    label: 'Costo estimado/h',
                    value: consumptionLPer100km != null
                        ? '\$${_estimateCostPerH().toStringAsFixed(0)}'
                        : '—',
                    sublabel: 'COP / hora',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _estimateCostPerH() {
    if (consumptionLPer100km == null) return 0;
    // Approximate: L/100km × avg 60km/h / 100 × price
    return consumptionLPer100km! *
        60 /
        100 *
        AppConstants.defaultFuelPricePerL;
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;

  const _Metric({
    required this.label,
    required this.value,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textHint, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15)),
        Text(sublabel,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
