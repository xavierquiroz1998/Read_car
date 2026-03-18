import 'package:flutter_test/flutter_test.dart';
import 'package:read_car/domain/entities/dtc_code.dart';
import 'package:read_car/core/utils/dtc_decoder.dart';

void main() {
  final fixedTime = DateTime(2026, 3, 18, 12, 0, 0);

  // ── DtcCode auto-decode constructor ───────────────────────────────────────
  group('DtcCode (auto-decode)', () {
    test('auto-decodes known P0300 description', () {
      final dtc = DtcCode(code: 'P0300', detectedAt: fixedTime);
      expect(dtc.description,
          'Random / Multiple Cylinder Misfire Detected');
    });

    test('auto-decodes unknown code with fallback description', () {
      final dtc = DtcCode(code: 'P9999', detectedAt: fixedTime);
      expect(dtc.description, contains('P9999'));
    });

    test('severity is powertrain for P-code', () {
      final dtc = DtcCode(code: 'P0133', detectedAt: fixedTime);
      expect(dtc.severity, DtcSeverity.powertrain);
    });

    test('severity is chassis for C-code', () {
      final dtc = DtcCode(code: 'C0035', detectedAt: fixedTime);
      expect(dtc.severity, DtcSeverity.chassis);
    });

    test('severity is body for B-code', () {
      final dtc = DtcCode(code: 'B0001', detectedAt: fixedTime);
      expect(dtc.severity, DtcSeverity.body);
    });

    test('severity is network for U-code', () {
      final dtc = DtcCode(code: 'U0001', detectedAt: fixedTime);
      expect(dtc.severity, DtcSeverity.network);
    });

    test('holds detectedAt timestamp', () {
      final dtc = DtcCode(code: 'P0300', detectedAt: fixedTime);
      expect(dtc.detectedAt, fixedTime);
    });
  });

  // ── DtcCode.withDescription (manual constructor) ──────────────────────────
  group('DtcCode.withDescription', () {
    test('stores provided description verbatim', () {
      final dtc = DtcCode.withDescription(
        code: 'P0300',
        description: 'Custom description',
        severity: DtcSeverity.powertrain,
        detectedAt: fixedTime,
      );
      expect(dtc.description, 'Custom description');
    });

    test('stores provided severity', () {
      final dtc = DtcCode.withDescription(
        code: 'X1234',
        description: 'some desc',
        severity: DtcSeverity.unknown,
        detectedAt: fixedTime,
      );
      expect(dtc.severity, DtcSeverity.unknown);
    });
  });

  // ── Equatable equality ────────────────────────────────────────────────────
  group('DtcCode equality (Equatable)', () {
    test('same code + same timestamp → equal', () {
      final a = DtcCode(code: 'P0300', detectedAt: fixedTime);
      final b = DtcCode(code: 'P0300', detectedAt: fixedTime);
      expect(a, equals(b));
    });

    test('different code → not equal', () {
      final a = DtcCode(code: 'P0300', detectedAt: fixedTime);
      final b = DtcCode(code: 'P0420', detectedAt: fixedTime);
      expect(a, isNot(equals(b)));
    });

    test('different timestamp → not equal', () {
      final a = DtcCode(code: 'P0300', detectedAt: fixedTime);
      final b = DtcCode(
          code: 'P0300',
          detectedAt: fixedTime.add(const Duration(seconds: 1)));
      expect(a, isNot(equals(b)));
    });
  });
}
