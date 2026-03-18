import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../data/datasources/bluetooth/bluetooth_datasource_impl.dart';
import '../../data/datasources/local/hive_datasource_impl.dart';
import '../../data/datasources/obd2/obd2_datasource_impl.dart';
import '../../data/repositories/bluetooth_repository_impl.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../data/repositories/mock_bluetooth_repository.dart';
import '../../data/repositories/mock_obd2_repository.dart';
import '../../data/repositories/obd2_repository_impl.dart';
import '../../domain/repositories/bluetooth_repository.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/repositories/obd2_repository.dart';
import '../../domain/usecases/bluetooth/connect_device_usecase.dart';
import '../../domain/usecases/bluetooth/scan_devices_usecase.dart';
import '../../domain/usecases/history/get_trips_usecase.dart';
import '../../domain/usecases/history/save_trip_usecase.dart';
import '../../domain/usecases/obd2/clear_dtc_usecase.dart';
import '../../domain/usecases/obd2/fetch_vehicle_data_usecase.dart';
import '../../domain/usecases/obd2/initialize_obd2_usecase.dart';
import '../../domain/usecases/obd2/read_dtc_usecase.dart';

// ── Infrastructure ────────────────────────────────────────────────────────────

final hiveDataSourceProvider = Provider<HiveDataSourceImpl>(
  (_) => HiveDataSourceImpl(),
);

final bluetoothDataSourceProvider = Provider<BluetoothDataSourceImpl>(
  (_) => BluetoothDataSourceImpl(),
);

final obd2DataSourceProvider = Provider<Obd2DataSourceImpl>(
  (_) => Obd2DataSourceImpl(),
);

// ── Repositories ──────────────────────────────────────────────────────────────

/// Cambia `kDemoMode` en app_config.dart para alternar entre
/// modo real (ELM327 físico) y modo demo (emulador / UI dev).
final bluetoothRepositoryProvider = Provider<BluetoothRepository>(
  (ref) => kDemoMode
      ? MockBluetoothRepository()
      : BluetoothRepositoryImpl(ref.watch(bluetoothDataSourceProvider)),
);

final obd2RepositoryProvider = Provider<Obd2Repository>(
  (ref) => kDemoMode
      ? MockObd2Repository()
      : Obd2RepositoryImpl(ref.watch(obd2DataSourceProvider)),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepositoryImpl(ref.watch(hiveDataSourceProvider)),
);

// ── Use Cases ─────────────────────────────────────────────────────────────────

final scanDevicesUseCaseProvider = Provider(
  (ref) => ScanDevicesUseCase(ref.watch(bluetoothRepositoryProvider)),
);

final connectDeviceUseCaseProvider = Provider(
  (ref) => ConnectDeviceUseCase(ref.watch(bluetoothRepositoryProvider)),
);

final initializeObd2UseCaseProvider = Provider(
  (ref) => InitializeObd2UseCase(ref.watch(obd2RepositoryProvider)),
);

final fetchVehicleDataUseCaseProvider = Provider(
  (ref) => FetchVehicleDataUseCase(ref.watch(obd2RepositoryProvider)),
);

final readDtcUseCaseProvider = Provider(
  (ref) => ReadDtcUseCase(ref.watch(obd2RepositoryProvider)),
);

final clearDtcUseCaseProvider = Provider(
  (ref) => ClearDtcUseCase(ref.watch(obd2RepositoryProvider)),
);

final saveTripsUseCaseProvider = Provider(
  (ref) => SaveTripUseCase(ref.watch(historyRepositoryProvider)),
);

final getTripsUseCaseProvider = Provider(
  (ref) => GetTripsUseCase(ref.watch(historyRepositoryProvider)),
);
