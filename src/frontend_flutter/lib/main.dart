import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'services/auth_session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthSessionService().init();
  runApp(const SaiciApp());
}

class SaiciApp extends StatelessWidget {
  const SaiciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LabAcces · Reservas UCEVA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.getInitialRoute(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
