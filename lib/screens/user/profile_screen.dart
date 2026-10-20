import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../services/auth_session_service.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;

  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isSavingProfile = false;
  bool _isChangingPassword = false;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final user = AuthSessionService().currentUser;
    _nombresController = TextEditingController(text: user?.nombres ?? '');
    _apellidosController = TextEditingController(text: user?.apellidos ?? '');
    _telefonoController = TextEditingController(text: user?.telefono ?? '');
    _emailController = TextEditingController(text: user?.correo ?? '');
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final nombres = _nombresController.text.trim();
    final apellidos = _apellidosController.text.trim();
    final telefono = _telefonoController.text.trim();
    final email = _emailController.text.trim();

    if (nombres.isEmpty || apellidos.isEmpty || telefono.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos de información personal.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(telefono)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El teléfono debe tener exactamente 10 dígitos numéricos.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSavingProfile = true);

    final res = await ApiService.updateProfile(
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      email: email,
    );

    if (!mounted) return;

    setState(() => _isSavingProfile = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Datos de perfil actualizados exitosamente en la base de datos!'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['error'] ?? 'Error al actualizar perfil.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    final currentPass = _currentPassController.text;
    final newPass = _newPassController.text;
    final confirmPass = _confirmPassController.text;

    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa los tres campos de contraseña.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (newPass.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La nueva contraseña debe tener al menos 8 caracteres.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La nueva contraseña y su confirmación no coinciden.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isChangingPassword = true);

    final res = await ApiService.changePassword(
      contrasenaActual: currentPass,
      nuevaContrasena: newPass,
      confirmarContrasena: confirmPass,
    );

    if (!mounted) return;

    setState(() => _isChangingPassword = false);

    if (res['success'] == true) {
      _currentPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Contraseña actualizada exitosamente!'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['error'] ?? 'Error al cambiar la contraseña.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthSessionService().currentUser;

    return AppLayout(
      currentRoute: '/user/profile',
      title: 'Perfil de Usuario',
      subtitle: 'Administra tus datos personales y credenciales de acceso',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // TARJETA DE INFORMACIÓN PERSONAL
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
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.accentGreenSoft,
                        child: Text(
                          (user?.nombres.isNotEmpty ?? false) ? user!.nombres.substring(0, 1).toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.accentGreenText),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'Usuario',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textStrong),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${user?.tipo ?? ''} · Rol: ${user?.rol.toUpperCase() ?? ''}',
                              style: const TextStyle(fontSize: 13, color: AppColors.accentGreenText, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.correo ?? '',
                              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 36),

                  const Text('Información Personal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 540;
                      if (isNarrow) {
                        return Column(
                          children: [
                            CustomTextField(
                              label: 'Nombres',
                              controller: _nombresController,
                              enabled: !_isSavingProfile,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Apellidos',
                              controller: _apellidosController,
                              enabled: !_isSavingProfile,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Nombres',
                              controller: _nombresController,
                              enabled: !_isSavingProfile,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'Apellidos',
                              controller: _apellidosController,
                              enabled: !_isSavingProfile,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Teléfono de contacto (10 dígitos)',
                    controller: _telefonoController,
                    keyboardType: TextInputType.phone,
                    enabled: !_isSavingProfile,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Correo electrónico',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isSavingProfile,
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 480;
                      return Align(
                        alignment: isNarrow ? Alignment.center : Alignment.centerRight,
                        child: SizedBox(
                          width: isNarrow ? double.infinity : null,
                          child: ElevatedButton.icon(
                            onPressed: _isSavingProfile ? null : _saveProfile,
                            icon: _isSavingProfile
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.save_outlined, size: 18),
                            label: Text(_isSavingProfile ? 'Guardando...' : 'Guardar datos personales'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 44),
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // TARJETA DE SEGURIDAD Y CAMBIO DE CONTRASEÑA
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
                      Icon(Icons.lock_outline, color: AppColors.primaryGreen, size: 22),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Seguridad y Cambio de Contraseña',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textStrong),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Para actualizar tu contraseña, ingresa tu clave actual y define una nueva de mínimo 8 caracteres.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const Divider(color: AppColors.surfaceBorder, height: 28),

                  CustomTextField(
                    label: 'Contraseña Actual',
                    controller: _currentPassController,
                    obscureText: _obscureCurrent,
                    enabled: !_isChangingPassword,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 540;
                      if (isNarrow) {
                        return Column(
                          children: [
                            CustomTextField(
                              label: 'Nueva Contraseña (mín. 8 caracteres)',
                              controller: _newPassController,
                              obscureText: _obscureNew,
                              enabled: !_isChangingPassword,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, size: 20),
                                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Confirmar Nueva Contraseña',
                              controller: _confirmPassController,
                              obscureText: _obscureConfirm,
                              enabled: !_isChangingPassword,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 20),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Nueva Contraseña (mín. 8 caracteres)',
                              controller: _newPassController,
                              obscureText: _obscureNew,
                              enabled: !_isChangingPassword,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility, size: 20),
                                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              label: 'Confirmar Nueva Contraseña',
                              controller: _confirmPassController,
                              obscureText: _obscureConfirm,
                              enabled: !_isChangingPassword,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 20),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 480;
                      return Align(
                        alignment: isNarrow ? Alignment.center : Alignment.centerRight,
                        child: SizedBox(
                          width: isNarrow ? double.infinity : null,
                          child: ElevatedButton.icon(
                            onPressed: _isChangingPassword ? null : _changePassword,
                            icon: _isChangingPassword
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Icon(Icons.key_outlined, size: 18),
                            label: Text(_isChangingPassword ? 'Actualizando...' : 'Actualizar contraseña'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(200, 44),
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
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
