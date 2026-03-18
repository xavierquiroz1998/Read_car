import 'package:flutter_test/flutter_test.dart';
import 'package:read_car/core/utils/fuel_calculator.dart';
import 'package:read_car/core/constants/app_constants.dart';

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // estimateLPer100km
  // Formula: fuelRateLPerH = (RPM × load/100 × displ) / (AFR × 3600)
  //          L/100km       = (fuelRateLPerH / speed) × 100
  // ══════════════════════════════════════════════════════════════════════════
  group('FuelCalculator.estimateLPer100km', () {
    test('returns null when speed = 0 (vehicle stopped)', () {
      final result = FuelCalculator.estimateLPer100km(
        rpm: 800,
        engineLoadPercent: 30,
        speedKmh: 0,
      );
      expect(result, isNull);
    });

    test('returns null when speed is negative', () {
      final result = FuelCalculator.estimateLPer100km(
        rpm: 800,
        engineLoadPercent: 30,
        speedKmh: -10,
      );
      expect(result, isNull);
    });

    test('returns positive value when speed > 0', () {
      final result = FuelCalculator.estimateLPer100km(
        rpm: 2000,
        engineLoadPercent: 40,
        speedKmh: 80,
      );
      expect(result, isNotNull);
      expect(result!, greaterThan(0));
    });

    test('consumption increases with RPM (same speed and load)', () {
      final low = FuelCalculator.estimateLPer100km(
        rpm: 1500,
        engineLoadPercent: 40,
        speedKmh: 60,
      );
      final high = FuelCalculator.estimateLPer100km(
        rpm: 4000,
        engineLoadPercent: 40,
        speedKmh: 60,
      );
      expect(high!, greaterThan(low!));
    });

    test('consumption increases with engine load (same RPM and speed)', () {
      final light = FuelCalculator.estimateLPer100km(
        rpm: 2000,
        engineLoadPercent: 20,
        speedKmh: 80,
      );
      final heavy = FuelCalculator.estimateLPer100km(
        rpm: 2000,
        engineLoadPercent: 80,
        speedKmh: 80,
      );
      expect(heavy!, greaterThan(light!));
    });

    test('consumption decreases as speed increases (same RPM and load)', () {
      final slow = FuelCalculator.estimateLPer100km(
        rpm: 2000,
        engineLoadPercent: 50,
        speedKmh: 40,
      );
      final fast = FuelCalculator.estimateLPer100km(
        rpm: 2000,
        engineLoadPercent: 50,
        speedKmh: 120,
      );
      expect(slow!, greaterThan(fast!));
    });

    test('uses default displacement of 1.6 L when not specified', () {
      final withDefault = FuelCalculator.estimateLPer100km(
        rpm: 2000,
        engineLoadPercent: 50,
        speedKmh: 80,
      );
      final explicit = FuelCalculator.estimateLPer100km(
        rpm: 2000,
        engineLoadPercent: 50,
        speedKmh: 80,
        displacementL: AppConstants.defaultDisplacementL,
      );
      expect(withDefault, closeTo(explicit!, 0.0001));
    });

    test('larger engine displacement yields higher consumption', () {
      final small = FuelCalculator.estimateLPer100km(
        rpm: 2500,
        engineLoadPercent: 60,
        speedKmh: 100,
        displacementL: 1.0,
      );
      final large = FuelCalculator.estimateLPer100km(
        rpm: 2500,
        engineLoadPercent: 60,
        speedKmh: 100,
        displacementL: 3.0,
      );
      expect(large!, greaterThan(small!));
    });

    test('consumption is zero when engine load is 0%', () {
      final result = FuelCalculator.estimateLPer100km(
        rpm: 2000,
        engineLoadPercent: 0,
        speedKmh: 60,
      );
      expect(result, closeTo(0.0, 0.0001));
    });

    test('manual spot-check: 2000 RPM, 50% load, 80 km/h, 1.6 L displacement', () {
      // fuelRateL/h = (2000 × 0.5 × 1.6) / (14.7 × 3600) ≈ 0.03030 L/h
      // L/100km = (0.03030 / 80) × 100 ≈ 0.0379 L/100km
      final result = FuelCalculator.estimateLPer100km(
        rpm: 2000,
        engineLoadPercent: 50,
        speedKmh: 80,
        displacementL: 1.6,
      );
      expect(result, closeTo(0.038, 0.005));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // lPer100kmToKmPerL
  // ══════════════════════════════════════════════════════════════════════════
  group('FuelCalculator.lPer100kmToKmPerL', () {
    test('10 L/100km → 10 km/L', () {
      expect(FuelCalculator.lPer100kmToKmPerL(10.0), closeTo(10.0, 0.001));
    });

    test('5 L/100km → 20 km/L', () {
      expect(FuelCalculator.lPer100kmToKmPerL(5.0), closeTo(20.0, 0.001));
    });

    test('20 L/100km → 5 km/L', () {
      expect(FuelCalculator.lPer100kmToKmPerL(20.0), closeTo(5.0, 0.001));
    });

    test('returns 0 when input is 0 (avoid ÷0)', () {
      expect(FuelCalculator.lPer100kmToKmPerL(0.0), 0.0);
    });

    test('returns 0 when input is negative', () {
      expect(FuelCalculator.lPer100kmToKmPerL(-5.0), 0.0);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // estimatedCostPerHour
  // ══════════════════════════════════════════════════════════════════════════
  group('FuelCalculator.estimatedCostPerHour', () {
    test('returns positive cost when engine is under load', () {
      final cost = FuelCalculator.estimatedCostPerHour(
        rpm: 2000,
        engineLoadPercent: 50,
        displacementL: 1.6,
      );
      expect(cost, greaterThan(0));
    });

    test('cost is zero when engine load is 0%', () {
      final cost = FuelCalculator.estimatedCostPerHour(
        rpm: 2000,
        engineLoadPercent: 0,
        displacementL: 1.6,
      );
      expect(cost, closeTo(0.0, 0.001));
    });

    test('higher fuel price → higher cost', () {
      final cheap = FuelCalculator.estimatedCostPerHour(
        rpm: 2000,
        engineLoadPercent: 50,
        displacementL: 1.6,
        fuelPricePerL: 1000,
      );
      final expensive = FuelCalculator.estimatedCostPerHour(
        rpm: 2000,
        engineLoadPercent: 50,
        displacementL: 1.6,
        fuelPricePerL: 8000,
      );
      expect(expensive, greaterThan(cheap));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // tripCost
  // ══════════════════════════════════════════════════════════════════════════
  group('FuelCalculator.tripCost', () {
    test('10 L × default price', () {
      final cost = FuelCalculator.tripCost(totalFuelL: 10.0);
      expect(cost, closeTo(10.0 * AppConstants.defaultFuelPricePerL, 0.01));
    });

    test('0 L → 0 cost', () {
      expect(FuelCalculator.tripCost(totalFuelL: 0), closeTo(0, 0.001));
    });

    test('custom price applied correctly', () {
      final cost = FuelCalculator.tripCost(
        totalFuelL: 5.0,
        fuelPricePerL: 2000.0,
      );
      expect(cost, closeTo(10000.0, 0.01));
    });
  });
}
