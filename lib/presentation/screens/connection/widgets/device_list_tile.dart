import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/repositories/bluetooth_repository_impl.dart';
import '../../../../domain/entities/ble_device.dart';
import 'signal_strength_bar.dart';

class DeviceListTile extends StatelessWidget {
  final BleDevice device;
  final bool isConnecting;
  final VoidCallback onTap;

  const DeviceListTile({
    super.key,
    required this.device,
    required this.isConnecting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isElm = BluetoothRepositoryImpl.isLikelyElm327(device.name);
    final level = SignalStrengthBar.levelFromRssi(device.rssi);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isElm
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.cardBackground,
        ),
        child: Icon(
          isElm ? Icons.directions_car : Icons.bluetooth,
          color: isElm ? AppColors.primary : AppColors.textSecondary,
          size: 22,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              device.name,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: isElm ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          // OBD2 badge
          if (isElm)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'OBD2',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            // Barras de señal animadas
            SignalStrengthBar(rssi: device.rssi),
            const SizedBox(width: 8),
            // Etiqueta de calidad
            Text(
              level.label,
              style: TextStyle(
                color: level.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            // Valor numérico dBm
            Text(
              '(${device.rssi} dBm)',
              style: const TextStyle(
                  color: AppColors.textHint, fontSize: 11),
            ),
          ],
        ),
      ),
      trailing: isConnecting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Icon(
              Icons.chevron_right,
              color: isElm ? AppColors.primary : AppColors.textHint,
            ),
      onTap: isConnecting ? null : onTap,
    );
  }
}
