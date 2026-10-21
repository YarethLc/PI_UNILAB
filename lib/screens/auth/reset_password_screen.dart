import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  void _savePassword() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Contraseña actualizada exitosamente! Inicia sesión con tu nueva clave.'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
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
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Nueva Contraseña',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textStrong,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea una contraseña segura de al menos 8 caracteres para tu cuenta LabAcces.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Nueva contraseña',
                    controller: _passwordController,
                    obscureText: _obscure1,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setState(() => _obscure1 = !_obscure1),
                    ),
                    validator: (v) => (v == null || v.length < 8) ? 'La contraseña debe tener al menos 8 caracteres.' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Confirmar nueva contraseña',
                    controller: _confirmPasswordController,
                    obscureText: _obscure2,
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setState(() => _obscure2 = !_obscure2),
                    ),
                    validator: (v) {
                      if (v != _passwordController.text) return 'Las contraseñas no coinciden.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _savePassword,
                    child: const Text('Guardar y acceder'),
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
