import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../entities/vehicle_data.dart';
import '../entities/dtc_code.dart';

/// Contract for all OBD2 communication.
abstract class Obd2Repository {
  /// Send the ELM327 initialization sequence (ATZ, ATE0, …).
  Future<Either<Failure, void>> initialize();

  /// Continuous stream of live vehicle data readings.
  Stream<Either<Failure, VehicleData>> vehicleDataStream();

  /// Request stored DTCs from the ECU (mode 03).
  Future<Either<Failure, List<DtcCode>>> readDtcCodes();

  /// Clear stored DTCs and turn off the MIL (mode 04).
  Future<Either<Failure, void>> clearDtcCodes();

  /// Send a raw PID command and return the raw response string.
  /// Useful for debugging or one-off queries.
  Future<Either<Failure, String>> sendRawCommand(String command);

  /// Dispose streaming resources (call when disconnecting).
  void dispose();
}
