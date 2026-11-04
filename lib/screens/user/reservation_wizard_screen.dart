import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/space_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_session_service.dart';
import '../../widgets/app_layout.dart';
import '../../models/schedule_model.dart';

class ReservationWizardScreen extends StatefulWidget {
  final SpaceModel? initialSpace;

  const ReservationWizardScreen({super.key, this.initialSpace});

  @override
  State<ReservationWizardScreen> createState() =>
      _ReservationWizardScreenState();
}

class _ReservationWizardScreenState extends State<ReservationWizardScreen> {
  int _currentStep = 0;
  List<SpaceModel> _spaces = [];
  bool _isLoadingSpaces = true;
  bool _isSubmitting = false;

  SpaceModel? _selectedSpace;
  DateTime _selectedDate = DateTime.now();
  String _selectedSlot = '';

  List<ScheduleModel> _schedules = [];
  bool _isLoadingSchedules = true;
  String? _scheduleError;
  String _selectedPurpose = 'Actividad académica';

  final List<String> purposes = [
    'Actividad académica',
    'Estudio individual',
    'Reunión de equipo',
    'Trabajo de grado / Investigación',
    'Taller o práctica de laboratorio',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSpace = widget.initialSpace;
    _loadSpaces();
    _loadSchedules();
  }

  Future<void> _loadSpaces() async {
    try {
      final spaces = await ApiService.fetchLaboratorios();
      if (!mounted) return;

      setState(() {
        _spaces = spaces;
        _isLoadingSpaces = false;
        if (_selectedSpace == null && spaces.isNotEmpty) {
          _selectedSpace = spaces.first;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingSpaces = false);
    }
  }

  bool _isAvailableDay(DateTime date) {
    return _schedules.any((schedule) =>
        schedule.weekday == date.weekday &&
        _getSlotsForSchedule(schedule).isNotEmpty);
  }

  DateTime? get _firstAvailableDate {
    final today = DateTime.now();

    for (int i = 0; i <= 60; i++) {
      final date =
          DateTime(today.year, today.month, today.day).add(Duration(days: i));

      if (_isAvailableDay(date)) {
        return date;
      }
    }

    return null;
  }

  int? _timeToMinutes(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }

  String _formatMinutes(int minutes) {
    final hours = (minutes ~/ 60).toString().padLeft(2, '0');
    final mins = (minutes % 60).toString().padLeft(2, '0');
    return '$hours:$mins';
  }

  List<String> _getSlotsForSchedule(ScheduleModel schedule) {
    final openingMinutes = _timeToMinutes(schedule.opensAt);
    final closingMinutes = _timeToMinutes(schedule.closesAt);

    if (openingMinutes == null ||
        closingMinutes == null ||
        closingMinutes <= openingMinutes) {
      return [];
    }

    final slots = <String>[];
    for (int start = openingMinutes;
        start + 120 <= closingMinutes;
        start += 120) {
      slots.add('${_formatMinutes(start)} – ${_formatMinutes(start + 120)}');
    }
    return slots;
  }

  List<String> _getAvailableTimeSlots() {
    final slots = <String>{};
    final daySchedules = _schedules.where(
      (schedule) => schedule.weekday == _selectedDate.weekday,
    );

    for (final schedule in daySchedules) {
      slots.addAll(_getSlotsForSchedule(schedule));
    }

    final result = slots.toList();
    result.sort((a, b) => a.compareTo(b));
    return result;
  }

  Future<void> _loadSchedules() async {
    try {
      final schedules = await ApiService.fetchSchedules();
      if (!mounted) return;

      setState(() {
        _schedules = schedules;
        _isLoadingSchedules = false;
        _scheduleError = null;

        final firstDate = _firstAvailableDate;
        if (firstDate != null) {
          _selectedDate = firstDate;
          final slots = _getAvailableTimeSlots();
          _selectedSlot = slots.isNotEmpty ? slots.first : '';
        } else {
          _selectedSlot = '';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingSchedules = false;
        _scheduleError = 'No se pudieron cargar los horarios institucionales.';
      });
    }
  }

  Future<void> _finishReservation() async {
    if (_selectedSpace == null || !_selectedSlot.contains(' – ')) return;

    final times = _selectedSlot.split(' – ');
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final idLab = int.tryParse(_selectedSpace!.id) ?? 1;

    setState(() => _isSubmitting = true);

    final result = await ApiService.createReserva(
      idLaboratorio: idLab,
      fecha: dateStr,
      horaInicio: times[0],
      horaFin: times[1],
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.accentGreen, size: 28),
              SizedBox(width: 10),
              Text('¡Reserva Guardada!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Tu solicitud para «${_selectedSpace!.name}» fue procesada por el servidor.',
                  style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.frameBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📅 Fecha: $dateStr',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('⏰ Horario: $_selectedSlot',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text('🎯 Motivo: $_selectedPurpose',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Text('📌 Estado actual: CONFIRMADA',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.amberText)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(
                    context, '/user/my-reservations');
              },
              child: const Text('Ir a Mis Reservas'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 28),
              SizedBox(width: 10),
              Text('No se pudo crear la reserva',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
              result['error'] ?? 'Ocurrió un error al procesar la reserva.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthSessionService().currentUser;

    return AppLayout(
      currentRoute: '/user/wizard',
      title: 'Asistente de Reserva',
      subtitle: 'Paso ${_currentStep + 1} de 4: ${_getStepTitle(_currentStep)}',
      child: _isLoadingSpaces
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    // Stepper visual adaptable
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 540;
                        if (isCompact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Paso ${_currentStep + 1} de 4: ${_getStepTitle(_currentStep)}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppColors.primaryGreen),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                      '${((_currentStep + 1) / 4 * 100).toInt()}%',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textMuted)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: (_currentStep + 1) / 4,
                                backgroundColor: AppColors.surfaceBorder,
                                color: AppColors.accentGreen,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            _buildStepIndicator(0, 'Espacio'),
                            _buildStepLine(0),
                            _buildStepIndicator(1, 'Fecha'),
                            _buildStepLine(1),
                            _buildStepIndicator(2, 'Horario'),
                            _buildStepLine(2),
                            _buildStepIndicator(3, 'Confirmación'),
                          ],
                        );
                      },
                    ),
                    const Divider(color: AppColors.surfaceBorder, height: 40),

                    // Contenido según paso
                    if (_currentStep == 0) _buildSpaceStep(),
                    if (_currentStep == 1) _buildDateStep(),
                    if (_currentStep == 2) _buildSlotStep(),
                    if (_currentStep == 3)
                      _buildSummaryStep(
                          user?.fullName ?? '', user?.correo ?? ''),

                    const SizedBox(height: 32),
                    // Botones de navegación adaptables
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (_currentStep > 0)
                          OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => setState(() => _currentStep--),
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(110, 42)),
                            child: const Text('Anterior'),
                          )
                        else
                          const SizedBox.shrink(),
                        ElevatedButton(
                          onPressed: _isSubmitting ||
                                  (_currentStep == 1 &&
                                      (_isLoadingSchedules ||
                                          _firstAvailableDate == null)) ||
                                  (_currentStep == 2 && _selectedSlot.isEmpty)
                              ? null
                              : () {
                                  if (_currentStep < 3) {
                                    if (_selectedSpace == null &&
                                        _currentStep == 0) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Por favor selecciona un espacio.'),
                                        ),
                                      );
                                      return;
                                    }
                                    if (_currentStep == 1 &&
                                        !_isAvailableDay(_selectedDate)) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Selecciona un día con horario registrado.'),
                                        ),
                                      );
                                      return;
                                    }
                                    if (_currentStep == 2 &&
                                        _selectedSlot.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'No hay franjas disponibles para la fecha seleccionada.'),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() => _currentStep++);
                                  } else {
                                    _finishReservation();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(160, 44)),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(_currentStep == 3
                                  ? 'Confirmar reserva'
                                  : 'Continuar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Selección del Espacio';
      case 1:
        return 'Selección de la Fecha';
      case 2:
        return 'Franja Horaria y Motivo';
      case 3:
        return 'Revisión y Confirmación';
      default:
        return '';
    }
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isDone = _currentStep > stepIndex;
    final isCurrent = _currentStep == stepIndex;

    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: isDone || isCurrent
                ? AppColors.accentGreen
                : AppColors.surfaceBorder,
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '${stepIndex + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? Colors.white : AppColors.textMuted,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color:
                  isCurrent ? AppColors.accentGreenText : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(int beforeIndex) {
    final isDone = _currentStep > beforeIndex;
    return Container(
      width: 24,
      height: 2,
      color: isDone ? AppColors.accentGreen : AppColors.surfaceBorder,
      margin: const EdgeInsets.only(bottom: 16),
    );
  }

  // Paso 1
  Widget _buildSpaceStep() {
    if (_spaces.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No hay laboratorios disponibles para reservar.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Elige el espacio que deseas utilizar:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        RadioGroup<SpaceModel>(
          groupValue: _selectedSpace,
          onChanged: (val) => setState(() => _selectedSpace = val),
          child: Column(
            children: [
              for (final sp in _spaces)
                RadioListTile<SpaceModel>(
                  value: sp,
                  title: Text(sp.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${sp.type} · ${sp.location} · Capacidad: ${sp.capacity} personas'),
                  secondary:
                      Text(sp.icon, style: const TextStyle(fontSize: 22)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Paso 2
  Widget _buildDateStep() {
    if (_isLoadingSchedules) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_scheduleError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_scheduleError!, style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: 12),
          OutlinedButton(
              onPressed: _loadSchedules, child: const Text('Reintentar')),
        ],
      );
    }

    if (_firstAvailableDate == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          'Actualmente no hay días con horarios institucionales configurados.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selecciona la fecha para la reserva:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.frameBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Icon(Icons.calendar_month,
                  color: AppColors.accentGreen, size: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Fecha elegida:',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textStrong,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final today = DateTime.now();
                  final firstDate =
                      DateTime(today.year, today.month, today.day);
                  final lastDate = firstDate.add(const Duration(days: 60));
                  final currentIsValid = _isAvailableDay(_selectedDate);
                  final initialDate =
                      currentIsValid ? _selectedDate : _firstAvailableDate!;

                  final picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                    selectableDayPredicate: _isAvailableDay,
                  );

                  if (picked != null && mounted) {
                    setState(() {
                      _selectedDate = picked;
                      final slots = _getAvailableTimeSlots();
                      _selectedSlot = slots.isNotEmpty ? slots.first : '';
                    });
                  }
                },
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(140, 40)),
                child: const Text('Cambiar fecha'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Solo puedes seleccionar días en los que el administrador haya registrado un horario.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      ],
    );
  }

  // Paso 3
  Widget _buildSlotStep() {
    final availableSlots = _getAvailableTimeSlots();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selecciona la franja horaria:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        if (_isLoadingSchedules)
          const Center(child: CircularProgressIndicator())
        else if (availableSlots.isEmpty)
          const Text(
            'No hay franjas horarias disponibles para este día. Selecciona otra fecha.',
            style: TextStyle(color: AppColors.textMuted),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: availableSlots.map((slot) {
              final isSel = _selectedSlot == slot;
              return ChoiceChip(
                label: Text(slot),
                selected: isSel,
                selectedColor: AppColors.accentGreen,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSel ? Colors.white : AppColors.textStrong,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedSlot = slot);
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 24),
        const Text('Motivo o justificación de la reserva:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedPurpose,
          decoration: const InputDecoration(labelText: 'Tipo de motivo'),
          items: purposes
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (val) => setState(() => _selectedPurpose = val!),
        ),
      ],
    );
  }

  // Paso 4
  Widget _buildSummaryStep(String userName, String userEmail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Revisión final de la reserva:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        const Text(
            'Verifica los datos antes de enviar tu solicitud al servidor.',
            style: TextStyle(color: AppColors.textMuted)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.frameBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Espacio', _selectedSpace?.name ?? ''),
              _buildSummaryRow('Ubicación', _selectedSpace?.location ?? ''),
              _buildSummaryRow('Fecha',
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              _buildSummaryRow('Horario', _selectedSlot),
              _buildSummaryRow('Motivo', _selectedPurpose),
              _buildSummaryRow('Solicitante', userName),
              _buildSummaryRow('Correo', userEmail),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textStrong,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
