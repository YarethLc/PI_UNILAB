import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/reservation_model.dart';
import 'status_badge.dart';

class ReservationCard extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback onDetails;
  final VoidCallback? onCancel;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onDetails,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final canCancel = reservation.status == 'Confirmada' || reservation.status == 'Pendiente';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  reservation.spaceName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textStrong,
                  ),
                ),
              ),
              StatusBadge(status: reservation.status),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    reservation.date,
                    style: const TextStyle(fontSize: 13, color: AppColors.textBody),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    '${reservation.startTime} – ${reservation.endTime}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textBody),
                  ),
                ],
              ),
            ],
          ),
          if (reservation.purpose != null) ...[
            const SizedBox(height: 6),
            Text(
              'Motivo: ${reservation.purpose}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSoft, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onDetails,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(90, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Detalles', style: TextStyle(fontSize: 12)),
                ),
                if (canCancel && onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      minimumSize: const Size(80, 32),
                    ),
                    child: const Text('Cancelar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
