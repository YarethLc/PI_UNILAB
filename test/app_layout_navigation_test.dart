import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/core/routes/app_routes.dart';
import 'package:frontend_flutter/models/user_model.dart';
import 'package:frontend_flutter/screens/admin/admin_dashboard_screen.dart';
import 'package:frontend_flutter/screens/lab/lab_dashboard_screen.dart';
import 'package:frontend_flutter/screens/user/user_home_screen.dart';
import 'package:frontend_flutter/services/auth_session_service.dart';
import 'package:frontend_flutter/widgets/app_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthSessionService().init();
  });

  testWidgets('administrator sees common home and only administrator options', (
    tester,
  ) async {
    await AuthSessionService().saveSession(
      'admin-token',
      const UserModel(
        id: 1,
        nombres: 'Admin',
        apellidos: 'Test',
        correo: 'admin@example.com',
        telefono: '',
        tipo: 'Estudiante',
        rol: 'administrador',
      ),
    );
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(
      MaterialApp(
        home: const AppLayout(
          currentRoute: '/admin/dashboard',
          title: 'Panel Administrativo',
          child: SizedBox(),
        ),
        routes: {'/home': (_) => const Text('Inicio de administrador')},
      ),
    );
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Gestionar reservas'), findsOneWidget);
    expect(find.text('Espacios'), findsNothing);
    expect(find.text('Solicitar reserva'), findsNothing);
    expect(find.text('Mis reservas'), findsNothing);

    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Inicio de administrador'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('student menu keeps student options and common home', (
    tester,
  ) async {
    await AuthSessionService().saveSession(
      'student-token',
      const UserModel(
        id: 2,
        nombres: 'Estudiante',
        apellidos: 'Test',
        correo: 'student@example.com',
        telefono: '',
        tipo: 'Estudiante',
        rol: 'usuario',
      ),
    );
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpWidget(
      const MaterialApp(
        home: AppLayout(
          currentRoute: '/user/home',
          title: 'Inicio',
          child: SizedBox(),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsNWidgets(2));
    expect(find.text('Espacios'), findsOneWidget);
    expect(find.text('Solicitar reserva'), findsOneWidget);
    expect(find.text('Mis reservas'), findsOneWidget);
    expect(find.text('Gestionar reservas'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('the shared home route opens the dashboard for each role', (
    tester,
  ) async {
    const users = [
      UserModel(
        id: 1,
        nombres: 'Admin',
        apellidos: 'Test',
        correo: 'admin@example.com',
        telefono: '',
        tipo: 'Estudiante',
        rol: 'administrador',
      ),
      UserModel(
        id: 2,
        nombres: 'Laboratorio',
        apellidos: 'Test',
        correo: 'lab@example.com',
        telefono: '',
        tipo: 'Docente',
        rol: 'laboratorio',
      ),
      UserModel(
        id: 3,
        nombres: 'Estudiante',
        apellidos: 'Test',
        correo: 'student@example.com',
        telefono: '',
        tipo: 'Estudiante',
        rol: 'usuario',
      ),
    ];
    final dashboardTypes = [
      AdminDashboardScreen,
      LabDashboardScreen,
      UserHomeScreen,
    ];

    for (var i = 0; i < users.length; i++) {
      await AuthSessionService().saveSession('token-$i', users[i]);
      expect(AppRoutes.getInitialRoute(), '/home');
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(i),
          initialRoute: '/home',
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      );
      await tester.pump();

      expect(find.byType(dashboardTypes[i]), findsOneWidget);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.binding.setSurfaceSize(null);
  });
}
