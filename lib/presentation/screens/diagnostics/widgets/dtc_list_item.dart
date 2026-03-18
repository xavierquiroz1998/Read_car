import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/dtc_decoder.dart';
import '../../../../domain/entities/dtc_code.dart';

class DtcListItem extends StatelessWidget {
  final DtcCode code;
  const DtcListItem({super.key, required this.code});

  Color get _severityColor => switch (code.severity) {
        DtcSeverity.powertrain => AppColors.danger,
        DtcSeverity.chassis    => AppColors.warning,
        DtcSeverity.body       => AppColors.primary,
        DtcSeverity.network    => AppColors.textSecondary,
        DtcSeverity.unknown    => AppColors.textHint,
      };

  IconData get _severityIcon => switch (code.severity) {
        DtcSeverity.powertrain => Icons.engineering,
        DtcSeverity.chassis    => Icons.directions_car,
        DtcSeverity.body       => Icons.car_repair,
        DtcSeverity.network    => Icons.device_hub,
        DtcSeverity.unknown    => Icons.help_outline,
      };

  // ── URL helpers ────────────────────────────────────────────────────────────

  /// Abre la URL en el navegador del sistema.
  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Google: "código DTC P0300 solución"
  String get _googleUrl {
    final query = Uri.encodeComponent(
      'código OBD2 ${code.code} ${code.description} causa solución',
    );
    return 'https://www.google.com/search?q=$query';
  }

  /// YouTube: videos de diagnóstico del código
  String get _youtubeUrl {
    final query = Uri.encodeComponent('${code.code} OBD2 diagnóstico solución');
    return 'https://www.youtube.com/results?search_query=$query';
  }

  // ── Bottom sheet de opciones ──────────────────────────────────────────────

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      // Permite que el sheet crezca más allá del 50% de la pantalla
      isScrollControlled: true,
      // Limita la altura máxima al 85% para no cubrir toda la pantalla
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DtcOptionsSheet(
        code: code,
        severityColor: _severityColor,
        severityIcon: _severityIcon,
        onGoogle: () {
          Navigator.pop(context);
          _launch(_googleUrl);
        },
        onYoutube: () {
          Navigator.pop(context);
          _launch(_youtubeUrl);
        },
        onCopy: () {
          Clipboard.setData(ClipboardData(
              text: '${code.code} — ${code.description}'));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código copiado al portapapeles'),
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.cardBackground,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOptions(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _severityColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono de categoría
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _severityColor.withValues(alpha: 0.12),
              ),
              child: Icon(_severityIcon, color: _severityColor, size: 18),
            ),
            const SizedBox(width: 12),

            // Código + descripción
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        code.code,
                        style: TextStyle(
                          color: _severityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _severityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          code.severity.label,
                          style: TextStyle(
                              color: _severityColor, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    code.description,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(code.detectedAt),
                    style: const TextStyle(
                        color: AppColors.textHint, fontSize: 11),
                  ),
                ],
              ),
            ),

            // Botón de búsqueda rápida
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Icon(
                Icons.search,
                color: _severityColor.withValues(alpha: 0.7),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _DtcOptionsSheet extends StatelessWidget {
  final DtcCode code;
  final Color severityColor;
  final IconData severityIcon;
  final VoidCallback onGoogle;
  final VoidCallback onYoutube;
  final VoidCallback onCopy;

  const _DtcOptionsSheet({
    required this.code,
    required this.severityColor,
    required this.severityIcon,
    required this.onGoogle,
    required this.onYoutube,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    // Respeta el espacio del teclado y barra de navegación del sistema
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 32 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Cabecera del código
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: severityColor.withValues(alpha: 0.12),
                ),
                child: Icon(severityIcon, color: severityColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code.code,
                      style: TextStyle(
                        color: severityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      code.description,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),

          // Texto guía
          const Text(
            '¿Qué deseas hacer?',
            style: TextStyle(
                color: AppColors.textHint, fontSize: 12),
          ),
          const SizedBox(height: 12),

          // Opción 1: Google
          _OptionTile(
            icon: Icons.search,
            color: const Color(0xFF4285F4), // Google blue
            title: 'Buscar en Google',
            subtitle: 'Ver causas, síntomas y soluciones',
            onTap: onGoogle,
          ),
          const SizedBox(height: 8),

          // Opción 2: YouTube
          _OptionTile(
            icon: Icons.play_circle_outline,
            color: const Color(0xFFFF0000), // YouTube red
            title: 'Ver en YouTube',
            subtitle: 'Videos de diagnóstico y reparación',
            onTap: onYoutube,
          ),
          const SizedBox(height: 8),

          // Opción 3: Copiar
          _OptionTile(
            icon: Icons.copy,
            color: AppColors.textSecondary,
            title: 'Copiar código',
            subtitle: '${code.code} — ${code.description}',
            onTap: onCopy,
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: color.withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }
}
