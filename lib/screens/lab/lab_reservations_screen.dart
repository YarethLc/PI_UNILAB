import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reservation_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/horizontal_table_scroll.dart';
import '../../widgets/status_badge.dart';

class LabReservationsScreen extends StatefulWidget {
  const LabReservationsScreen({super.key});

  @override
  State<LabReservationsScreen> createState() => _LabReservationsScreenState();
}

class _LabReservationsScreenState extends State<LabReservationsScreen> {
  List<ReservationModel> _labReservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final allReservas = await ApiService.fetchReservas();
    if (!mounted) return;
    setState(() {
      // Filtrar reservas que corresponden a laboratorios o mostrar todas si no hay filtro estricto
      _labReservations = allReservas.where((r) =>
        r.spaceName.toLowerCase().contains('lab') ||
        r.spaceName.toLowerCase().contains('laboratorio') ||
        r.spaceName.toLowerCase().contains('sala') ||
        r.spaceName.isNotEmpty
      ).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/lab/reservations',
      title: 'Reservas Asignadas a Laboratorio',
      subtitle: 'Control de sesiones prácticas y talleres programados en laboratorios',
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sesiones Programadas en Laboratorios',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textStrong),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Listado de reservas en tiempo real desde la base de datos.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
                      onPressed: _loadData,
                      tooltip: 'Actualizar',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ),
                  )
                else if (_labReservations.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.frameBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.event_busy, size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text(
                          'No hay reservas registradas para laboratorios',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textStrong),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Las reservas creadas por estudiantes aparecerán aquí automáticamente.',
                          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                else
                  HorizontalTableScroll(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppColors.frameBg),
                      columns: const [
                        DataColumn(label: Text('Laboratorio', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Fecha y Horario', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Solicitante', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Motivo / Práctica', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _labReservations.map((r) {
                        return DataRow(
                          cells: [
                            DataCell(Text(r.spaceName, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text('${r.date}\n${r.startTime} – ${r.endTime}')),
                            DataCell(Text(r.userName ?? 'Estudiante')),
                            DataCell(Text(r.purpose ?? 'Práctica académica')),
                            DataCell(StatusBadge(status: r.status)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
