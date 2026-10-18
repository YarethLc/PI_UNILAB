
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_flutter/models/user_model.dart';

void main() {
  test('parses the PostgreSQL user ID and type field names', () {
    final user = UserModel.fromJson({
      'id_usuario': 42,
      'nombres': 'Ana',
      'apellidos': 'Prueba',
      'email': 'ana@example.com',
      'telefono': '3000000000',
      'rol': 'USUARIO',
      'tipo_usuario': 'ESTUDIANTE',
    });

    expect(user.id, 42);
    expect(user.correo, 'ana@example.com');
    expect(user.tipo, 'ESTUDIANTE');
  });
}
