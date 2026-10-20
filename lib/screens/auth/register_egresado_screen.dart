import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_text_field.dart';

class RegisterEgresadoScreen extends StatefulWidget {
  const RegisterEgresadoScreen({super.key});

  @override
  State<RegisterEgresadoScreen> createState() => _RegisterEgresadoScreenState();
}

class _RegisterEgresadoScreenState extends State<RegisterEgresadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _tipoUsuario = 'ESTUDIANTE'; // 'ESTUDIANTE' o 'EGRESADO'
  bool _termsAccepted = false;
  bool _termsError = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _termsError = !_termsAccepted;
      _errorMessage = null;
    });

    if (!_termsAccepted) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.register(
      nombres: _nombresController.text.trim(),
      apellidos: _apellidosController.text.trim(),
      email: _emailController.text.trim(),
      telefono: _telefonoController.text.trim(),
      contrasena: _passwordController.text,
      confirmarContrasena: _confirmPasswordController.text,
      tipoUsuario: _tipoUsuario,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['mensaje'] ?? '¡Cuenta creada exitosamente! Ya puedes iniciar sesión.'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'Error al registrar usuario.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder, width: 1),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Registro de Usuario',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textStrong,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Completa tus datos para solicitar reservas en las instalaciones de la UCEVA.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorSoft,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Selector de tipo de persona
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de Usuario',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textStrong),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        initialValue: _tipoUsuario,
                        decoration: const InputDecoration(),
                        items: const [
                          DropdownMenuItem(value: 'ESTUDIANTE', child: Text('Estudiante')),
                          DropdownMenuItem(value: 'EGRESADO', child: Text('Egresado')),
                        ],
                        onChanged: _isLoading ? null : (val) => setState(() => _tipoUsuario = val!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Nombres',
                          controller: _nombresController,
                          hint: 'Ej. Juan Camilo',
                          enabled: !_isLoading,
                          validator: (v) => (v == null || v.trim().length < 2) ? 'Escribe tus nombres.' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'Apellidos',
                          controller: _apellidosController,
                          hint: 'Ej. Restrepo',
                          enabled: !_isLoading,
                          validator: (v) => (v == null || v.trim().length < 2) ? 'Escribe tus apellidos.' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Teléfono celular (10 dígitos)',
                    controller: _telefonoController,
                    hint: '3001234567',
                    keyboardType: TextInputType.phone,
                    enabled: !_isLoading,
                    validator: (v) {
                      if (v == null || !RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                        return 'El teléfono debe tener exactamente 10 dígitos numéricos.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Correo electrónico',
                    controller: _emailController,
                    hint: 'nombre@correo.com',
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    validator: (v) {
                      if (v == null || !v.contains('@') || !v.contains('.')) {
                        return 'Escribe un correo electrónico válido.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Contraseña (mínimo 8 caracteres)',
                    controller: _passwordController,
                    obscureText: true,
                    enabled: !_isLoading,
                    validator: (v) => (v == null || v.length < 8) ? 'La contraseña debe tener al menos 8 caracteres.' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Confirmar contraseña',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    enabled: !_isLoading,
                    validator: (v) {
                      if (v != _passwordController.text) return 'Las contraseñas no coinciden.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _termsAccepted,
                        activeColor: AppColors.accentGreen,
                        onChanged: _isLoading
                            ? null
                            : (val) {
                                setState(() {
                                  _termsAccepted = val ?? false;
                                  if (_termsAccepted) _termsError = false;
                                });
                              },
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Acepto la política de tratamiento de datos personales y normas de uso de espacios de la UCEVA.',
                            style: TextStyle(fontSize: 12, color: AppColors.textBody),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_termsError)
                    const Padding(
                      padding: EdgeInsets.only(left: 12, bottom: 8),
                      child: Text(
                        'Debes aceptar los términos y condiciones para continuar.',
                        style: TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Crear mi cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
