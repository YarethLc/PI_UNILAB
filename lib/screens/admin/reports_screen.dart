import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/space_model.dart';
import '../../models/reservation_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_page_scroll_view.dart';
import '../../widgets/simple_charts.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<SpaceModel> _spaces = [];
  List<ReservationModel> _reservas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      ApiService.fetchLaboratorios(),
      ApiService.fetchReservas(),
    ]);

    if (!mounted) return;
    setState(() {
      _spaces = results[0] as List<SpaceModel>;
      _reservas = results[1] as List<ReservationModel>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalReservas = _reservas.length;
    final activas = _reservas
        .where((r) =>
            r.status.toLowerCase() == 'confirmada' ||
            r.status.toLowerCase() == 'aprobada' ||
            r.status.toLowerCase() == 'activa')
        .length;
    final canceladas = _reservas
        .where((r) =>
            r.status.toLowerCase() == 'cancelada' ||
            r.status.toLowerCase() == 'rechazada')
        .length;
    final tasaConfirmacion = totalReservas > 0
        ? ((activas / totalReservas) * 100).toStringAsFixed(1)
        : '100.0';

    // Agrupar reservas por espacio
    final spaceCountMap = <String, int>{};
    for (final r in _reservas) {
      spaceCountMap[r.spaceName] = (spaceCountMap[r.spaceName] ?? 0) + 1;
    }

    // Distribución por estado para el gráfico de pastel
    final statusCounts = <String, int>{};
    for (final r in _reservas) {
      final raw = r.status.toLowerCase().trim();
      final normalized = (raw == 'aprobada' || raw == 'activa')
          ? 'confirmada'
          : (raw == 'rechazada' ? 'cancelada' : raw);
      statusCounts[normalized] = (statusCounts[normalized] ?? 0) + 1;
    }

    const statusLabels = <String, String>{
      'confirmada': 'Confirmadas',
      'pendiente': 'Pendientes',
      'cancelada': 'Canceladas',
      'finalizada': 'Finalizadas',
    };
    const statusColors = <String, Color>{
      'confirmada': AppColors.accentGreen,
      'pendiente': Color(0xFFE0A100),
      'cancelada': AppColors.error,
      'finalizada': Color(0xFF3E6FB0),
    };

    final statusEntries = statusLabels.entries
        .map(
          (entry) => ChartEntry(
            label: entry.value,
            value: (statusCounts[entry.key] ?? 0).toDouble(),
            color: statusColors[entry.key]!,
          ),
        )
        .toList();

    // Demanda por laboratorio para el gráfico de barras
    final labRanking = spaceCountMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    const barPalette = <Color>[
      AppColors.accentGreen,
      AppColors.primaryGreen,
      Color(0xFF4B9E6A),
      Color(0xFF7BBE93),
      Color(0xFF2E7D4F),
      Color(0xFF9ACCA9),
    ];
    final barEntries = <ChartEntry>[
      for (var i = 0; i < labRanking.length; i++)
        ChartEntry(
          label: labRanking[i].key,
          value: labRanking[i].value.toDouble(),
          color: barPalette[i % barPalette.length],
        ),
    ];

    return AppLayout(
      currentRoute: '/admin/reports',
      title: 'Estadísticas y Reportes',
      subtitle:
          'Métricas de ocupación y cumplimiento de reservas en campus UCEVA',
      mobilePageOwnsScroll: true,
      child: RefreshIndicator(
        onRefresh: _loadMetrics,
        child: AppPageScrollView(
          child: _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen),
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...[
                        // Resumen de Métricas Adaptable
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 680;
                            if (isMobile) {
                              return Column(
                                children: [
                                  _buildReportMetric(
                                    'Tasa de Confirmación',
                                    '$tasaConfirmacion%',
                                    '$activas de $totalReservas reservas',
                                    Icons.check_circle_outline,
                                    AppColors.accentGreen,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildReportMetric(
                                    'Total Reservas',
                                    '$totalReservas',
                                    'Registradas en el sistema',
                                    Icons.calendar_month_outlined,
                                    AppColors.primaryGreen,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildReportMetric(
                                    'Canceladas',
                                    '$canceladas',
                                    'Solicitudes declinadas',
                                    Icons.cancel_outlined,
                                    AppColors.amberText,
                                  ),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildReportMetric(
                                    'Tasa de Confirmación',
                                    '$tasaConfirmacion%',
                                    '$activas de $totalReservas reservas',
                                    Icons.check_circle_outline,
                                    AppColors.accentGreen,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildReportMetric(
                                    'Total Reservas',
                                    '$totalReservas',
                                    'Registradas en el sistema',
                                    Icons.calendar_month_outlined,
                                    AppColors.primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildReportMetric(
                                    'Canceladas',
                                    '$canceladas',
                                    'Solicitudes declinadas',
                                    Icons.cancel_outlined,
                                    AppColors.amberText,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Gráficos de pastel y barras
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 760;

                            final pieCard = _buildChartCard(
                              title: 'Reservas por estado',
                              subtitle: 'Distribución de las solicitudes registradas',
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 24,
                                runSpacing: 16,
                                children: [
                                  DonutChart(
                                    entries: statusEntries,
                                    size: 170,
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        for (final entry in statusEntries)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: entry.color,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    entry.label,
                                                    style: const TextStyle(
                                                      fontSize: 12.5,
                                                      color: AppColors.textBody,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  entry.value.toStringAsFixed(0),
                                                  style: const TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textStrong,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );

                            final barCard = _buildChartCard(
                              title: 'Demanda por laboratorio',
                              subtitle:
                                  'Número de reservas registradas por espacio',
                              child: HorizontalBarChart(entries: barEntries),
                            );

                            if (!isWide) {
                              return Column(
                                children: [
                                  pieCard,
                                  const SizedBox(height: 16),
                                  barCard,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: pieCard),
                                const SizedBox(width: 16),
                                Expanded(child: barCard),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Top Espacios Más Solicitados
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Espacios con Mayor Demanda',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textStrong),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Ranking de ocupación basado en las solicitudes reales procesadas:',
                                style: TextStyle(
                                    color: AppColors.textMuted, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              if (_spaces.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                      'No hay espacios registrados en la base de datos.'),
                                )
                              else
                                for (final sp in _spaces) ...[
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${sp.icon} ${sp.name}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              '${spaceCountMap[sp.name] ?? 0} reservas',
                                              style: const TextStyle(
                                                color:
                                                    AppColors.accentGreenText,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        LinearProgressIndicator(
                                          value: totalReservas > 0
                                              ? (((spaceCountMap[sp.name] ??
                                                          0) /
                                                      totalReservas))
                                                  .clamp(0.05, 1.0)
                                              : 0.1,
                                          backgroundColor:
                                              AppColors.surfaceBorder,
                                          color: AppColors.accentGreen,
                                          minHeight: 6,
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildReportMetric(
      String title, String val, String subtitle, IconData icon, Color color) {
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
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textStrong),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
