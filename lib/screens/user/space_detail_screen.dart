import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/space_model.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/status_badge.dart';

class SpaceDetailScreen extends StatelessWidget {
  final SpaceModel space;

  const SpaceDetailScreen({super.key, required this.space});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/user/spaces',
      title: 'Detalle del Espacio',
      subtitle: space.name,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con botón de regresar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreenSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(space.icon, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          space.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textStrong),
                        ),
                        Text(
                          space.type,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accentGreenText),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: space.status),
                ],
              ),
              const Divider(color: AppColors.surfaceBorder, height: 32),

              // Detalles en cuadrícula responsiva
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;
                  if (isNarrow) {
                    return Column(
                      children: [
                        _buildDetailItem(
                          Icons.location_on_outlined,
                          'Ubicación en Campus',
                          space.location,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          Icons.people_outline,
                          'Aforo y Capacidad',
                          '${space.capacity} personas permitidas',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          Icons.schedule_outlined,
                          'Horario Habitual',
                          space.schedule,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          Icons.devices_outlined,
                          'Recursos y Equipamiento',
                          space.resources,
                        ),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              Icons.location_on_outlined,
                              'Ubicación en Campus',
                              space.location,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildDetailItem(
                              Icons.people_outline,
                              'Aforo y Capacidad',
                              '${space.capacity} personas permitidas',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              Icons.schedule_outlined,
                              'Horario Habitual',
                              space.schedule,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildDetailItem(
                              Icons.devices_outlined,
                              'Recursos y Equipamiento',
                              space.resources,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 28),

              // Normas de uso
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.frameBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Normas y condiciones de uso:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textStrong),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• El espacio debe reservarse con al menos 24 horas de antelación.\n'
                      '• Presentar carné institucional o documento de identidad al ingresar.\n'
                      '• Se debe registrar la asistencia dentro de los primeros 15 minutos del bloque reservado.',
                      style: TextStyle(fontSize: 12, color: AppColors.textBody, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Acciones responsivas
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(120, 44)),
                    child: const Text('Volver al listado'),
                  ),
                  ElevatedButton.icon(
                    onPressed: space.isAvailable
                        ? () {
                            Navigator.pushReplacementNamed(context, '/user/wizard', arguments: space);
                          }
                        : null,
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: const Text('Solicitar reserva para este espacio'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(220, 44)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.frameBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textStrong)),
            ],
          ),
        ),
      ],
    );
  }
}
