import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/either.dart';

/// Contract for communicating with an ELM327 OBD2 adapter.
abstract class Obd2DataSource {
  /// Set the Bluetooth characteristics once a device is connected.
  void attachCharacteristics({
    required BluetoothCharacteristic writeCharacteristic,
    required BluetoothCharacteristic notifyCharacteristic,
  });

  /// Send [command] and await a single response line.
  Future<Either<Failure, String>> sendCommand(String command);

  /// Release subscriptions and pending completers.
  void dispose();
}
