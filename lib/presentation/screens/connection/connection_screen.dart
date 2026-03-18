import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/ble_device.dart';
import '../../navigation/routes.dart';
import '../../providers/bluetooth_provider.dart';
import 'widgets/device_list_tile.dart';
import 'widgets/signal_strength_bar.dart';

class ConnectionScreen extends ConsumerWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionProvider);
    final scanResults = ref.watch(scanResultsProvider);

    // Navigate to dashboard when connected and initialized
    ref.listen(connectionProvider, (prev, next) {
      if (next.status == ConnectionStatus.connected) {
        context.go(Routes.dashboard);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Conectar OBD2'),
        actions: [
          if (connectionState.status == ConnectionStatus.connected)
            TextButton.icon(
              onPressed: () =>
                  ref.read(connectionProvider.notifier).disconnect(),
              icon: const Icon(Icons.link_off, color: AppColors.danger),
              label: const Text('Desconectar',
                  style: TextStyle(color: AppColors.danger)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status card
            _StatusCard(status: connectionState.status),
            const SizedBox(height: 12),

            // Signal quality card — visible solo cuando hay dispositivo conectado
            if (connectionState.connectedDevice != null)
              _SignalCard(device: connectionState.connectedDevice!),
            if (connectionState.connectedDevice != null)
              const SizedBox(height: 12),

            // Error message
            if (connectionState.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        connectionState.errorMessage!,
                        style: const TextStyle(
                            color: AppColors.danger, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            if (connectionState.errorMessage != null) const SizedBox(height: 16),

            // Scan button
            ElevatedButton.icon(
              onPressed: connectionState.status == ConnectionStatus.connecting
                  ? null
                  : () => ref.refresh(scanResultsProvider),
              icon: connectionState.status == ConnectionStatus.scanning
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.bluetooth_searching),
              label: Text(connectionState.status == ConnectionStatus.scanning
                  ? 'Buscando…'
                  : 'Buscar dispositivos'),
            ),

            const SizedBox(height: 20),
            Text(
              'Dispositivos encontrados',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),

            // Device list
            Expanded(
              child: scanResults.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Text('Error al escanear: $e',
                      style:
                          const TextStyle(color: AppColors.textSecondary)),
                ),
                data: (devices) {
                  if (devices.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bluetooth_disabled,
                              size: 48, color: AppColors.textHint),
                          SizedBox(height: 12),
                          Text(
                            'No se encontraron dispositivos.\nPresiona "Buscar dispositivos".',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textHint),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: devices.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (_, i) => DeviceListTile(
                      device: devices[i],
                      isConnecting:
                          connectionState.status == ConnectionStatus.connecting,
                      onTap: () => ref
                          .read(connectionProvider.notifier)
                          .connectTo(devices[i]),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            const _HelpText(),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final ConnectionStatus status;
  const _StatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (status) {
      ConnectionStatus.disconnected => (
          AppColors.disconnected,
          Icons.bluetooth_disabled,
          'Desconectado'
        ),
      ConnectionStatus.scanning => (
          AppColors.scanning,
          Icons.bluetooth_searching,
          'Buscando…'
        ),
      ConnectionStatus.connecting => (
          AppColors.warning,
          Icons.bluetooth_connected,
          'Conectando…'
        ),
      ConnectionStatus.connected => (
          AppColors.connected,
          Icons.bluetooth_connected,
          'Conectado'
        ),
      ConnectionStatus.error => (
          AppColors.danger,
          Icons.error_outline,
          'Error de conexión'
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _HelpText extends StatelessWidget {
  const _HelpText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Conecta el adaptador ELM327 al puerto OBD2 del vehículo\n'
      'y asegúrate de que el Bluetooth esté habilitado.',
      textAlign: TextAlign.center,
      style: const TextStyle(color: AppColors.textHint, fontSize: 12),
    );
  }
}

/// Card de calidad de señal del dispositivo conectado.
class _SignalCard extends StatelessWidget {
  final BleDevice device;
  const _SignalCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final level = SignalStrengthBar.levelFromRssi(device.rssi);

    // Consejo según calidad de señal
    final tip = switch (level) {
      SignalLevel.excellent => 'Señal óptima. Comunicación estable.',
      SignalLevel.good      => 'Buena señal. Sin problemas esperados.',
      SignalLevel.fair      => 'Señal regular. Acerca el teléfono al adaptador.',
      SignalLevel.weak      => 'Señal débil. Pueden ocurrir desconexiones.',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: level.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: level.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: barras + etiqueta + dBm
          Row(
            children: [
              SignalStrengthBar(
                rssi: device.rssi,
                barWidth: 6,
                maxBarHeight: 22,
                spacing: 3,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Señal Bluetooth',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                  ),
                  Text(
                    '${level.label}  ·  ${device.rssi} dBm',
                    style: TextStyle(
                      color: level.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Indicador de potencia en círculo
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: level.color.withValues(alpha: 0.15),
                ),
                child: Icon(Icons.bluetooth_connected,
                    color: level.color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 8),
          // Consejo de uso
          Row(
            children: [
              Icon(
                level == SignalLevel.weak || level == SignalLevel.fair
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                size: 14,
                color: level.color,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  tip,
                  style: TextStyle(color: level.color, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
