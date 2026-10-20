import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/space_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/horizontal_table_scroll.dart';
import '../../widgets/status_badge.dart';

class AttendanceRecord {
  final String spaceName;
  final String date;
  final String time;
  final String code;
  final String status;

  AttendanceRecord({
    required this.spaceName,
    required this.date,
    required this.time,
    required this.code,
    required this.status,
  });
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _codeController = TextEditingController();
  List<SpaceModel> _spaces = [];
  String? _selectedSpace;
  bool _isLoadingSpaces = true;
  final List<AttendanceRecord> _localHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    final list = await ApiService.fetchLaboratorios();
    if (!mounted) return;
    setState(() {
      _spaces = list;
      if (_spaces.isNotEmpty) {
        _selectedSpace = _spaces.first.name;
      }
      _isLoadingSpaces = false;
    });
  }

  void _registerAttendance() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código de confirmación del espacio.'), backgroundColor: AppColors.error),
      );
      return;
    }

    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    setState(() {
      _localHistory.insert(
        0,
        AttendanceRecord(
          spaceName: _selectedSpace ?? 'Espacio UCEVA',
          date: dateStr,
          time: timeStr,
          code: code.toUpperCase(),
          status: 'Confirmada',
        ),
      );
      _codeController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Asistencia registrada con éxito! Presencia confirmada.'),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/user/attendance',
      title: 'Control de Asistencia',
      subtitle: 'Registra tu llegada al espacio y consulta tu historial',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de Registro de Asistencia
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
                      Icon(Icons.qr_code_scanner, color: AppColors.accentGreen, size: 28),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Registrar Asistencia en Espacio',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textStrong),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ingresa el código proporcionado por el encargado o mostrado en la pantalla del laboratorio.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoadingSpaces)
                    const LinearProgressIndicator(color: AppColors.primaryGreen)
                  else if (_spaces.isEmpty)
                    const Text('No se encontraron espacios universitarios disponibles.')
                  else
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _selectedSpace,
                      decoration: const InputDecoration(labelText: 'Espacio en el que estás presente'),
                      items: _spaces.map((s) => DropdownMenuItem(
                        value: s.name,
                        child: Text(s.name, overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedSpace = val),
                    ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 560;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomTextField(
                              label: 'Código de Asistencia (Ej. AST-1234)',
                              controller: _codeController,
                              hint: 'Ingresa el código del aula...',
                              prefixIcon: const Icon(Icons.pin),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: _registerAttendance,
                              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                              child: const Text('Confirmar llegada'),
                            ),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Código de Asistencia (Ej. AST-1234)',
                              controller: _codeController,
                              hint: 'Ingresa el código del aula...',
                              prefixIcon: const Icon(Icons.pin),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _registerAttendance,
                            style: ElevatedButton.styleFrom(minimumSize: const Size(160, 48)),
                            child: const Text('Confirmar llegada'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Historial de Asistencia
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
                    'Historial de Asistencias Registradas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textStrong),
                  ),
                  const SizedBox(height: 16),
                  if (_localHistory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Aún no has registrado asistencias en esta sesión.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  else
                    HorizontalTableScroll(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.frameBg),
                        columns: const [
                          DataColumn(label: Text('Espacio', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Fecha y Hora', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Código', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _localHistory.map((a) {
                          return DataRow(
                            cells: [
                              DataCell(Text(a.spaceName, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text('${a.date} · ${a.time}')),
                              DataCell(Text(a.code, style: const TextStyle(fontFamily: 'monospace'))),
                              DataCell(StatusBadge(status: a.status)),
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
    );
  }
}
