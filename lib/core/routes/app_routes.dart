import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/space_model.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_egresado_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/auth/reset_password_screen.dart';
import '../../screens/user/user_home_screen.dart';
import '../../screens/user/explore_spaces_screen.dart';
import '../../screens/user/space_detail_screen.dart';
import '../../screens/user/reservation_wizard_screen.dart';
import '../../screens/user/my_reservations_screen.dart';
import '../../screens/user/reservation_history_screen.dart';
import '../../screens/user/attendance_screen.dart';
import '../../screens/user/profile_screen.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/manage_reservations_screen.dart';
import '../../screens/admin/manage_spaces_screen.dart';
import '../../screens/admin/manage_schedules_screen.dart';
import '../../screens/admin/reports_screen.dart';
import '../../screens/admin/manage_users_screen.dart';
import '../../screens/lab/lab_dashboard_screen.dart';
import '../../screens/lab/lab_reservations_screen.dart';
import '../../services/auth_session_service.dart';

class AppRoutes {
  static String getInitialRoute() {
    final session = AuthSessionService();

    if (!session.isAuthenticated) {
      return '/login';
    }

    return '/home';
  }

  static Widget _unauthorizedScreen(
    BuildContext context,
    String reason,
  ) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.security,
                size: 56,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Acceso Restringido',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textStrong,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reason,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textBody,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    getInitialRoute(),
                  );
                },
                child: const Text(
                  'Volver a mi panel autorizado',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Route<dynamic> onGenerateRoute(
    RouteSettings settings,
  ) {
    final session = AuthSessionService();
    final name = settings.name ?? '/';

    // Rutas públicas de acceso.
    if (name == '/' || name == '/login') {
      return MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      );
    }

    if (name == '/register-egresado') {
      return MaterialPageRoute(
        builder: (_) => const RegisterEgresadoScreen(),
      );
    }

    if (name == '/forgot-password') {
      return MaterialPageRoute(
        builder: (_) => const ForgotPasswordScreen(),
      );
    }

    if (name == '/verify-otp') {
      final email = settings.arguments as String? ?? '';

      return MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          email: email,
        ),
      );
    }

    if (name == '/reset-password') {
      final token = settings.arguments as String?;

      if (token == null || token.isEmpty) {
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
      }

      return MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          tokenRecuperacion: token,
        ),
      );
    }

    // Si la ruta requiere autenticación y no hay sesión activa.
    if (!session.isAuthenticated) {
      return MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      );
    }

    final rol = session.currentRole;
    final tipo = session.currentTipo;

    final isAdmin = rol == 'ADMINISTRADOR';
    final isLab = rol == 'LABORATORIO';

    final isEstudiante = rol == 'USUARIO' ||
        (!isAdmin && !isLab && (tipo == 'ESTUDIANTE' || tipo == 'EGRESADO'));

    if (name == '/home') {
      if (isAdmin) {
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        );
      }

      if (isLab) {
        return MaterialPageRoute(
          builder: (_) => const LabDashboardScreen(),
        );
      }

      if (isEstudiante) {
        return MaterialPageRoute(
          builder: (_) => const UserHomeScreen(),
        );
      }

      return MaterialPageRoute(
        builder: (ctx) => _unauthorizedScreen(
          ctx,
          'No se pudo determinar el rol autorizado para mostrar el inicio.',
        ),
      );
    }

    // Perfil: accesible por todos los usuarios autenticados.
    if (name == '/user/profile') {
      return MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      );
    }

    // Rutas exclusivas de estudiante / egresado.
    if (name.startsWith('/user/')) {
      if (!isEstudiante) {
        return MaterialPageRoute(
          builder: (ctx) => _unauthorizedScreen(
            ctx,
            'Esta pantalla es exclusiva para estudiantes y egresados universitarios.',
          ),
        );
      }

      switch (name) {
        case '/user/home':
          return MaterialPageRoute(
            builder: (_) => const UserHomeScreen(),
          );

        case '/user/spaces':
          return MaterialPageRoute(
            builder: (_) => const ExploreSpacesScreen(),
          );

        case '/user/space-detail':
          final space = settings.arguments as SpaceModel;

          return MaterialPageRoute(
            builder: (_) => SpaceDetailScreen(space: space),
          );

        case '/user/wizard':
          final space = settings.arguments as SpaceModel?;

          return MaterialPageRoute(
            builder: (_) => ReservationWizardScreen(
              initialSpace: space,
            ),
          );

        case '/user/my-reservations':
          return MaterialPageRoute(
            builder: (_) => const MyReservationsScreen(),
          );

        case '/user/history':
          return MaterialPageRoute(
            builder: (_) => const ReservationHistoryScreen(),
          );

        case '/user/attendance':
          return MaterialPageRoute(
            builder: (_) => const AttendanceScreen(),
          );
      }
    }

    // Rutas de administración.
    if (name.startsWith('/admin/')) {
      // Gestionar espacios también es accesible para laboratorio.
      if (name == '/admin/spaces' && (isAdmin || isLab)) {
        return MaterialPageRoute(
          builder: (_) => const ManageSpacesScreen(),
        );
      }

      if (!isAdmin) {
        return MaterialPageRoute(
          builder: (ctx) => _unauthorizedScreen(
            ctx,
            'No tienes permisos de Administrador para acceder a las funciones de gestión.',
          ),
        );
      }

      switch (name) {
        case '/admin/dashboard':
          return MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(),
          );

        case '/admin/reservations':
          return MaterialPageRoute(
            builder: (_) => const ManageReservationsScreen(),
          );

        case '/admin/spaces':
          return MaterialPageRoute(
            builder: (_) => const ManageSpacesScreen(),
          );

        case '/admin/schedules':
          return MaterialPageRoute(
            builder: (_) => const ManageSchedulesScreen(),
          );

        case '/admin/reports':
          return MaterialPageRoute(
            builder: (_) => const ReportsScreen(),
          );

        case '/admin/users':
          return MaterialPageRoute(
            builder: (_) => const ManageUsersScreen(),
          );
      }
    }

    // Rutas de laboratorio.
    if (name.startsWith('/lab/')) {
      if (!isLab && !isAdmin) {
        return MaterialPageRoute(
          builder: (ctx) => _unauthorizedScreen(
            ctx,
            'Esta pantalla es exclusiva para el personal de laboratorio.',
          ),
        );
      }

      switch (name) {
        case '/lab/dashboard':
          return MaterialPageRoute(
            builder: (_) => const LabDashboardScreen(),
          );

        case '/lab/reservations':
          return MaterialPageRoute(
            builder: (_) => const LabReservationsScreen(),
          );
      }
    }

    return MaterialPageRoute(
      builder: (ctx) => _unauthorizedScreen(
        ctx,
        'Ruta no encontrada o no autorizada.',
      ),
    );
  }
}
