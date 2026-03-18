import '../constants/app_constants.dart';

/// Fuel consumption estimator based on OBD2 PIDs.
///
/// When the vehicle supports PID 015E (fuel rate), prefer that.
/// Otherwise we estimate using RPM + engine load + displacement.
class FuelCalculator {
  FuelCalculator._();

  /// Estimate instantaneous fuel consumption in L/100km.
  ///
  /// - [rpm] Engine speed (rev/min)
  /// - [engineLoadPercent] Engine load 0–100 %
  /// - [speedKmh] Vehicle speed (km/h)
  /// - [displacementL] Engine displacement in litres (default 1.6 L)
  ///
  /// Returns `null` when speed is zero (vehicle stopped) to avoid ÷0.
  static double? estimateLPer100km({
    required double rpm,
    required double engineLoadPercent,
    required int speedKmh,
    double displacementL = AppConstants.defaultDisplacementL,
  }) {
    if (speedKmh <= 0) return null;

    // Fuel flow rate estimate (L/h)
    // Derived from: power ≈ RPM × load × displacement / constant
    // Tuned constant 3600 normalises to L/h for typical BSFC values
    final fuelRateLPerH =
        (rpm * (engineLoadPercent / 100.0) * displacementL) /
            (AppConstants.stoichiometricAfr * 3600.0);

    // Convert to L/100km
    return (fuelRateLPerH / speedKmh) * 100.0;
  }

  /// Convert L/100km to km/L.
  static double lPer100kmToKmPerL(double lPer100km) {
    if (lPer100km <= 0) return 0;
    return 100.0 / lPer100km;
  }

  /// Estimated fuel cost for a given consumption and price.
  static double estimatedCostPerHour({
    required double rpm,
    required double engineLoadPercent,
    required double displacementL,
    double fuelPricePerL = AppConstants.defaultFuelPricePerL,
  }) {
    final fuelRateLPerH =
        (rpm * (engineLoadPercent / 100.0) * displacementL) /
            (AppConstants.stoichiometricAfr * 3600.0);
    return fuelRateLPerH * fuelPricePerL;
  }

  /// Total cost estimate for a trip.
  static double tripCost({
    required double totalFuelL,
    double fuelPricePerL = AppConstants.defaultFuelPricePerL,
  }) =>
      totalFuelL * fuelPricePerL;
}
