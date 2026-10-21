import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/horizontal_table_scroll.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final list = await ApiService.fetchUsuarios();
    if (!mounted) return;
    setState(() {
      _users = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      currentRoute: '/admin/users',
      title: 'Gestión de Usuarios',
      subtitle: 'Administración de cuentas y roles almacenados en PostgreSQL',
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUsers,
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
                        runSpacing: 8,
                        children: [
                          const Text('Usuarios Registrados en BD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            '${_users.length} cuentas registradas',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_users.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text('No hay usuarios registrados en la base de datos.', style: TextStyle(color: AppColors.textMuted)),
                          ),
                        )
                      else
                        HorizontalTableScroll(
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(AppColors.frameBg),
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Nombre Completo')),
                              DataColumn(label: Text('Correo')),
                              DataColumn(label: Text('Teléfono')),
                              DataColumn(label: Text('Tipo')),
                              DataColumn(label: Text('Rol')),
                            ],
                            rows: _users.map((u) {
                              return DataRow(
                                cells: [
                                  DataCell(Text('#${u.id}')),
                                  DataCell(Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                  DataCell(Text(u.correo)),
                                  DataCell(Text(u.telefono)),
                                  DataCell(Text(u.tipo)),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: u.rol.toUpperCase() == 'ADMINISTRADOR'
                                            ? AppColors.accentGreenSoft
                                            : AppColors.frameBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        u.rol.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: u.rol.toUpperCase() == 'ADMINISTRADOR'
                                              ? AppColors.accentGreenText
                                              : AppColors.textBody,
                                        ),
                                      ),
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
