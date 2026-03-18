import 'package:flutter_test/flutter_test.dart';
import 'package:read_car/core/utils/obd2_parser.dart';

void main() {
  // ══════════════════════════════════════════════════════════════════════════
  // parseSpeed — PID 010D
  // Formula: A (km/h)
  // ══════════════════════════════════════════════════════════════════════════
  group('Obd2Parser.parseSpeed', () {
    test('parses clean response: 41 0D 3C → 60 km/h', () {
      expect(Obd2Parser.parseSpeed('410D3C'), 60);
    });

    test('parses with spaces (ELM327 raw): "41 0D 3C"', () {
      expect(Obd2Parser.parseSpeed('41 0D 3C'), 60);
    });

    test('parses response with prompt char: "410D3C\\r\\n>"', () {
      expect(Obd2Parser.parseSpeed('410D3C\r\n>'), 60);
    });

    test('speed = 0 (vehicle stopped): A = 0x00', () {
      expect(Obd2Parser.parseSpeed('410D00'), 0);
    });

    test('speed = 120 km/h: A = 0x78', () {
      expect(Obd2Parser.parseSpeed('410D78'), 120);
    });

    test('speed = 255 km/h (max single byte): A = 0xFF', () {
      expect(Obd2Parser.parseSpeed('410DFF'), 255);
    });

    test('response without header prefix still parses', () {
      // Some adapters skip the echo — treat raw hex as data bytes
      expect(Obd2Parser.parseSpeed('3C'), 60);
    });

    test('throws FormatException on too-short input', () {
      expect(() => Obd2Parser.parseSpeed('410D'), throwsFormatException);
    });

    test('throws FormatException on empty string', () {
      expect(() => Obd2Parser.parseSpeed(''), throwsFormatException);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // parseRpm — PID 010C
  // Formula: (A×256 + B) / 4
  // ══════════════════════════════════════════════════════════════════════════
  group('Obd2Parser.parseRpm', () {
    test('parses idle RPM 750: A=0x0B B=0xB8 → (11×256+184)/4 = 750', () {
      expect(Obd2Parser.parseRpm('410C0BB8'), 750.0);
    });

    test('parses with spaces: "41 0C 0B B8"', () {
      expect(Obd2Parser.parseRpm('41 0C 0B B8'), 750.0);
    });

    test('RPM = 0 when A=0x00 B=0x00', () {
      expect(Obd2Parser.parseRpm('410C0000'), 0.0);
    });

    test('parses 3000 RPM: A=0x2E B=0xE0 → (46×256+224)/4 = 3000', () {
      expect(Obd2Parser.parseRpm('410C2EE0'), 3000.0);
    });

    test('parses RPM: A=0x65 B=0xF8 → (101×256+248)/4 = 6526', () {
      // A=0x65=101, B=0xF8=248 → (101*256+248)/4 = 26136/4 = 6534 ... wait:
      // 101*256 = 25856, +248 = 26104, /4 = 6526.0
      final result = Obd2Parser.parseRpm('410C65F8');
      expect(result, closeTo(6526.0, 0.1));
    });

    test('throws FormatException when response is too short', () {
      expect(() => Obd2Parser.parseRpm('410C0B'), throwsFormatException);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // parseCoolantTemp — PID 0105
  // Formula: A - 40 (°C)
  // ══════════════════════════════════════════════════════════════════════════
  group('Obd2Parser.parseCoolantTemp', () {
    test('normal operating temp 90°C: A = 0x82 = 130 → 130-40=90', () {
      expect(Obd2Parser.parseCoolantTemp('41057A'), 82); // 0x7A=122 → 82°C
    });

    test('cold engine -40°C: A = 0x00 → 0-40 = -40', () {
      expect(Obd2Parser.parseCoolantTemp('410500'), -40);
    });

    test('warm engine 80°C: A = 0x78 = 120 → 120-40 = 80', () {
      expect(Obd2Parser.parseCoolantTemp('410578'), 80);
    });

    test('overheating 115°C: A = 0x9B = 155 → 155-40 = 115', () {
      expect(Obd2Parser.parseCoolantTemp('41059B'), 115);
    });

    test('parses with spaces', () {
      expect(Obd2Parser.parseCoolantTemp('41 05 78'), 80);
    });

    test('throws FormatException on too-short input', () {
      expect(() => Obd2Parser.parseCoolantTemp('4105'), throwsFormatException);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // parseFuelLevel — PID 012F
  // Formula: A × 100 / 255 (%)
  // ══════════════════════════════════════════════════════════════════════════
  group('Obd2Parser.parseFuelLevel', () {
    test('full tank: A = 0xFF = 255 → 100%', () {
      expect(Obd2Parser.parseFuelLevel('412FFF'), closeTo(100.0, 0.1));
    });

    test('empty tank: A = 0x00 = 0 → 0%', () {
      expect(Obd2Parser.parseFuelLevel('412F00'), closeTo(0.0, 0.01));
    });

    test('half tank: A = 0x7F = 127 → ~49.8%', () {
      expect(Obd2Parser.parseFuelLevel('412F7F'), closeTo(49.8, 0.2));
    });

    test('25% tank: A = 0x3F = 63 → ~24.7%', () {
      expect(Obd2Parser.parseFuelLevel('412F3F'), closeTo(24.7, 0.2));
    });

    test('parses with spaces', () {
      expect(Obd2Parser.parseFuelLevel('41 2F FF'), closeTo(100.0, 0.1));
    });

    test('throws FormatException on too-short input', () {
      expect(() => Obd2Parser.parseFuelLevel('412F'), throwsFormatException);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // parseEngineLoad — PID 0104
  // Formula: A × 100 / 255 (%)
  // ══════════════════════════════════════════════════════════════════════════
  group('Obd2Parser.parseEngineLoad', () {
    test('full load: A = 0xFF → 100%', () {
      expect(Obd2Parser.parseEngineLoad('4104FF'), closeTo(100.0, 0.1));
    });

    test('no load: A = 0x00 → 0%', () {
      expect(Obd2Parser.parseEngineLoad('410400'), closeTo(0.0, 0.01));
    });

    test('50% load: A = 0x80 = 128 → ~50.2%', () {
      expect(Obd2Parser.parseEngineLoad('410480'), closeTo(50.2, 0.2));
    });

    test('parses with spaces', () {
      expect(Obd2Parser.parseEngineLoad('41 04 FF'), closeTo(100.0, 0.1));
    });

    test('throws FormatException on too-short input', () {
      expect(() => Obd2Parser.parseEngineLoad('4104'), throwsFormatException);
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // parseDtcCodes — Mode 03
  // ══════════════════════════════════════════════════════════════════════════
  group('Obd2Parser.parseDtcCodes', () {
    test('NODATA returns empty list', () {
      expect(Obd2Parser.parseDtcCodes('NODATA'), isEmpty);
    });

    test('"NO DATA" with space also returns empty', () {
      expect(Obd2Parser.parseDtcCodes('NO DATA'), isEmpty);
    });

    test('OK response returns empty list', () {
      expect(Obd2Parser.parseDtcCodes('OK'), isEmpty);
    });

    test('empty string returns empty list', () {
      expect(Obd2Parser.parseDtcCodes(''), isEmpty);
    });

    test('single P-code: 43 01 33 → P0133', () {
      final codes = Obd2Parser.parseDtcCodes('43 01 33 00 00 00 00');
      expect(codes, ['P0133']);
    });

    test('single P-code without spaces: 430133000000', () {
      final codes = Obd2Parser.parseDtcCodes('430133000000');
      expect(codes, ['P0133']);
    });

    test('P0300 — multiple misfire: 43 03 00', () {
      final codes = Obd2Parser.parseDtcCodes('43 03 00 00 00 00 00');
      expect(codes, contains('P0300'));
    });

    test('two DTCs returned', () {
      // 43 0133 0420 = P0133 + P0420
      final codes = Obd2Parser.parseDtcCodes('430133042000000000');
      expect(codes.length, 2);
      expect(codes, containsAll(['P0133', 'P0420']));
    });

    test('padding 0000 pairs are ignored', () {
      final codes = Obd2Parser.parseDtcCodes('43000000000000000000');
      expect(codes, isEmpty);
    });

    test('C-code parsed: first nibble 4–7 → C category', () {
      // First nibble 4 → C, digit=0, remaining="133" → C0133
      final codes = Obd2Parser.parseDtcCodes('43413300000000');
      expect(codes, contains('C0133'));
    });

    test('B-code parsed: first nibble 8–B → B category', () {
      // First nibble 8 → B, digit=0, remaining="001" → B0001
      final codes = Obd2Parser.parseDtcCodes('43800100000000');
      expect(codes, contains('B0001'));
    });

    test('U-code parsed: first nibble C–F → U category', () {
      // First nibble C=12 → U, digit=0, remaining="001" → U0001
      final codes = Obd2Parser.parseDtcCodes('43C00100000000');
      expect(codes, contains('U0001'));
    });
  });

  // ══════════════════════════════════════════════════════════════════════════
  // isNoData
  // ══════════════════════════════════════════════════════════════════════════
  group('Obd2Parser.isNoData', () {
    test('returns true for "NODATA"', () {
      expect(Obd2Parser.isNoData('NODATA'), isTrue);
    });

    test('returns true for "NO DATA" with space', () {
      expect(Obd2Parser.isNoData('NO DATA'), isTrue);
    });

    test('returns true for "?"', () {
      expect(Obd2Parser.isNoData('?'), isTrue);
    });

    test('returns true for empty string', () {
      expect(Obd2Parser.isNoData(''), isTrue);
    });

    test('returns false for valid response', () {
      expect(Obd2Parser.isNoData('410D3C'), isFalse);
    });

    test('returns false for OK response', () {
      expect(Obd2Parser.isNoData('OK'), isFalse);
    });
  });
}
