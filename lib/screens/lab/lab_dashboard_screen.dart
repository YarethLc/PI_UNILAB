import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reservation_model.dart';
import '../../models/space_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/status_badge.dart';

class LabDashboardScreen extends StatefulWidget {
  const LabDashboardScreen({super.key});

  @override
  State<LabDashboardScreen> createState() => _LabDashboardScreenState();
}

class _LabDashboardScreenState extends State<LabDashboardScreen> {
  List<SpaceModel> _labSpaces = [];
  List<ReservationModel> _labReservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLabData();
  }

  Future<void> _loadLabData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      ApiService.fetchLaboratorios(),
      ApiService.fetchReservas(),
    ]);

    if (!mounted) return;

    setState(() {
      _labSpaces = results[0] as List<SpaceModel>;
      _labReservations = results[1] as List<ReservationModel>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/lab/dashboard',
      title: 'Panel de Laboratorio',
      subtitle: 'Encargado de Laboratorio (control de prácticas y estaciones)',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLabData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen Adaptable
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 640;
                        if (isMobile) {
                          return Column(
                            children: [
                              _buildKpiCard('Laboratorios Registrados', '${_labSpaces.length}', Icons.science_outlined, AppColors.primaryGreen),
                              const SizedBox(height: 12),
                              _buildKpiCard('Reservas Programadas', '${_labReservations.length}', Icons.biotech_outlined, AppColors.accentGreen),
                              const SizedBox(height: 12),
                              _buildKpiCard('Capacidad Total', '${_labSpaces.fold(0, (sum, s) => sum + s.capacity)} personas', Icons.people_outline, AppColors.amberText),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: _buildKpiCard('Laboratorios Registrados', '${_labSpaces.length}', Icons.science_outlined, AppColors.primaryGreen)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildKpiCard('Reservas Programadas', '${_labReservations.length}', Icons.biotech_outlined, AppColors.accentGreen)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildKpiCard('Capacidad Total', '${_labSpaces.fold(0, (sum, s) => sum + s.capacity)} personas', Icons.people_outline, AppColors.amberText)),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),

                    // Estado Actual de los Laboratorios
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estado de Laboratorios UCEVA en Base de Datos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (_labSpaces.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text('No hay laboratorios registrados por ahora.', style: TextStyle(color: AppColors.textMuted)),
                            )
                          else
                            for (final lab in _labSpaces)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.frameBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text(lab.icon, style: const TextStyle(fontSize: 24)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  lab.name,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '${lab.location} · Capacidad: ${lab.capacity} personas',
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusBadge(status: lab.status),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
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
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textStrong),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 24),
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
}
