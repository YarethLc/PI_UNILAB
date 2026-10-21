import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      final user = result['usuario'];
      final rol = (user.rol ?? '').toString().toUpperCase();
      final tipo = (user.tipo ?? '').toString().toUpperCase();

      if (rol == 'ADMINISTRADOR') {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      } else if (rol == 'LABORATORIO') {
        Navigator.pushReplacementNamed(context, '/lab/dashboard');
      } else if (rol == 'USUARIO' || tipo == 'ESTUDIANTE' || tipo == 'EGRESADO') {
        Navigator.pushReplacementNamed(context, '/user/home');
      } else {
        setState(() {
          _errorMessage = 'Rol de usuario no reconocido en el sistema ($rol).';
        });
      }
    } else {
      setState(() {
        _errorMessage = result['error'] ?? 'Error al iniciar sesión.';
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
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.surfaceBorder, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(18, 59, 34, 0.06),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo UCEVA
                  Center(
                    child: Image.asset(
                      'assets/images/uceva-imagotipo.png',
                      height: 52,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Column(
                        children: [
                          Icon(Icons.account_balance, color: AppColors.primaryGreen, size: 40),
                          SizedBox(height: 4),
                          Text('UCEVA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Iniciar sesión en LabAcces',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textStrong,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Sistema de Reserva de Espacios Universitarios',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 24),

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

                  // Email
                  CustomTextField(
                    label: 'Correo electrónico',
                    controller: _emailController,
                    hint: 'nombre@correo.com',
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isLoading,
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Escribe tu correo electrónico.';
                      if (!v.contains('@') || !v.contains('.')) return 'El correo no es válido. Ejemplo: usuario@uceva.edu.co';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  CustomTextField(
                    label: 'Contraseña',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !_isLoading,
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Escribe tu contraseña.';
                      if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Olvidé contraseña
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pushNamed(context, '/forgot-password'),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: AppColors.accentGreenText, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Ingresar a LabAcces'),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.surfaceBorder),
                  const SizedBox(height: 12),

                  // Registro
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pushNamed(context, '/register-egresado'),
                    child: const Text('¿No tienes cuenta? Regístrate aquí'),
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
