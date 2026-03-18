import 'package:flutter_test/flutter_test.dart';
import 'package:read_car/core/errors/failures.dart';

void main() {
  // ── Message content ───────────────────────────────────────────────────────
  group('Failure messages', () {
    test('BluetoothUnavailableFailure has descriptive message', () {
      const f = BluetoothUnavailableFailure();
      expect(f.message, isNotEmpty);
      expect(f.message.toLowerCase(), contains('bluetooth'));
    });

    test('BluetoothPermissionFailure has descriptive message', () {
      const f = BluetoothPermissionFailure();
      expect(f.message.toLowerCase(), contains('permission'));
    });

    test('DeviceNotFoundFailure includes device name in message', () {
      const name = 'ELM327-OBDII';
      final f = DeviceNotFoundFailure(name);
      expect(f.message, contains(name));
    });

    test('ConnectionFailure has default message', () {
      const f = ConnectionFailure();
      expect(f.message, isNotEmpty);
    });

    test('ConnectionFailure accepts custom message', () {
      const f = ConnectionFailure('Custom error');
      expect(f.message, 'Custom error');
    });

    test('DisconnectedFailure has descriptive message', () {
      const f = DisconnectedFailure();
      expect(f.message.toLowerCase(), contains('disconnect'));
    });

    test('CommandTimeoutFailure includes command in message', () {
      const cmd = '010D';
      final f = CommandTimeoutFailure(cmd);
      expect(f.message, contains(cmd));
    });

    test('InvalidResponseFailure includes raw response in message', () {
      const raw = '??GARBAGE??';
      final f = InvalidResponseFailure(raw);
      expect(f.message, contains(raw));
    });

    test('UnsupportedPidFailure includes PID in message', () {
      const pid = '012F';
      final f = UnsupportedPidFailure(pid);
      expect(f.message, contains(pid));
    });

    test('InitializationFailure has default message', () {
      const f = InitializationFailure();
      expect(f.message, isNotEmpty);
    });

    test('StorageFailure has default message', () {
      const f = StorageFailure();
      expect(f.message, isNotEmpty);
    });
  });

  // ── Equatable props ───────────────────────────────────────────────────────
  group('Failure equality (Equatable)', () {
    test('two failures with same message are equal', () {
      final a = ConnectionFailure('timeout');
      final b = ConnectionFailure('timeout');
      expect(a, equals(b));
    });

    test('two failures with different messages are not equal', () {
      final a = ConnectionFailure('timeout');
      final b = ConnectionFailure('refused');
      expect(a, isNot(equals(b)));
    });

    test('different failure types are not equal even with same message', () {
      const a = DisconnectedFailure();
      const b = BluetoothUnavailableFailure();
      expect(a, isNot(equals(b)));
    });
  });

  // ── Type hierarchy ────────────────────────────────────────────────────────
  group('Failure type hierarchy', () {
    test('all failures extend Failure', () {
      expect(const BluetoothUnavailableFailure(), isA<Failure>());
      expect(const BluetoothPermissionFailure(), isA<Failure>());
      expect(DeviceNotFoundFailure('x'), isA<Failure>());
      expect(const ConnectionFailure(), isA<Failure>());
      expect(const DisconnectedFailure(), isA<Failure>());
      expect(CommandTimeoutFailure('y'), isA<Failure>());
      expect(InvalidResponseFailure('z'), isA<Failure>());
      expect(UnsupportedPidFailure('w'), isA<Failure>());
      expect(const InitializationFailure(), isA<Failure>());
      expect(const StorageFailure(), isA<Failure>());
    });
  });
}
