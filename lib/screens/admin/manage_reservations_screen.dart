import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reservation_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/horizontal_table_scroll.dart';
import '../../widgets/status_badge.dart';

class ManageReservationsScreen extends StatefulWidget {
  const ManageReservationsScreen({super.key});

  @override
  State<ManageReservationsScreen> createState() => _ManageReservationsScreenState();
}

class _ManageReservationsScreenState extends State<ManageReservationsScreen> {
  List<ReservationModel> _reservas = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadReservas();
  }

  Future<void> _loadReservas() async {
    setState(() => _isLoading = true);
    final list = await ApiService.fetchReservas();
    if (!mounted) return;
    setState(() {
      _reservas = list;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    final result = await ApiService.updateEstadoReserva(id, newStatus);
    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reserva #$id actualizada a: $newStatus')),
      );
      _loadReservas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al actualizar reserva.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _reservas.where((r) {
      if (_selectedFilter == 'Todas') return true;
      return r.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return AppLayout(
      currentRoute: '/admin/reservations',
      title: 'Gestionar Reservas',
      subtitle: 'Aprobación, rechazo y seguimiento de solicitudes universitarias en BD',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReservas,
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
                          const Text('Listado de Reservas en Base de Datos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: _selectedFilter,
                            items: ['Todas', 'Pendiente', 'Confirmada', 'Cancelada']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedFilter = val!),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (list.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text('No hay reservas registradas en esta categoría.', style: TextStyle(color: AppColors.textMuted)),
                          ),
                        )
                      else
                        HorizontalTableScroll(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(AppColors.frameBg),
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Espacio')),
                              DataColumn(label: Text('Fecha y Horario')),
                              DataColumn(label: Text('Solicitante')),
                              DataColumn(label: Text('Motivo')),
                              DataColumn(label: Text('Estado')),
                              DataColumn(label: Text('Acciones')),
                            ],
                            rows: list.map((r) {
                              final isPending = r.status.toUpperCase() == 'PENDIENTE';
                              return DataRow(
                                cells: [
                                  DataCell(Text('#${r.id}')),
                                  DataCell(Text(r.spaceName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text('${r.date}\n${r.startTime} – ${r.endTime}')),
                                  DataCell(Text(r.userName ?? 'Estudiante')),
                                  DataCell(Text(r.purpose ?? 'Académico')),
                                  DataCell(StatusBadge(status: r.status)),
                                  DataCell(
                                    Row(
                                      children: [
                                        if (isPending) ...[
                                          IconButton(
                                            icon: const Icon(Icons.check_circle_outline, color: AppColors.accentGreen),
                                            tooltip: 'Aprobar reserva',
                                            onPressed: () => _updateStatus(r.id, 'CONFIRMADA'),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                                            tooltip: 'Rechazar reserva',
                                            onPressed: () => _updateStatus(r.id, 'CANCELADA'),
                                          ),
                                        ] else
                                          const Text('—', style: TextStyle(color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
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
