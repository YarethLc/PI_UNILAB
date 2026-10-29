import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reservation_model.dart';
import '../../models/space_model.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_page_scroll_view.dart';
import '../../widgets/horizontal_table_scroll.dart';
import '../../widgets/status_badge.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  List<ReservationModel> _reservas = [];
  List<SpaceModel> _spaces = [];
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      ApiService.fetchReservas(),
      ApiService.fetchLaboratorios(),
      ApiService.fetchUsuarios(),
    ]);

    if (!mounted) return;

    setState(() {
      _reservas = results[0] as List<ReservationModel>;
      _spaces = results[1] as List<SpaceModel>;
      _users = results[2] as List<UserModel>;
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
      _loadDashboardData();
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
    final pendingReservations =
        _reservas.where((r) => r.status.toUpperCase() == 'PENDIENTE').toList();

    return AppLayout(
      currentRoute: '/admin/dashboard',
      title: 'Panel Administrativo LabAcces',
      subtitle: 'Administración UCEVA (vista de control general)',
      mobilePageOwnsScroll: true,
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: AppPageScrollView(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPIs Adaptables
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 640;
                          final isTablet = constraints.maxWidth < 900;

                          if (isMobile) {
                            return Column(
                              children: [
                                _buildKpiCard(
                                    'Total Reservas',
                                    '${_reservas.length}',
                                    Icons.calendar_today,
                                    AppColors.accentGreen),
                                const SizedBox(height: 12),
                                _buildKpiCard(
                                    'Pendientes por Aprobar',
                                    '${pendingReservations.length}',
                                    Icons.pending_actions,
                                    AppColors.amberText),
                                const SizedBox(height: 12),
                                _buildKpiCard(
                                    'Espacios Registrados',
                                    '${_spaces.length}',
                                    Icons.meeting_room,
                                    AppColors.primaryGreen),
                                const SizedBox(height: 12),
                                _buildKpiCard(
                                    'Usuarios Totales',
                                    '${_users.length}',
                                    Icons.people,
                                    const Color(0xFF1565C0)),
                              ],
                            );
                          }

                          if (isTablet) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildKpiCard(
                                            'Total Reservas',
                                            '${_reservas.length}',
                                            Icons.calendar_today,
                                            AppColors.accentGreen)),
                                    const SizedBox(width: 14),
                                    Expanded(
                                        child: _buildKpiCard(
                                            'Pendientes por Aprobar',
                                            '${pendingReservations.length}',
                                            Icons.pending_actions,
                                            AppColors.amberText)),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                        child: _buildKpiCard(
                                            'Espacios Registrados',
                                            '${_spaces.length}',
                                            Icons.meeting_room,
                                            AppColors.primaryGreen)),
                                    const SizedBox(width: 14),
                                    Expanded(
                                        child: _buildKpiCard(
                                            'Usuarios Totales',
                                            '${_users.length}',
                                            Icons.people,
                                            const Color(0xFF1565C0))),
                                  ],
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(
                                  child: _buildKpiCard(
                                      'Total Reservas',
                                      '${_reservas.length}',
                                      Icons.calendar_today,
                                      AppColors.accentGreen)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildKpiCard(
                                      'Pendientes por Aprobar',
                                      '${pendingReservations.length}',
                                      Icons.pending_actions,
                                      AppColors.amberText)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildKpiCard(
                                      'Espacios Registrados',
                                      '${_spaces.length}',
                                      Icons.meeting_room,
                                      AppColors.primaryGreen)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildKpiCard(
                                      'Usuarios Totales',
                                      '${_users.length}',
                                      Icons.people,
                                      const Color(0xFF1565C0))),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // Acciones Rápidas
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Accesos de Gestión',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 14),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 680) {
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: _buildQuickAction(
                                                  context,
                                                  'Gestionar Reservas',
                                                  Icons.assignment,
                                                  '/admin/reservations')),
                                          const SizedBox(width: 12),
                                          Expanded(
                                              child: _buildQuickAction(
                                                  context,
                                                  'Gestionar Espacios',
                                                  Icons.room_preferences,
                                                  '/admin/spaces')),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                              child: _buildQuickAction(
                                                  context,
                                                  'Configurar Horarios',
                                                  Icons.schedule,
                                                  '/admin/schedules')),
                                          const SizedBox(width: 12),
                                          Expanded(
                                              child: _buildQuickAction(
                                                  context,
                                                  'Ver Reportes',
                                                  Icons.bar_chart,
                                                  '/admin/reports')),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                                return Row(
                                  children: [
                                    Expanded(
                                        child: _buildQuickAction(
                                            context,
                                            'Gestionar Reservas',
                                            Icons.assignment,
                                            '/admin/reservations')),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: _buildQuickAction(
                                            context,
                                            'Gestionar Espacios',
                                            Icons.room_preferences,
                                            '/admin/spaces')),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: _buildQuickAction(
                                            context,
                                            'Configurar Horarios',
                                            Icons.schedule,
                                            '/admin/schedules')),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: _buildQuickAction(
                                            context,
                                            'Ver Reportes',
                                            Icons.bar_chart,
                                            '/admin/reports')),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Solicitudes Pendientes
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                const Text(
                                  'Solicitudes Pendientes en BD',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textStrong),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(
                                          context, '/admin/reservations'),
                                  child: const Text('Ver todas las reservas',
                                      style: TextStyle(
                                          color: AppColors.accentGreenText)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (pendingReservations.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                    'No hay solicitudes pendientes en este momento.',
                                    style:
                                        TextStyle(color: AppColors.textMuted)),
                              )
                            else
                              HorizontalTableScroll(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                      AppColors.frameBg),
                                  columns: const [
                                    DataColumn(label: Text('Espacio')),
                                    DataColumn(label: Text('Fecha y Hora')),
                                    DataColumn(label: Text('Solicitante')),
                                    DataColumn(label: Text('Motivo')),
                                    DataColumn(label: Text('Estado')),
                                  ],
                                  rows: pendingReservations.map((r) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(r.spaceName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600))),
                                        DataCell(Text(
                                            '${r.date} (${r.startTime} – ${r.endTime})')),
                                        DataCell(
                                            Text(r.userName ?? 'Estudiante')),
                                        DataCell(
                                            Text(r.purpose ?? 'Académico')),
                                        DataCell(StatusBadge(status: r.status)),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String val, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  val,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textStrong),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
      BuildContext context, String title, IconData icon, String route) {
    return InkWell(
      onTap: () => Navigator.pushReplacementNamed(context, route),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.frameBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.accentGreenText, size: 22),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textStrong),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
