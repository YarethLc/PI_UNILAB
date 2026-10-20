class AttendanceModel {
  final int id;
  final String spaceName;
  final String date;
  final String time;
  final String status; // 'Registrada', 'Pendiente', 'Vencida'
  final String code;

  const AttendanceModel({
    required this.id,
    required this.spaceName,
    required this.date,
    required this.time,
    required this.status,
    required this.code,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      spaceName: json['spaceName'] ?? json['espacio'] ?? '',
      date: json['date'] ?? json['fecha'] ?? '',
      time: json['time'] ?? json['hora'] ?? '',
      status: json['status'] ?? json['estado'] ?? 'Registrada',
      code: json['code'] ?? json['codigo'] ?? '',
    );
  }
}
