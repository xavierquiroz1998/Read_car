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

    test('camshaft/crankshaft codes P0010–P0022 have descriptions', () {
      final codes = ['P0010', 'P0011', 'P0012', 'P0013', 'P0014', 'P0015',
        'P0016', 'P0017', 'P0020', 'P0021', 'P0022'];
      for (final code in codes) {
        expect(DtcDecoder.describe(code), isNot(contains('consult a mechanic')));
      }
    });

    test('O2 sensor codes Bank 2 have descriptions', () {
      final codes = ['P0150', 'P0151', 'P0152', 'P0153', 'P0154', 'P0155',
        'P0156', 'P0157', 'P0158', 'P0159', 'P0160', 'P0161'];
      for (final code in codes) {
        expect(DtcDecoder.describe(code), isNot(contains('consult a mechanic')));
      }
    });

    test('injector codes P0201–P0208 have descriptions', () {
      for (int i = 1; i <= 8; i++) {
        final desc = DtcDecoder.describe('P020$i');
        expect(desc, contains('Cylinder $i'));
      }
    });

    test('knock sensor codes have descriptions', () {
      final codes = ['P0325', 'P0326', 'P0327', 'P0328', 'P0330', 'P0332', 'P0333'];
      for (final code in codes) {
        expect(DtcDecoder.describe(code), isNot(contains('consult a mechanic')));
      }
    });

    test('ignition coil codes P0351–P0356 have descriptions', () {
      for (int i = 1; i <= 6; i++) {
        final desc = DtcDecoder.describe('P035$i');
        expect(desc, contains('Ignition Coil'));
      }
    });

    test('idle control codes P0505–P0507 have descriptions', () {
      final codes = ['P0505', 'P0506', 'P0507'];
      for (final code in codes) {
        expect(DtcDecoder.describe(code), isNot(contains('consult a mechanic')));
      }
    });

    test('transmission gear ratio codes P0731–P0735 have descriptions', () {
      for (int i = 1; i <= 5; i++) {
        final desc = DtcDecoder.describe('P073$i');
        expect(desc, contains('Gear $i'));
      }
    });

    test('torque converter codes P0740–P0744 have descriptions', () {
      final codes = ['P0740', 'P0741', 'P0742', 'P0743', 'P0744'];
      for (final code in codes) {
        expect(DtcDecoder.describe(code), contains('Torque Converter'));
      }
    });

    test('turbo/diesel codes have descriptions', () {
      final codes = ['P0234', 'P0235', 'P0299', 'P0380', 'P0381'];
      for (final code in codes) {
        expect(DtcDecoder.describe(code), isNot(contains('consult a mechanic')));
      }
    });

    test('ABS wheel speed C-codes have descriptions', () {
      final codes = ['C0035', 'C0040', 'C0045', 'C0050'];
      for (final code in codes) {
        expect(DtcDecoder.describe(code), contains('Wheel Speed'));
      }
    });

    test('body B-codes have descriptions', () {
      final codes = ['B0001', 'B0002', 'B0010', 'B1318', 'B2799'];
      for (final code in codes) {
        expect(DtcDecoder.describe(code), isNot(contains('consult a mechanic')));
      }
    });

    test('network U-codes for lost communication have descriptions', () {
      final codes = ['U0100', 'U0101', 'U0121', 'U0140', 'U0151', 'U0155'];
      for (final code in codes) {
        expect(DtcDecoder.describe(code), contains('Lost Communication'));
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
