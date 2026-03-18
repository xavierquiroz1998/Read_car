import 'package:flutter_test/flutter_test.dart';
import 'package:read_car/domain/entities/vehicle_data.dart';

void main() {
  final fixedTime = DateTime(2026, 3, 18, 10, 0, 0);

  VehicleData makeData({
    int speedKmh = 60,
    double rpm = 2000,
    int coolantTempC = 90,
    double fuelLevelPercent = 75,
    double engineLoadPercent = 40,
    double? fuelConsumptionLPer100km = 7.5,
  }) =>
      VehicleData(
        speedKmh: speedKmh,
        rpm: rpm,
        coolantTempC: coolantTempC,
        fuelLevelPercent: fuelLevelPercent,
        engineLoadPercent: engineLoadPercent,
        fuelConsumptionLPer100km: fuelConsumptionLPer100km,
        timestamp: fixedTime,
      );

  // ── Construction ──────────────────────────────────────────────────────────
  group('VehicleData construction', () {
    test('holds all values correctly', () {
      final data = makeData();
      expect(data.speedKmh, 60);
      expect(data.rpm, 2000);
      expect(data.coolantTempC, 90);
      expect(data.fuelLevelPercent, 75);
      expect(data.engineLoadPercent, 40);
      expect(data.fuelConsumptionLPer100km, 7.5);
      expect(data.timestamp, fixedTime);
    });

    test('fuelConsumptionLPer100km can be null', () {
      final data = makeData(fuelConsumptionLPer100km: null);
      expect(data.fuelConsumptionLPer100km, isNull);
    });
  });

  // ── VehicleData.empty() ───────────────────────────────────────────────────
  group('VehicleData.empty()', () {
    test('all numeric fields are zero', () {
      final data = VehicleData.empty();
      expect(data.speedKmh, 0);
      expect(data.rpm, 0);
      expect(data.coolantTempC, 0);
      expect(data.fuelLevelPercent, 0);
      expect(data.engineLoadPercent, 0);
    });

    test('fuelConsumptionLPer100km is null', () {
      expect(VehicleData.empty().fuelConsumptionLPer100km, isNull);
    });

    test('timestamp is set (not null)', () {
      expect(VehicleData.empty().timestamp, isNotNull);
    });
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  group('VehicleData.copyWith', () {
    test('creates a new instance with updated speed', () {
      final original = makeData(speedKmh: 60);
      final updated = original.copyWith(speedKmh: 100);
      expect(updated.speedKmh, 100);
      expect(updated.rpm, original.rpm);
      expect(updated.coolantTempC, original.coolantTempC);
    });

    test('creates a new instance with updated RPM', () {
      final original = makeData(rpm: 2000);
      final updated = original.copyWith(rpm: 3500);
      expect(updated.rpm, 3500);
      expect(updated.speedKmh, original.speedKmh);
    });

    test('null fuelConsumption is preserved through copyWith', () {
      final original = makeData(fuelConsumptionLPer100km: null);
      final updated = original.copyWith(speedKmh: 50);
      expect(updated.fuelConsumptionLPer100km, isNull);
    });

    test('does not mutate original', () {
      final original = makeData(speedKmh: 60);
      original.copyWith(speedKmh: 200);
      expect(original.speedKmh, 60);
    });
  });

  // ── Equatable equality ────────────────────────────────────────────────────
  group('VehicleData equality (Equatable)', () {
    test('two instances with same props are equal', () {
      final a = makeData();
      final b = makeData();
      expect(a, equals(b));
    });

    test('different speed → not equal', () {
      expect(makeData(speedKmh: 60), isNot(equals(makeData(speedKmh: 80))));
    });

    test('different rpm → not equal', () {
      expect(makeData(rpm: 2000), isNot(equals(makeData(rpm: 3000))));
    });

    test('null vs non-null fuelConsumption → not equal', () {
      expect(
        makeData(fuelConsumptionLPer100km: null),
        isNot(equals(makeData(fuelConsumptionLPer100km: 7.5))),
      );
    });
  });
}
