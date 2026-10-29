import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/api_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int _secondsLeft = 900;
  Timer? _timer;

  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyOtp() async {
    if (_isVerifying || _isResending) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
    });

    final resultado = await ApiService.verificarCodigoRecuperacion(
      email: widget.email,
      codigo: _otpController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isVerifying = false;
    });

    if (resultado['success'] == true) {
      final tokenRecuperacion = resultado['token_recuperacion']?.toString();

      if (tokenRecuperacion == null || tokenRecuperacion.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El servidor no devolvió el token de recuperación.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        '/reset-password',
        arguments: tokenRecuperacion,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado['error'] ?? 'No se pudo verificar el código.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _resendCode() async {
    if (_isResending || _isVerifying) return;

    setState(() {
      _isResending = true;
    });

    final resultado =
        await ApiService.solicitarCodigoRecuperacion(widget.email);

    if (!mounted) return;

    setState(() {
      _isResending = false;
    });

    if (resultado['success'] == true) {
      setState(() {
        _secondsLeft = 900;
        _otpController.clear();
      });

      _startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado['mensaje'] ?? 'Solicitud de reenvío procesada.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resultado['error'] ?? 'No se pudo reenviar el código.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Verificar Código OTP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textStrong,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enviamos un código de 6 dígitos a:\n'
                    '${widget.email.isEmpty ? "tu correo registrado" : widget.email}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Código de verificación (6 dígitos)',
                    controller: _otpController,
                    hint: 'Ingresa el código recibido',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.pin_outlined),
                    validator: (v) {
                      final codigo = v?.trim() ?? '';

                      if (!RegExp(r'^\d{6}$').hasMatch(codigo)) {
                        return 'Ingresa los 6 dígitos del código.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Expira en: $_formattedTime',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed:
                            (_isResending || _isVerifying) ? null : _resendCode,
                        child: _isResending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Reenviar código',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.accentGreenText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        (_isVerifying || _isResending) ? null : _verifyOtp,
                    child: _isVerifying
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Verificar y continuar'),
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
