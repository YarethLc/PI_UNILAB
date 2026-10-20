import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/reservation_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/app_page_scroll_view.dart';
import '../../widgets/reservation_card.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  List<ReservationModel> _reservas = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todas';

  final List<String> filters = ['Todas', 'Confirmada', 'Pendiente', 'Cancelada'];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    final list = await ApiService.fetchReservas();
    if (!mounted) return;
    setState(() {
      _reservas = list;
      _isLoading = false;
    });
  }

  void _showDetailsDialog(ReservationModel res) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(res.spaceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📅 Fecha: ${res.date}'),
            const SizedBox(height: 6),
            Text('⏰ Horario: ${res.startTime} – ${res.endTime}'),
            const SizedBox(height: 6),
            Text('📌 Estado: ${res.status}'),
            const SizedBox(height: 6),
            Text('🎯 Motivo: ${res.purpose ?? "Actividad académica"}'),
            const SizedBox(height: 6),
            Text('👤 Solicitante: ${res.userName ?? "Tú"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(ReservationModel res) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cancelar reserva?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Seguro que deseas cancelar tu reserva de «${res.spaceName}» para el ${res.date}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await ApiService.cancelReserva(res.id);
              if (!mounted) return;
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reserva cancelada correctamente en el sistema.')),
                );
                _loadReservations();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['error'] ?? 'No se pudo cancelar la reserva.')),
                );
              }
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _reservas.where((r) {
      if (_selectedFilter == 'Todas') return true;
      return r.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return AppLayout(
      currentRoute: '/user/my-reservations',
      title: 'Mis Reservas',
      subtitle: 'Administra tus solicitudes activas guardadas en la base de datos',
      mobilePageOwnsScroll: true,
      child: RefreshIndicator(
        onRefresh: _loadReservations,
        child: AppPageScrollView(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        // Filtros
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: filters.map((f) {
                              final isSel = _selectedFilter == f;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(f),
                                  selected: isSel,
                                  selectedColor: AppColors.accentGreen,
                                  backgroundColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: isSel ? Colors.white : AppColors.textBody,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                  onSelected: (val) => setState(() => _selectedFilter = f),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushReplacementNamed(context, '/user/wizard'),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Nueva reserva'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(140, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (list.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 48, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              'No se encontraron reservas en esta categoría',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 4),
                            Text('Tus reservas creadas se guardan en el backend y aparecerán aquí.', style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                      )
                    else
                      for (final res in list)
                        ReservationCard(
                          reservation: res,
                          onDetails: () => _showDetailsDialog(res),
                          onCancel: () => _confirmCancel(res),
                        ),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}
