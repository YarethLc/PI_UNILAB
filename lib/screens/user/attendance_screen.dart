import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/space_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/horizontal_table_scroll.dart';
import '../../widgets/status_badge.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<SpaceModel> _spaces = [];
  List<Map<String, dynamic>> _history = [];

  String? _selectedSpace;
  bool _isLoadingSpaces = true;
  bool _isLoadingHistory = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadSpaces(),
      _loadHistory(),
    ]);
  }

  Future<void> _loadSpaces() async {
    try {
      final spaces = await ApiService.fetchLaboratorios();

      if (!mounted) return;

      setState(() {
        _spaces = spaces;

        if (_spaces.isNotEmpty && !_spaces.any((s) => s.id == _selectedSpace)) {
          _selectedSpace = _spaces.first.id;
        }

        _isLoadingSpaces = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoadingSpaces = false);
      _showMessage('No se pudieron cargar los laboratorios.');
    }
  }

  Future<void> _loadHistory() async {
    if (mounted) {
      setState(() => _isLoadingHistory = true);
    }

    try {
      final history = await ApiService.fetchHistorialAsistencia();

      if (!mounted) return;

      setState(() {
        _history = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoadingHistory = false);
      _showMessage('No se pudo cargar el historial: $e');
    }
  }

  Future<void> _registerEntry() async {
    if (_selectedSpace == null) {
      _showMessage('Selecciona un laboratorio.');
      return;
    }

    final idLaboratorio = int.tryParse(_selectedSpace!);

    if (idLaboratorio == null) {
      _showMessage('El laboratorio seleccionado no tiene un ID válido.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await ApiService.registrarEntrada(
        idLaboratorio: idLaboratorio,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showMessage(
          result['mensaje'] ?? 'Entrada registrada correctamente.',
          success: true,
        );

        await _loadHistory();
      } else {
        _showMessage(
          result['error'] ?? 'No se pudo registrar la entrada.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _registerExit() async {
    setState(() => _isSubmitting = true);

    try {
      final result = await ApiService.registrarSalida();

      if (!mounted) return;

      if (result['success'] == true) {
        _showMessage(
          result['mensaje'] ?? 'Salida registrada correctamente.',
          success: true,
        );

        await _loadHistory();
      } else {
        _showMessage(
          result['error'] ?? 'No se pudo registrar la salida.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? AppColors.accentGreen : AppColors.error,
      ),
    );
  }

  String _formatDateTime(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '—';
    }

    final text = value.toString();

    // El backend devuelve la hora local de Colombia como texto.
    if (text.contains('T')) {
      final parts = text.split('T');
      final date = parts[0];
      final time = parts[1].length >= 5 ? parts[1].substring(0, 5) : parts[1];

      return '$date · $time';
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final hasOpenAttendance = _history.any((a) {
      final salida = a['hora_salida'];
      return salida == null || salida.toString().trim().isEmpty;
    });

    return AppLayout(
      currentRoute: '/user/attendance',
      title: 'Control de Asistencia',
      subtitle: 'Registra tu llegada y salida del laboratorio',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  const Row(
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        color: AppColors.accentGreen,
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Control de asistencia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textStrong,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona el laboratorio donde te encuentras y registra tu entrada. '
                    'Al terminar, registra tu salida.',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoadingSpaces)
                    const LinearProgressIndicator(
                      color: AppColors.primaryGreen,
                    )
                  else if (_spaces.isEmpty)
                    const Text(
                      'No se encontraron laboratorios disponibles.',
                    )
                  else
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedSpace,
                      decoration: const InputDecoration(
                        labelText: 'Laboratorio',
                      ),
                      items: _spaces.map((space) {
                        return DropdownMenuItem<String>(
                          value: space.id,
                          child: Text(
                            space.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: _isSubmitting
                          ? null
                          : (value) {
                              setState(() => _selectedSpace = value);
                            },
                    ),
                  const SizedBox(height: 20),
                  if (hasOpenAttendance)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Tienes una asistencia abierta. Registra tu salida al terminar.',
                      ),
                    ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 500;

                      final entryButton = ElevatedButton.icon(
                        onPressed: _isSubmitting ||
                                _isLoadingSpaces ||
                                _spaces.isEmpty ||
                                hasOpenAttendance
                            ? null
                            : _registerEntry,
                        icon: const Icon(Icons.login),
                        label: const Text('Registrar entrada'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                      );

                      final exitButton = OutlinedButton.icon(
                        onPressed: _isSubmitting || !hasOpenAttendance
                            ? null
                            : _registerExit,
                        icon: const Icon(Icons.logout),
                        label: const Text('Registrar salida'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                      );

                      if (narrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            entryButton,
                            const SizedBox(height: 12),
                            exitButton,
                            if (_isSubmitting) ...[
                              const SizedBox(height: 12),
                              const LinearProgressIndicator(),
                            ],
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: entryButton),
                          const SizedBox(width: 12),
                          Expanded(child: exitButton),
                          if (_isSubmitting)
                            const Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                    'Historial de asistencias',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textStrong,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoadingHistory)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No hay asistencias registradas.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  else
                    HorizontalTableScroll(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.frameBg,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Laboratorio',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Entrada',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Salida',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Estado',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: _history.map((attendance) {
                          final exit = attendance['hora_salida'];
                          final isOpen = exit == null;

                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  (attendance['laboratorio'] ??
                                          attendance['nombre_laboratorio'] ??
                                          'Laboratorio')
                                      .toString(),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _formatDateTime(
                                    attendance['hora_entrada'],
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(_formatDateTime(exit)),
                              ),
                              DataCell(
                                StatusBadge(
                                  status: isOpen ? 'En curso' : 'Finalizada',
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _isLoadingHistory ? null : _loadHistory,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualizar historial'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
