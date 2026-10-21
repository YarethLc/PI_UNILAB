class ReservationModel {
  final int id;
  final String spaceName;
  final String date; // YYYY-MM-DD
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final String status; // 'Confirmada', 'Pendiente', 'Cancelada', 'Finalizada'
  final String? purpose;
  final String? userName;

  const ReservationModel({
    required this.id,
    required this.spaceName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.purpose,
    this.userName,
  });

  ReservationModel copyWith({
    int? id,
    String? spaceName,
    String? date,
    String? startTime,
    String? endTime,
    String? status,
    String? purpose,
    String? userName,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      spaceName: spaceName ?? this.spaceName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      purpose: purpose ?? this.purpose,
      userName: userName ?? this.userName,
    );
  }

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      spaceName: json['espacio'] ?? json['spaceName'] ?? '',
      date: json['fecha'] ?? json['date'] ?? '',
      startTime: json['inicio'] ?? json['startTime'] ?? '',
      endTime: json['fin'] ?? json['endTime'] ?? '',
      status: json['estado'] ?? json['status'] ?? 'Pendiente',
      purpose: json['motivo'] ?? json['purpose'],
      userName: json['usuario'] ?? json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'espacio': spaceName,
      'fecha': date,
      'inicio': startTime,
      'fin': endTime,
      'estado': status,
      'motivo': purpose,
      'usuario': userName,
    };
  }
}
