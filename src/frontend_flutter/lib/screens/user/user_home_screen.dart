import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reservation_model.dart';
import '../../models/space_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_session_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_page_scroll_view.dart';
import '../../widgets/space_card.dart';
import '../../widgets/reservation_card.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  bool _isLoading = true;
  List<ReservationModel> _reservas = [];
  List<SpaceModel> _spaces = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      ApiService.fetchReservas(),
      ApiService.fetchLaboratorios(),
    ]);

    if (!mounted) return;

    setState(() {
      _reservas = results[0] as List<ReservationModel>;
      _spaces = results[1] as List<SpaceModel>;
      _isLoading = false;
    });
  }

  Future<void> _cancelReservation(int id) async {
    final res = await ApiService.cancelReserva(id);
    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva cancelada correctamente.')),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'Error al cancelar reserva.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthSessionService().currentUser;
    final activeRes = _reservas.where((r) => r.status.toUpperCase() != 'CANCELADA').take(2).toList();
    final featuredSpaces = _spaces.take(4).toList();

    return AppLayout(
      currentRoute: '/user/home',
      title: 'LabAcces · Reservas UCEVA',
      subtitle: user != null ? 'Bienvenido, ${user.fullName}' : null,
      mobilePageOwnsScroll: true,
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: AppPageScrollView(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner de bienvenida
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryGreen, AppColors.sidebarActive],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(18, 59, 34, 0.12),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Hola de nuevo, ${user?.nombres ?? 'Estudiante'}!',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Consulta los laboratorios y salas disponibles en el campus universitario y reserva tu lugar.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.sidebarTagline,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.pushReplacementNamed(context, '/user/wizard'),
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Solicitar nueva reserva'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primaryGreen,
                                    elevation: 0,
                                    minimumSize: const Size(200, 42),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Métricas reales adaptables
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 640;
                        if (isMobile) {
                          return Column(
                            children: [
                              _buildStatCard(
                                'Tus Reservas Activas',
                                '${_reservas.where((r) => r.status.toUpperCase() != "CANCELADA").length}',
                                Icons.calendar_month_outlined,
                                AppColors.accentGreen,
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                'Laboratorios en Campus',
                                '${_spaces.length}',
                                Icons.domain_outlined,
                                AppColors.primaryGreen,
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                'Historial Total',
                                '${_reservas.length}',
                                Icons.history_outlined,
                                AppColors.amberText,
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Tus Reservas Activas',
                                '${_reservas.where((r) => r.status.toUpperCase() != "CANCELADA").length}',
                                Icons.calendar_month_outlined,
                                AppColors.accentGreen,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Laboratorios en Campus',
                                '${_spaces.length}',
                                Icons.domain_outlined,
                                AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Historial Total',
                                '${_reservas.length}',
                                Icons.history_outlined,
                                AppColors.amberText,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Próximas reservas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tus próximas reservas',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textStrong),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/user/my-reservations'),
                          child: const Text('Ver todas', style: TextStyle(color: AppColors.accentGreenText, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (activeRes.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: const Text(
                          'No tienes reservas activas por ahora. Haz clic en «Solicitar nueva reserva» para agendar tu espacio.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    else
                      for (final res in activeRes)
                        ReservationCard(
                          reservation: res,
                          onDetails: () => Navigator.pushReplacementNamed(context, '/user/my-reservations'),
                          onCancel: () => _cancelReservation(res.id),
                        ),
                    const SizedBox(height: 28),

                    // Espacios disponibles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Espacios disponibles',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textStrong),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/user/spaces'),
                          child: const Text('Explorar todos', style: TextStyle(color: AppColors.accentGreenText, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (featuredSpaces.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: const Text(
                          'No hay laboratorios registrados en este momento.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 250,
                            ),
                            itemCount: featuredSpaces.length,
                            itemBuilder: (context, index) {
                              final sp = featuredSpaces[index];
                              return SpaceCard(
                                space: sp,
                                onDetails: () {
                                  Navigator.pushNamed(context, '/user/space-detail', arguments: sp);
                                },
                                onReserve: () {
                                  Navigator.pushReplacementNamed(context, '/user/wizard', arguments: sp);
                                },
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textStrong),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
