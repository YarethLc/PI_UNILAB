import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/space_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/horizontal_table_scroll.dart';
import '../../widgets/status_badge.dart';

class ManageSpacesScreen extends StatefulWidget {
  const ManageSpacesScreen({super.key});

  @override
  State<ManageSpacesScreen> createState() => _ManageSpacesScreenState();
}

class _ManageSpacesScreenState extends State<ManageSpacesScreen> {
  List<SpaceModel> _spaces = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    setState(() => _isLoading = true);
    final list = await ApiService.fetchLaboratorios();
    if (!mounted) return;
    setState(() {
      _spaces = list;
      _isLoading = false;
    });
  }

  void _openSpaceForm([SpaceModel? existing]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final locationCtrl = TextEditingController(text: existing?.location ?? '');
    final capacityCtrl = TextEditingController(text: existing != null ? existing.capacity.toString() : '20');
    String estado = (existing?.status ?? 'DISPONIBLE').toUpperCase();
    if (estado != 'DISPONIBLE' && estado != 'OCUPADO' && estado != 'MANTENIMIENTO') {
      estado = 'DISPONIBLE';
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(existing == null ? 'Crear Nuevo Laboratorio' : 'Editar Laboratorio',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(label: 'Nombre del Laboratorio', controller: nameCtrl, hint: 'Ej. Laboratorio de Redes 2'),
                  const SizedBox(height: 12),
                  CustomTextField(label: 'Ubicación física', controller: locationCtrl, hint: 'Ej. Bloque B, sala 102'),
                  const SizedBox(height: 12),
                  CustomTextField(label: 'Capacidad máxima', controller: capacityCtrl, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: estado,
                    decoration: const InputDecoration(labelText: 'Estado en el sistema'),
                    items: const [
                      DropdownMenuItem(value: 'DISPONIBLE', child: Text('DISPONIBLE')),
                      DropdownMenuItem(value: 'OCUPADO', child: Text('OCUPADO')),
                      DropdownMenuItem(value: 'MANTENIMIENTO', child: Text('MANTENIMIENTO')),
                    ],
                    onChanged: (val) => setDlgState(() => estado = val!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final loc = locationCtrl.text.trim();
                final cap = int.tryParse(capacityCtrl.text.trim()) ?? 20;

                if (name.isEmpty || loc.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nombre y ubicación son obligatorios.')),
                  );
                  return;
                }

                Navigator.pop(ctx);

                Map<String, dynamic> res;
                if (existing == null) {
                  res = await ApiService.createLaboratorio(
                    nombre: name,
                    ubicacion: loc,
                    estado: estado,
                    capacidad: cap,
                  );
                } else {
                  res = await ApiService.updateLaboratorio(
                    id: existing.id,
                    nombre: name,
                    ubicacion: loc,
                    estado: estado,
                    capacidad: cap,
                  );
                }

                if (!mounted) return;

                if (res['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(existing == null ? 'Laboratorio creado en BD con éxito' : 'Laboratorio actualizado')),
                  );
                  _loadSpaces();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res['error'] ?? 'Error al guardar laboratorio.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: Text(existing == null ? 'Crear Laboratorio' : 'Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(SpaceModel sp) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Eliminar laboratorio?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Seguro que deseas eliminar «${sp.name}» de la base de datos?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await ApiService.deleteLaboratorio(sp.id);
              if (!mounted) return;
              if (res['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Laboratorio eliminado de la base de datos.')),
                );
                _loadSpaces();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res['error'] ?? 'No se pudo eliminar el laboratorio.'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/admin/spaces',
      title: 'Gestionar Espacios Universitarios',
      subtitle: 'Configuración y catálogo de laboratorios en base de datos',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSpaces,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                          const Text('Catálogo de Laboratorios en BD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: () => _openSpaceForm(),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Nuevo laboratorio'),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(160, 40)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_spaces.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text('No hay laboratorios creados en la base de datos.', style: TextStyle(color: AppColors.textMuted)),
                          ),
                        )
                      else
                        HorizontalTableScroll(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(AppColors.frameBg),
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Ubicación')),
                              DataColumn(label: Text('Capacidad')),
                              DataColumn(label: Text('Estado')),
                              DataColumn(label: Text('Acciones')),
                            ],
                            rows: _spaces.map((sp) {
                              return DataRow(
                                cells: [
                                  DataCell(Text('#${sp.id}')),
                                  DataCell(Text(sp.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(sp.location)),
                                  DataCell(Text('${sp.capacity} personas')),
                                  DataCell(StatusBadge(status: sp.status)),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.accentGreenText),
                                          tooltip: 'Editar laboratorio',
                                          onPressed: () => _openSpaceForm(sp),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                          tooltip: 'Eliminar laboratorio',
                                          onPressed: () => _confirmDelete(sp),
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
            ),
    );
  }
}
