import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/schedule_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/horizontal_table_scroll.dart';

import '../../models/space_model.dart';

class ManageSchedulesScreen extends StatefulWidget {
  const ManageSchedulesScreen({super.key});

  @override
  State<ManageSchedulesScreen> createState() => _ManageSchedulesScreenState();
}

class _ManageSchedulesScreenState extends State<ManageSchedulesScreen> {
  static const _weekdays = {
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábados',
    7: 'Domingos y festivos',
  };

  List<ScheduleModel> _schedules = [];
  List<SpaceModel> _spaces = [];
  int? _selectedLabFilter; // null = Todos
  final Set<int> _updatingSchedules = {};
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final results = await Future.wait([
        ApiService.fetchLaboratorios(),
        ApiService.fetchSchedules(labId: _selectedLabFilter),
      ]);
      if (!mounted) return;
      setState(() {
        _spaces = results[0] as List<SpaceModel>;
        _schedules = results[1] as List<ScheduleModel>;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final schedules = await ApiService.fetchSchedules(labId: _selectedLabFilter);
      if (!mounted) return;
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _createSchedule() async {
    final draft = await showDialog<_ScheduleDraft>(
      context: context,
      builder: (_) => _ScheduleDialog(spaces: _spaces),
    );
    if (draft == null || !mounted) return;

    try {
      await ApiService.createSchedule(
        weekday: draft.weekday,
        opensAt: draft.opensAt,
        closesAt: draft.closesAt,
        labId: draft.labId,
      );
      if (!mounted) return;
      await _loadSchedules();
      _showMessage('La nueva franja quedó guardada.');
    } catch (error) {
      if (!mounted) return;
      _showMessage(
        'No se pudo guardar la franja: ${error.toString().replaceFirst('Exception: ', '')}',
        isError: true,
      );
    }
  }

  Future<void> _setScheduleActive(ScheduleModel schedule, bool active) async {
    setState(() => _updatingSchedules.add(schedule.id));
    try {
      await ApiService.setScheduleActive(schedule.id, active);
      if (!mounted) return;
      setState(() {
        _schedules = _schedules
            .map(
              (item) => item.id == schedule.id
                  ? item.copyWith(active: active)
                  : item,
            )
            .toList();
        _updatingSchedules.remove(schedule.id);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _updatingSchedules.remove(schedule.id));
      _showMessage(
        'No se pudo actualizar el estado: ${error.toString().replaceFirst('Exception: ', '')}',
        isError: true,
      );
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.accentGreen,
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/admin/schedules',
      title: 'Gestionar Horarios Institucionales',
      subtitle:
          'Configura las franjas horarias y días de disponibilidad para reservas',
      child: SingleChildScrollView(
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
                runSpacing: 12,
                children: [
                  const Text(
                    'Franjas y Políticas de Horario',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        child: DropdownButtonFormField<int>(
                          initialValue: _selectedLabFilter ?? 0,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Filtrar por laboratorio',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<int>(
                              value: 0,
                              child: Text('Todos los laboratorios'),
                            ),
                            ..._spaces.map(
                              (space) => DropdownMenuItem<int>(
                                value: int.tryParse(space.id) ?? 0,
                                child: Text(
                                  space.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedLabFilter =
                                  (value == null || value == 0) ? null : value;
                            });
                            _loadSchedules();
                          },
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _createSchedule,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nueva franja'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(140, 40),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Los cambios se guardan en la base de datos y determinan '
                'cuándo se permiten nuevas reservas.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_loadError != null)
                Center(
                  child: Column(
                    children: [
                      Text(
                        'No se pudieron cargar los horarios: $_loadError',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _loadSchedules,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              else if (_schedules.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No hay franjas configuradas en la base de datos.'),
                  ),
                )
              else
                HorizontalTableScroll(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.frameBg),
                    columns: const [
                      DataColumn(label: Text('Laboratorio')),
                      DataColumn(label: Text('Día')),
                      DataColumn(label: Text('Hora apertura')),
                      DataColumn(label: Text('Hora cierre')),
                      DataColumn(label: Text('Estado')),
                    ],
                    rows: _schedules.map((schedule) {
                      final isUpdating = _updatingSchedules.contains(
                        schedule.id,
                      );
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              schedule.labName ?? 'Todos los laboratorios',
                              style: TextStyle(
                                color: schedule.labName == null
                                    ? AppColors.textMuted
                                    : AppColors.textStrong,
                                fontStyle: schedule.labName == null
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _weekdays[schedule.weekday] ??
                                  'Día ${schedule.weekday}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(Text(_formatTime(schedule.opensAt))),
                          DataCell(Text(_formatTime(schedule.closesAt))),
                          DataCell(
                            isUpdating
                                ? const SizedBox(
                                    width: 48,
                                    height: 32,
                                    child: Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  )
                                : Switch(
                                    value: schedule.active,
                                    activeTrackColor: AppColors.accentGreen,
                                    onChanged: (value) =>
                                        _setScheduleActive(schedule, value),
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
    );
  }
}

class _ScheduleDraft {
  final int weekday;
  final String opensAt;
  final String closesAt;
  final int? labId;

  const _ScheduleDraft({
    required this.weekday,
    required this.opensAt,
    required this.closesAt,
    this.labId,
  });
}

class _ScheduleDialog extends StatefulWidget {
  final List<SpaceModel> spaces;

  const _ScheduleDialog({required this.spaces});

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  int _weekday = DateTime.monday;
  TimeOfDay _opensAt = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closesAt = const TimeOfDay(hour: 18, minute: 0);
  int? _labId; // null = Todos los laboratorios
  String? _validationError;

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime({required bool opening}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: opening ? _opensAt : _closesAt,
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (opening) {
        _opensAt = selected;
      } else {
        _closesAt = selected;
      }
      _validationError = null;
    });
  }

  void _submit() {
    final opensInMinutes = _opensAt.hour * 60 + _opensAt.minute;
    final closesInMinutes = _closesAt.hour * 60 + _closesAt.minute;
    if (closesInMinutes <= opensInMinutes) {
      setState(() {
        _validationError = 'La hora de cierre debe ser posterior a la apertura.';
      });
      return;
    }
    Navigator.of(context).pop(
      _ScheduleDraft(
        weekday: _weekday,
        opensAt: _formatTime(_opensAt),
        closesAt: _formatTime(_closesAt),
        labId: _labId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear franja horaria'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            initialValue: _labId ?? 0,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Laboratorio',
              helperText: 'Elige uno o aplica la franja a todos',
            ),
            items: [
              const DropdownMenuItem<int>(
                value: 0,
                child: Text('Todos los laboratorios'),
              ),
              ...widget.spaces.map(
                (space) => DropdownMenuItem<int>(
                  value: int.tryParse(space.id) ?? 0,
                  child: Text(space.name, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
            onChanged: (value) => setState(
              () => _labId = (value == null || value == 0) ? null : value,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: _weekday,
            decoration: const InputDecoration(labelText: 'Día de la semana'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Lunes')),
              DropdownMenuItem(value: 2, child: Text('Martes')),
              DropdownMenuItem(value: 3, child: Text('Miércoles')),
              DropdownMenuItem(value: 4, child: Text('Jueves')),
              DropdownMenuItem(value: 5, child: Text('Viernes')),
              DropdownMenuItem(value: 6, child: Text('Sábado')),
              DropdownMenuItem(value: 7, child: Text('Domingo')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _weekday = value);
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Hora de apertura'),
            trailing: TextButton(
              onPressed: () => _pickTime(opening: true),
              child: Text(_formatTime(_opensAt)),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Hora de cierre'),
            trailing: TextButton(
              onPressed: () => _pickTime(opening: false),
              child: Text(_formatTime(_closesAt)),
            ),
          ),
          if (_validationError != null)
            Text(
              _validationError!,
              style: const TextStyle(color: AppColors.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
