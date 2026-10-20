class UserModel {
  final int id;
  final String nombres;
  final String apellidos;
  final String correo;
  final String telefono;
  final String tipo; // 'Egresado', 'Estudiante', 'Docente'
  final String rol; // 'usuario', 'admin', 'laboratorio'

  const UserModel({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.tipo,
    required this.rol,
  });

  String get fullName => '$nombres $apellidos';

  UserModel copyWith({
    int? id,
    String? nombres,
    String? apellidos,
    String? correo,
    String? telefono,
    String? tipo,
    String? rol,
  }) {
    return UserModel(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      tipo: tipo ?? this.tipo,
      rol: rol ?? this.rol,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id_usuario'] is int
          ? json['id_usuario']
          : json['id'] is int
          ? json['id']
          : int.tryParse(
                  (json['id_usuario'] ?? json['id'] ?? '').toString(),
                ) ??
                0,
      nombres: json['nombres'] ?? json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      correo: json['correo'] ?? json['email'] ?? '',
      telefono: json['telefono'] ?? json['phone'] ?? '',
      tipo: json['tipo'] ?? json['tipo_usuario'] ?? 'Egresado',
      rol: json['rol'] ?? 'usuario',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'tipo': tipo,
      'rol': rol,
    };
  }
}
