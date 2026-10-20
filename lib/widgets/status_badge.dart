import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showSuffix;

  const StatusBadge({
    super.key,
    required this.status,
    this.showSuffix = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    final s = status.toLowerCase();

    if (s.contains('confirmada') || s == 'disponible' || s.contains('activo')) {
      bg = AppColors.statusConfirmadaBg;
      fg = AppColors.statusConfirmadaText;
    } else if (s.contains('pendiente') || s.contains('ocupado')) {
      bg = AppColors.statusPendienteBg;
      fg = AppColors.statusPendienteText;
    } else if (s.contains('cancelada') || s.contains('inactivo')) {
      bg = AppColors.statusCanceladaBg;
      fg = AppColors.statusCanceladaText;
    } else {
      bg = AppColors.statusFinalizadaBg;
      fg = AppColors.statusFinalizadaText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
