import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/reservation_model.dart';
import '../models/schedule_model.dart';
import '../models/space_model.dart';
import '../models/user_model.dart';
import 'auth_session_service.dart';

class ApiService {
  // En Web o Desktop se usa localhost:3000.
  // En el Emulador de Android, localhost es el emulador mismo; la IP del host de la PC es 10.0.2.2.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static Map<String, String> _headers({bool needsAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (needsAuth) {
      final token = AuthSessionService().token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map) {
        if (data.containsKey('mensaje')) return data['mensaje'].toString();
        if (data.containsKey('error')) return data['error'].toString();
        if (data.containsKey('message')) return data['message'].toString();
      }
    } catch (_) {}

    switch (response.statusCode) {
      case 400:
        return 'Solicitud inválida. Revisa los datos ingresados.';
      case 401:
        return 'Credenciales incorrectas o sesión no autorizada.';
      case 403:
        return 'Acceso denegado: no tienes permisos para esta función.';
      case 404:
        return 'Recurso no encontrado en el servidor.';
      case 409:
        return 'Conflicto: ya existe un registro con esos datos.';
      case 500:
        return 'Error interno del servidor. Por favor intenta más tarde.';
      default:
        return 'Error inesperado del servidor (Código ${response.statusCode}).';
    }
  }

  // ==========================================
  // AUTENTICACIÓN & USUARIOS
  // ==========================================

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers(needsAuth: false),
        body: jsonEncode({
          'email': email.trim(),
          'contrasena': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final token = data['token'] as String;
        final user = UserModel.fromJson(data['usuario']);

        await AuthSessionService().saveSession(token, user);

        return {
          'success': true,
          'token': token,
          'usuario': user,
        };
      } else {
        return {
          'success': false,
          'error': _extractErrorMessage(response),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error':
            'No se pudo conectar con el servidor ($baseUrl). Verifica que el backend esté iniciado.',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String nombres,
    required String apellidos,
    required String email,
    required String telefono,
    required String contrasena,
    required String confirmarContrasena,
    required String tipoUsuario,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers(needsAuth: false),
        body: jsonEncode({
          'nombres': nombres.trim(),
          'apellidos': apellidos.trim(),
          'email': email.trim().toLowerCase(),
          'telefono': telefono.trim(),
          'contrasena': contrasena,
          'confirmarContrasena': confirmarContrasena,
          'tipo_usuario': tipoUsuario.trim().toUpperCase(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          'success': true,
          'mensaje': data['mensaje'] ?? 'Usuario registrado exitosamente',
        };
      } else {
        return {
          'success': false,
          'error': _extractErrorMessage(response),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error':
            'Error de conexión con el backend. Verifica que el servidor esté activo.',
      };
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String nombres,
    required String apellidos,
    required String telefono,
    required String email,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/auth/perfil'),
            headers: _headers(),
            body: jsonEncode({
              'nombres': nombres.trim(),
              'apellidos': apellidos.trim(),
              'telefono': telefono.trim(),
              'email': email.trim().toLowerCase(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 &&
          data is Map<String, dynamic> &&
          data['usuario'] is Map<String, dynamic>) {
        final updated = UserModel.fromJson(
          data['usuario'] as Map<String, dynamic>,
        );

        await AuthSessionService().updateCurrentUser(updated);

        return {
          'success': true,
          'mensaje': data['mensaje'] ?? 'Perfil actualizado correctamente.',
          'usuario': updated,
        };
      }

      return {
        'success': false,
        'error': data is Map<String, dynamic>
            ? data['mensaje'] ??
                data['error'] ??
                data['message'] ??
                'No se pudo actualizar el perfil.'
            : 'El servidor devolvió una respuesta inválida.',
      };
    } catch (e) {
      debugPrint('Error actualizando perfil: $e');

      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor al actualizar el perfil.',
      };
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String contrasenaActual,
    required String nuevaContrasena,
    required String confirmarContrasena,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/cambiar-password'),
        headers: _headers(),
        body: jsonEncode({
          'contrasenaActual': contrasenaActual,
          'nuevaContrasena': nuevaContrasena,
          'confirmarContrasena': confirmarContrasena,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'mensaje': data['mensaje'] ??
              data['message'] ??
              'Contraseña actualizada correctamente.',
        };
      }

      return {
        'success': false,
        'error': data['mensaje'] ??
            data['message'] ??
            data['error'] ??
            'No fue posible cambiar la contraseña.',
      };
    } catch (e) {
      debugPrint('Error al cambiar contraseña: $e');

      return {
        'success': false,
        'error': 'Error de conexión al cambiar contraseña.',
      };
    }
  }

  static Future<List<UserModel>> fetchUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/usuarios'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((u) => UserModel.fromJson(u)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ==========================================
  // HORARIOS INSTITUCIONALES
  // ==========================================

  static Future<List<ScheduleModel>> fetchSchedules({int? labId}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/horarios'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    if (data is! List) {
      throw const FormatException(
        'La respuesta de horarios no es una lista.',
      );
    }

    return data
        .map((item) => ScheduleModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  static Future<ScheduleModel> createSchedule({
    required int weekday,
    required String opensAt,
    required String closesAt,
    int? labId,
  }) async {
    _validateScheduleTimes(weekday, opensAt, closesAt);

    final response = await http.post(
      Uri.parse('$baseUrl/horarios'),
      headers: _headers(),
      body: jsonEncode({
        'dia_semana': weekday,
        'hora_apertura': opensAt,
        'hora_cierre': closesAt,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_extractErrorMessage(response));
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));

    return ScheduleModel.fromJson(
      Map<String, dynamic>.from(data['horario'] as Map),
    );
  }

  static Future<ScheduleModel> updateSchedule({
    required int id,
    required int weekday,
    required String opensAt,
    required String closesAt,
  }) async {
    _validateScheduleTimes(weekday, opensAt, closesAt);

    final response = await http.put(
      Uri.parse('$baseUrl/horarios/$id'),
      headers: _headers(),
      body: jsonEncode({
        'dia_semana': weekday,
        'hora_apertura': opensAt,
        'hora_cierre': closesAt,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final horario = Map<String, dynamic>.from(data['horario'] as Map);

    return ScheduleModel.fromJson(horario);
  }

  static Future<void> deleteSchedule(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/horarios/$id'),
      headers: _headers(),
    );

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }
  }

  static void _validateScheduleTimes(
    int weekday,
    String opensAt,
    String closesAt,
  ) {
    if (weekday < 1 || weekday > 7) {
      throw ArgumentError('El día debe estar entre 1 y 7.');
    }

    if (opensAt.compareTo(closesAt) >= 0) {
      throw ArgumentError(
        'La hora de cierre debe ser posterior a la apertura.',
      );
    }
  }

  // ==========================================
  // LABORATORIOS / ESPACIOS
  // ==========================================

  static Future<List<SpaceModel>> fetchLaboratorios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/laboratorios'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((item) {
          final idLab = item['id_laboratorio']?.toString() ?? '';
          return SpaceModel(
            id: idLab,
            name: item['nombre'] ?? '',
            type: 'Laboratorio',
            location: item['ubicacion'] ?? 'Campus UCEVA',
            capacity: item['capacidad'] is int
                ? item['capacidad']
                : int.tryParse(item['capacidad']?.toString() ?? '20') ?? 20,
            resources: 'Equipos y conectividad de laboratorio',
            availability:
                (item['estado'] ?? '').toString().toUpperCase() == 'DISPONIBLE'
                    ? 'Disponible'
                    : 'Ocupado',
            status: item['estado'] ?? 'Disponible',
            schedule: 'Lunes a viernes, 8:00 a. m. – 6:00 p. m.',
            icon: '💻',
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createLaboratorio({
    required String nombre,
    required String ubicacion,
    required String estado,
    required int capacidad,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/laboratorios'),
        headers: _headers(),
        body: jsonEncode({
          'nombre': nombre.trim(),
          'ubicacion': ubicacion.trim(),
          'estado': estado.trim().toUpperCase(),
          'capacidad': capacidad,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        return {'success': false, 'error': _extractErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión con el backend.'};
    }
  }

  static Future<Map<String, dynamic>> updateLaboratorio({
    required String id,
    required String nombre,
    required String ubicacion,
    required String estado,
    required int capacidad,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/laboratorios/$id'),
        headers: _headers(),
        body: jsonEncode({
          'nombre': nombre.trim(),
          'ubicacion': ubicacion.trim(),
          'estado': estado.trim().toUpperCase(),
          'capacidad': capacidad,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'error': _extractErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión con el backend.'};
    }
  }

  static Future<Map<String, dynamic>> deleteLaboratorio(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/laboratorios/$id'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'error': _extractErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión con el backend.'};
    }
  }

  // ==========================================
  // RESERVAS
  // ==========================================

  static Future<List<ReservationModel>> fetchReservas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        final dynamic raw = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> data = raw is List ? raw : [raw];
        return data.map((item) {
          final idRes = item['id_reserva'] is int
              ? item['id_reserva']
              : int.tryParse(item['id_reserva']?.toString() ?? '0') ?? 0;
          final labNombre =
              item['laboratorio'] ?? item['nombre'] ?? 'Laboratorio';
          final solicitante =
              (item['nombres'] != null && item['apellidos'] != null)
                  ? '${item['nombres']} ${item['apellidos']}'
                  : null;
          final horaIni =
              item['hora_inicio']?.toString().substring(0, 5) ?? '08:00';
          final horaFin =
              item['hora_fin']?.toString().substring(0, 5) ?? '10:00';

          return ReservationModel(
            id: idRes,
            spaceName: labNombre,
            date: item['fecha']?.toString().split('T')[0] ?? '',
            startTime: horaIni,
            endTime: horaFin,
            status: item['estado'] ?? 'PENDIENTE',
            purpose: 'Actividad académica',
            userName: solicitante,
          );
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createReserva({
    required int idLaboratorio,
    required String fecha, // YYYY-MM-DD
    required String horaInicio, // HH:MM
    required String horaFin, // HH:MM
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservas'),
        headers: _headers(),
        body: jsonEncode({
          'id_laboratorio': idLaboratorio,
          'fecha': fecha,
          'horaInicio': horaInicio,
          'horaFin': horaFin,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        return {'success': false, 'error': _extractErrorMessage(response)};
      }
    } catch (e) {
      return {'success': false, 'error': 'Error de conexión al crear reserva.'};
    }
  }

  static Future<Map<String, dynamic>> cancelReserva(int idReserva) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/reservas/$idReserva'),
        headers: _headers(),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'error': _extractErrorMessage(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión al cancelar reserva.'
      };
    }
  }

  static Future<Map<String, dynamic>> updateEstadoReserva(
      int idReserva, String nuevoEstado) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/reservas/$idReserva/estado'),
        headers: _headers(),
        body: jsonEncode({'estado': nuevoEstado.toUpperCase()}),
      );

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': false, 'error': _extractErrorMessage(response)};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexión al actualizar estado.'
      };
    }
  }

  // ==========================================
  // ASISTENCIA
  // ==========================================

  static Future<Map<String, dynamic>> registrarEntrada({
    required int idLaboratorio,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/asistencia/entrada'),
            headers: _headers(),
            body: jsonEncode({
              'id_laboratorio': idLaboratorio,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 201) {
        return {
          'success': true,
          'mensaje': data is Map
              ? data['mensaje'] ?? 'Entrada registrada correctamente.'
              : 'Entrada registrada correctamente.',
        };
      }

      return {
        'success': false,
        'error': data is Map
            ? data['mensaje'] ??
                data['error'] ??
                'No se pudo registrar la entrada.'
            : 'No se pudo registrar la entrada.',
      };
    } catch (e) {
      debugPrint('Error registrando entrada: $e');

      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor.',
      };
    }
  }

  static Future<Map<String, dynamic>> registrarSalida() async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/asistencia/salida'),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 15));

      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'mensaje': data is Map
              ? data['mensaje'] ?? 'Salida registrada correctamente.'
              : 'Salida registrada correctamente.',
        };
      }

      return {
        'success': false,
        'error': data is Map
            ? data['mensaje'] ??
                data['error'] ??
                'No se pudo registrar la salida.'
            : 'No se pudo registrar la salida.',
      };
    } catch (e) {
      debugPrint('Error registrando salida: $e');

      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor.',
      };
    }
  }

  static Future<List<Map<String, dynamic>>> fetchHistorialAsistencia() async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/asistencia/historial'),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(_extractErrorMessage(response));
    }

    final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

    if (data is! List) {
      throw const FormatException(
        'La respuesta del historial de asistencia no es una lista.',
      );
    }

    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  // ==========================================
  // RECUPERACIÓN DE CONTRASEÑA
  // ==========================================

  static Future<Map<String, dynamic>> solicitarCodigoRecuperacion(
    String email,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/recuperar-password'),
            headers: _headers(needsAuth: false),
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'mensaje': data is Map
              ? data['mensaje'] ?? 'Solicitud procesada.'
              : 'Solicitud procesada.',
        };
      }

      return {
        'success': false,
        'error': _extractErrorMessage(response),
      };
    } catch (e) {
      debugPrint('Error solicitando recuperación: $e');
      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor.',
      };
    }
  }

  static Future<Map<String, dynamic>> verificarCodigoRecuperacion({
    required String email,
    required String codigo,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/verificar-codigo'),
            headers: _headers(needsAuth: false),
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'codigo': codigo.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 &&
          data is Map &&
          data['token_recuperacion'] != null) {
        return {
          'success': true,
          'mensaje': data['mensaje'] ?? 'Código verificado correctamente.',
          'token_recuperacion': data['token_recuperacion'].toString(),
        };
      }

      return {
        'success': false,
        'error': _extractErrorMessage(response),
      };
    } catch (e) {
      debugPrint('Error verificando código: $e');
      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor.',
      };
    }
  }

  static Future<Map<String, dynamic>> restablecerContrasena({
    required String tokenRecuperacion,
    required String nuevaContrasena,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/nueva-password'),
            headers: _headers(needsAuth: false),
            body: jsonEncode({
              'token_recuperacion': tokenRecuperacion,
              'nuevaContrasena': nuevaContrasena,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final dynamic data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'mensaje': data is Map
              ? data['mensaje'] ?? 'Contraseña actualizada correctamente.'
              : 'Contraseña actualizada correctamente.',
        };
      }

      return {
        'success': false,
        'error': _extractErrorMessage(response),
      };
    } catch (e) {
      debugPrint('Error restableciendo contraseña: $e');
      return {
        'success': false,
        'error': 'No se pudo conectar con el servidor.',
      };
    }
  }
}
