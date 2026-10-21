import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reservation_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/horizontal_table_scroll.dart';
import '../../widgets/status_badge.dart';

class ReservationHistoryScreen extends StatefulWidget {
  const ReservationHistoryScreen({super.key});

  @override
  State<ReservationHistoryScreen> createState() => _ReservationHistoryScreenState();
}

class _ReservationHistoryScreenState extends State<ReservationHistoryScreen> {
  List<ReservationModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final all = await ApiService.fetchReservas();
    if (!mounted) return;
    setState(() {
      // Filtrar historial (completadas, canceladas o pasadas)
      final now = DateTime.now();
      _history = all.where((r) {
        if (r.status.toLowerCase() == 'cancelada' || r.status.toLowerCase() == 'completada') {
          return true;
        }
        try {
          final resDate = DateTime.parse(r.date);
          return resDate.isBefore(DateTime(now.year, now.month, now.day));
        } catch (_) {
          return false;
        }
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/user/history',
      title: 'Historial de Reservas',
      subtitle: 'Registro histórico de tus usos de espacios anteriores',
      child: RefreshIndicator(
        onRefresh: _loadHistory,
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
                          'Reservas Pasadas y Finalizadas',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textStrong),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Historial sincronizado desde la base de datos.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
                      onPressed: _loadHistory,
                      tooltip: 'Actualizar',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.primaryGreen),
                    ),
                  )
                else if (_history.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.frameBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.history_toggle_off, size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text(
                          'No hay reservas pasadas registradas',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textStrong),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tus reservas canceladas o culminadas aparecerán listadas aquí.',
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
                        DataColumn(label: Text('Espacio Universitario', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Horario', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Motivo', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _history.map((r) {
                        return DataRow(
                          cells: [
                            DataCell(Text(r.spaceName, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(r.date)),
                            DataCell(Text('${r.startTime} – ${r.endTime}')),
                            DataCell(Text(r.purpose ?? 'Académico')),
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
