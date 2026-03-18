import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/dtc_code.dart';
import '../../providers/dtc_provider.dart';
import 'widgets/dtc_list_item.dart';

class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dtcState = ref.watch(dtcProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Diagnóstico'),
        actions: [
          // Read DTC button
          IconButton(
            tooltip: 'Leer códigos',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(dtcProvider.notifier).readDtcs(),
          ),
        ],
      ),
      body: dtcState.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('Leyendo códigos de falla…',
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.danger),
                const SizedBox(height: 12),
                Text(e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(dtcProvider.notifier).readDtcs(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (codes) => _DtcContent(codes: codes),
      ),
      bottomNavigationBar: dtcState.hasValue && dtcState.value!.isNotEmpty
          ? _ClearDtcBar()
          : null,
    );
  }
}

class _DtcContent extends StatelessWidget {
  final List<DtcCode> codes;
  const _DtcContent({required this.codes});

  @override
  Widget build(BuildContext context) {
    if (codes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline,
                size: 64, color: AppColors.connected),
            SizedBox(height: 16),
            Text(
              'Sin códigos de falla',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'El vehículo no reporta errores.\nPresiona el botón ↻ para leer.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Summary banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.danger.withOpacity(0.1),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.danger, size: 20),
              const SizedBox(width: 10),
              Text(
                '${codes.length} código${codes.length > 1 ? 's' : ''} de falla detectado${codes.length > 1 ? 's' : ''}',
                style: const TextStyle(
                    color: AppColors.danger, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        // DTC list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: codes.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 12, color: AppColors.divider),
            itemBuilder: (_, i) => DtcListItem(code: codes[i]),
          ),
        ),
      ],
    );
  }
}

class _ClearDtcBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: OutlinedButton.icon(
          icon: const Icon(Icons.delete_sweep),
          label: const Text('Borrar todos los errores'),
          onPressed: () => _confirmClear(context, ref),
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Borrar códigos de falla'),
        content: const Text(
          '¿Deseas borrar todos los códigos DTC y apagar la luz de motor (MIL)?\n\n'
          'Esta acción no puede deshacerse.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success = await ref.read(dtcProvider.notifier).clearDtcs();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Códigos borrados correctamente'
                : 'Error al borrar los códigos'),
            backgroundColor:
                success ? AppColors.connected : AppColors.danger,
          ),
        );
      }
    }
  }
}
