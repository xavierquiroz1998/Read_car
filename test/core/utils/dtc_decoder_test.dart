import 'package:flutter_test/flutter_test.dart';
import 'package:read_car/core/utils/dtc_decoder.dart';

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // DtcDecoder.describe
  // ══════════════════════════════════════════════════════════════════════════
  group('DtcDecoder.describe', () {
    test('returns description for known P-code P0300', () {
      expect(
        DtcDecoder.describe('P0300'),
        'Random / Multiple Cylinder Misfire Detected',
      );
    });

    test('returns description for known P-code P0133', () {
      expect(
        DtcDecoder.describe('P0133'),
        'O2 Sensor Slow Response (Bank 1, Sensor 1)',
      );
    });

    test('returns description for known P-code P0420', () {
      expect(
        DtcDecoder.describe('P0420'),
        'Catalyst System Efficiency Below Threshold (Bank 1)',
      );
    });

    test('returns description for known U-code U0001', () {
      expect(
        DtcDecoder.describe('U0001'),
        'High Speed CAN Communication Bus',
      );
    });

    test('returns description for known B-code B0001', () {
      expect(
        DtcDecoder.describe('B0001'),
        'Driver Frontal Stage 1 Deployment Control',
      );
    });

    test('returns description for known C-code C0035', () {
      expect(
        DtcDecoder.describe('C0035'),
        'Left Front Wheel Speed Sensor Circuit',
      );
    });

    test('is case-insensitive — lowercase input', () {
      expect(
        DtcDecoder.describe('p0300'),
        'Random / Multiple Cylinder Misfire Detected',
      );
    });

    test('is case-insensitive — mixed case input', () {
      expect(
        DtcDecoder.describe('P0420'),
        DtcDecoder.describe('p0420'),
      );
    });

    test('returns generic fallback for unknown code', () {
      final desc = DtcDecoder.describe('P9999');
      expect(desc, contains('P9999'));
      expect(desc, contains('consult a mechanic'));
    });

    test('returns generic fallback for completely unknown code', () {
      final desc = DtcDecoder.describe('XXXXX');
      expect(desc, isNotEmpty);
    });

    // Spot-checks for each category
    test('cylinder misfire codes P0301–P0306 all have descriptions', () {
      for (int i = 1; i <= 6; i++) {
        final desc = DtcDecoder.describe('P030$i');
        expect(desc, contains('Cylinder $i Misfire'));
      }
    });

    test('coolant temperature codes have descriptions', () {
      final codes = ['P0115', 'P0116', 'P0117', 'P0118'];
      for (final code in codes) {
        expect(DtcDecoder.describe(code), isNot(contains('consult a mechanic')));
      }
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // DtcDecoder.severity
  // ══════════════════════════════════════════════════════════════════════════
  group('DtcDecoder.severity', () {
    test('P-code → powertrain', () {
      expect(DtcDecoder.severity('P0300'), DtcSeverity.powertrain);
    });

    test('C-code → chassis', () {
      expect(DtcDecoder.severity('C0035'), DtcSeverity.chassis);
    });

    test('B-code → body', () {
      expect(DtcDecoder.severity('B0001'), DtcSeverity.body);
    });

    test('U-code → network', () {
      expect(DtcDecoder.severity('U0001'), DtcSeverity.network);
    });

    test('empty code → unknown', () {
      expect(DtcDecoder.severity(''), DtcSeverity.unknown);
    });

    test('code with unknown prefix → unknown', () {
      expect(DtcDecoder.severity('X0001'), DtcSeverity.unknown);
    });

    test('lowercase p-code → powertrain', () {
      expect(DtcDecoder.severity('p0300'), DtcSeverity.powertrain);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // DtcSeverity.label
  // ══════════════════════════════════════════════════════════════════════════
  group('DtcSeverity.label', () {
    test('powertrain label is "Powertrain"', () {
      expect(DtcSeverity.powertrain.label, 'Powertrain');
    });

    test('chassis label is "Chassis"', () {
      expect(DtcSeverity.chassis.label, 'Chassis');
    });

    test('body label is "Body"', () {
      expect(DtcSeverity.body.label, 'Body');
    });

    test('network label is "Network"', () {
      expect(DtcSeverity.network.label, 'Network');
    });

    test('unknown label is "Unknown"', () {
      expect(DtcSeverity.unknown.label, 'Unknown');
    });

    test('all severity values have non-empty labels', () {
      for (final s in DtcSeverity.values) {
        expect(s.label, isNotEmpty);
      }
    });
  });
}
