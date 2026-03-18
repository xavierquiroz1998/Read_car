import 'package:equatable/equatable.dart';

/// Base failure class. Use subtypes to communicate what went wrong
/// without leaking exceptions through the domain boundary.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Bluetooth failures ───────────────────────────────────────────────────────

class BluetoothUnavailableFailure extends Failure {
  const BluetoothUnavailableFailure()
      : super('Bluetooth is not available on this device');
}

class BluetoothPermissionFailure extends Failure {
  const BluetoothPermissionFailure()
      : super('Bluetooth permission was denied');
}

class DeviceNotFoundFailure extends Failure {
  const DeviceNotFoundFailure(String deviceName)
      : super('Device "$deviceName" not found');
}

class ConnectionFailure extends Failure {
  const ConnectionFailure([String msg = 'Failed to connect to OBD2 device'])
      : super(msg);
}

class DisconnectedFailure extends Failure {
  const DisconnectedFailure() : super('OBD2 device disconnected');
}

// ── OBD2 command failures ────────────────────────────────────────────────────

class CommandTimeoutFailure extends Failure {
  const CommandTimeoutFailure(String command)
      : super('Timeout waiting for response to "$command"');
}

class InvalidResponseFailure extends Failure {
  const InvalidResponseFailure(String raw)
      : super('Could not parse OBD2 response: "$raw"');
}

class UnsupportedPidFailure extends Failure {
  const UnsupportedPidFailure(String pid)
      : super('PID $pid is not supported by this vehicle');
}

class InitializationFailure extends Failure {
  const InitializationFailure([String msg = 'ELM327 initialization failed'])
      : super(msg);
}

// ── Storage failures ─────────────────────────────────────────────────────────

class StorageFailure extends Failure {
  const StorageFailure([String msg = 'Local storage error']) : super(msg);
}
