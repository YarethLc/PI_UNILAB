import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String tokenRecuperacion;

  const ResetPasswordScreen({
    super.key,
    required this.tokenRecuperacion,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _isSubmitting = false;

  Future<void> _savePassword() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final resultado = await ApiService.restablecerContrasena(
      tokenRecuperacion: widget.tokenRecuperacion,
      nuevaContrasena: _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (resultado['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado['mensaje'] ?? 'Contraseña actualizada correctamente.',
          ),
          backgroundColor: AppColors.accentGreen,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado['error'] ?? 'No se pudo actualizar la contraseña.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
              border: Border.all(
                color: AppColors.surfaceBorder,
                width: 1,
              ),
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
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Nueva contraseña',
                    controller: _passwordController,
                    obscureText: _obscure1,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure1 ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure1 = !_obscure1;
                        });
                      },
                    ),
                    validator: (v) {
                      if (v == null || v.length < 8) {
                        return 'La contraseña debe tener al menos 8 caracteres.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Confirmar nueva contraseña',
                    controller: _confirmPasswordController,
                    obscureText: _obscure2,
                    prefixIcon: const Icon(Icons.lock_reset),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure2 ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure2 = !_obscure2;
                        });
                      },
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Confirma tu nueva contraseña.';
                      }

                      if (v != _passwordController.text) {
                        return 'Las contraseñas no coinciden.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _savePassword,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Guardar y acceder'),
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
