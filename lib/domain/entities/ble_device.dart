import 'package:equatable/equatable.dart';

/// Domain-level Bluetooth device — decoupled from flutter_blue_plus types.
class BleDevice extends Equatable {
  final String id;          // platform device ID
  final String name;
  final int rssi;           // signal strength dBm
  final bool isConnected;

  const BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
    this.isConnected = false,
  });

  BleDevice copyWith({
    String? id,
    String? name,
    int? rssi,
    bool? isConnected,
  }) {
    return BleDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  @override
  List<Object?> get props => [id, name, rssi, isConnected];
}
