import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';

abstract class BluetoothDataSource {
  Stream<List<ScanResult>> startScan();
  Future<Either<Failure, void>> stopScan();
  Future<Either<Failure, BluetoothDevice>> connectToDevice(String deviceId);
  Future<Either<Failure, void>> disconnectDevice(BluetoothDevice device);
  Stream<BluetoothConnectionState> deviceConnectionState(BluetoothDevice device);
}
