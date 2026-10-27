import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/schedule_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/horizontal_table_scroll.dart';

class ManageSchedulesScreen extends StatefulWidget {
  const ManageSchedulesScreen({super.key});

  @override
  State<ManageSchedulesScreen> createState() => _ManageSchedulesScreenState();
}

class _ManageSchedulesScreenState extends State<ManageSchedulesScreen> {
  static const Map<int, String> _weekdays = {
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábado',
    7: 'Domingo',
  };

  List<ScheduleModel> _schedules = [];
  bool _isLoading = true;
  String? _loadError;

  final Set<int> _processingSchedules = {};

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final schedules = await ApiService.fetchSchedules();

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
      builder: (_) => const _ScheduleDialog(),
    );

    if (draft == null || !mounted) return;

    try {
      await ApiService.createSchedule(
        weekday: draft.weekday,
        opensAt: draft.opensAt,
        closesAt: draft.closesAt,
      );

      if (!mounted) return;

      await _loadSchedules();
      _showMessage('Horario creado correctamente.');
    } catch (error) {
      if (!mounted) return;

      _showMessage(
        'No se pudo crear el horario: '
        '${error.toString().replaceFirst('Exception: ', '')}',
        isError: true,
      );
    }
  }

  Future<void> _editSchedule(ScheduleModel schedule) async {
    final draft = await showDialog<_ScheduleDraft>(
      context: context,
      builder: (_) => _ScheduleDialog(schedule: schedule),
    );

    if (draft == null || !mounted) return;

    setState(() => _processingSchedules.add(schedule.id));

    try {
      await ApiService.updateSchedule(
        id: schedule.id,
        weekday: draft.weekday,
        opensAt: draft.opensAt,
        closesAt: draft.closesAt,
      );

      if (!mounted) return;

      setState(() => _processingSchedules.remove(schedule.id));

      await _loadSchedules();
      _showMessage('Horario actualizado correctamente.');
    } catch (error) {
      if (!mounted) return;

      setState(() => _processingSchedules.remove(schedule.id));

      _showMessage(
        'No se pudo actualizar el horario: '
        '${error.toString().replaceFirst('Exception: ', '')}',
        isError: true,
      );
    }
  }

  Future<void> _deleteSchedule(ScheduleModel schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar horario'),
        content: Text(
          '¿Deseas eliminar el horario del '
          '${_weekdays[schedule.weekday] ?? 'día seleccionado'}, '
          'de ${schedule.opensAt} a ${schedule.closesAt}?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _processingSchedules.add(schedule.id));

    try {
      await ApiService.deleteSchedule(schedule.id);

      if (!mounted) return;

      setState(() {
        _processingSchedules.remove(schedule.id);
        _schedules.removeWhere((item) => item.id == schedule.id);
      });

      _showMessage('Horario eliminado correctamente.');
    } catch (error) {
      if (!mounted) return;

      setState(() => _processingSchedules.remove(schedule.id));

      _showMessage(
        'No se pudo eliminar el horario: '
        '${error.toString().replaceFirst('Exception: ', '')}',
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

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/admin/schedules',
      title: 'Gestionar Horarios Institucionales',
      subtitle: 'Configura los días y las franjas horarias para las reservas',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _loadSchedules,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Actualizar'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _createSchedule,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nueva franja'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Los horarios son institucionales y se comparten '
                'entre todos los laboratorios.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_loadError != null)
                Center(
                  child: Column(
                    children: [
                      Text(
                        'No se pudieron cargar los horarios:\n'
                        '$_loadError',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _loadSchedules,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              else if (_schedules.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No hay horarios configurados. '
                      'Selecciona "Nueva franja" para agregar uno.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                HorizontalTableScroll(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(AppColors.frameBg),
                    columns: const [
                      DataColumn(label: Text('Día')),
                      DataColumn(label: Text('Hora apertura')),
                      DataColumn(label: Text('Hora cierre')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: _schedules.map((schedule) {
                      final isProcessing =
                          _processingSchedules.contains(schedule.id);

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              _weekdays[schedule.weekday] ??
                                  'Día ${schedule.weekday}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(Text(schedule.opensAt)),
                          DataCell(Text(schedule.closesAt)),
                          DataCell(
                            isProcessing
                                ? const SizedBox(
                                    width: 40,
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
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Editar horario',
                                        onPressed: () =>
                                            _editSchedule(schedule),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Eliminar horario',
                                        onPressed: () =>
                                            _deleteSchedule(schedule),
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
                                        ),
                                      ),
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
    );
  }
}

class _ScheduleDraft {
  final int weekday;
  final String opensAt;
  final String closesAt;

  const _ScheduleDraft({
    required this.weekday,
    required this.opensAt,
    required this.closesAt,
  });
}

class _ScheduleDialog extends StatefulWidget {
  final ScheduleModel? schedule;

  const _ScheduleDialog({this.schedule});

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  late int _weekday;
  late TimeOfDay _opensAt;
  late TimeOfDay _closesAt;

  String? _validationError;

  @override
  void initState() {
    super.initState();

    final schedule = widget.schedule;

    _weekday = schedule?.weekday ?? DateTime.monday;
    _opensAt = _parseTime(schedule?.opensAt ?? '08:00');
    _closesAt = _parseTime(schedule?.closesAt ?? '18:00');
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');

    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

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
    final openingMinutes = _opensAt.hour * 60 + _opensAt.minute;
    final closingMinutes = _closesAt.hour * 60 + _closesAt.minute;

    if (closingMinutes <= openingMinutes) {
      setState(() {
        _validationError =
            'La hora de cierre debe ser posterior a la apertura.';
      });
      return;
    }

    Navigator.of(context).pop(
      _ScheduleDraft(
        weekday: _weekday,
        opensAt: _formatTime(_opensAt),
        closesAt: _formatTime(_closesAt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.schedule != null;

    return AlertDialog(
      title: Text(
        isEditing ? 'Editar franja horaria' : 'Crear franja horaria',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _weekday,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Día de la semana',
                border: OutlineInputBorder(),
              ),
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
                if (value != null) {
                  setState(() => _weekday = value);
                }
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
            if (_validationError != null) ...[
              const SizedBox(height: 8),
              Text(
                _validationError!,
                style: const TextStyle(
                  color: AppColors.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Guardar cambios' : 'Crear'),
        ),
      ],
    );
  }
}
