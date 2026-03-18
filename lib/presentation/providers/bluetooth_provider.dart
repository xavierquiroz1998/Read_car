import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../data/repositories/bluetooth_repository_impl.dart';
import '../../data/repositories/obd2_repository_impl.dart';
import '../../domain/entities/ble_device.dart';
import 'providers.dart';

// ── Connection State ──────────────────────────────────────────────────────────

enum ConnectionStatus { disconnected, scanning, connecting, connected, error }

class ConnectionState {
  final ConnectionStatus status;
  final String? errorMessage;
  final BleDevice? connectedDevice;

  const ConnectionState({
    this.status = ConnectionStatus.disconnected,
    this.errorMessage,
    this.connectedDevice,
  });

  ConnectionState copyWith({
    ConnectionStatus? status,
    String? errorMessage,
    BleDevice? connectedDevice,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      connectedDevice: connectedDevice ?? this.connectedDevice,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ConnectionNotifier extends StateNotifier<ConnectionState> {
  final Ref _ref;
  StreamSubscription<bool>? _connectionSub;

  ConnectionNotifier(this._ref) : super(const ConnectionState());

  Future<void> connectTo(BleDevice device) async {
    state = state.copyWith(status: ConnectionStatus.connecting);

    final useCase = _ref.read(connectDeviceUseCaseProvider);
    final result = await useCase(device.id);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ConnectionStatus.error,
          errorMessage: failure.message,
        );
      },
      (_) async {
        state = state.copyWith(
          status: ConnectionStatus.connected,
          connectedDevice: device.copyWith(isConnected: true),
        );

        // En modo demo el OBD2 mock se inicializa directamente.
        // En modo real se conectan las características BLE al adaptador.
        if (!kDemoMode) {
          final btRepo = _ref.read(bluetoothRepositoryProvider)
              as BluetoothRepositoryImpl;
          final obd2Repo = _ref.read(obd2RepositoryProvider)
              as Obd2RepositoryImpl;
          if (btRepo.connectedDevice != null) {
            obd2Repo.attachDevice(btRepo.connectedDevice!);
          }
        }
        await _ref.read(initializeObd2UseCaseProvider).call();

        // Watch for unexpected disconnections
        _connectionSub = _ref
            .read(bluetoothRepositoryProvider)
            .connectionStateStream()
            .listen((connected) {
          if (!connected && state.status == ConnectionStatus.connected) {
            state = const ConnectionState(
                status: ConnectionStatus.disconnected,
                errorMessage: 'Device disconnected unexpectedly');
          }
        });
      },
    );
  }

  Future<void> disconnect() async {
    await _ref.read(bluetoothRepositoryProvider).disconnectDevice();
    _ref.read(obd2RepositoryProvider).dispose();
    _connectionSub?.cancel();
    state = const ConnectionState();
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    super.dispose();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final connectionProvider =
    StateNotifierProvider<ConnectionNotifier, ConnectionState>(
  (ref) => ConnectionNotifier(ref),
);

/// Live scan results filtered to non-empty names.
final scanResultsProvider = StreamProvider<List<BleDevice>>(
  (ref) {
    final useCase = ref.watch(scanDevicesUseCaseProvider);
    return useCase();
  },
);
