class SpaceModel {
  final String id;
  final String name;
  final String type; // 'Laboratorio', 'Sala de estudio', 'Aula', 'Auditorio', 'Sala'
  final String location;
  final int capacity;
  final String resources;
  final String availability; // 'Disponible', 'Ocupado'
  final String status;
  final String schedule;
  final String icon;

  const SpaceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.capacity,
    required this.resources,
    required this.availability,
    required this.status,
    required this.schedule,
    required this.icon,
  });

  bool get isAvailable => availability.toLowerCase() == 'disponible';

  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    return SpaceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? json['nombre'] ?? '',
      type: json['type'] ?? json['tipo'] ?? '',
      location: json['location'] ?? json['ubicacion'] ?? '',
      capacity: json['capacity'] ?? json['capacidad'] ?? 0,
      resources: json['resources'] ?? json['recursos'] ?? '',
      availability: json['availability'] ?? json['disponibilidad'] ?? 'Disponible',
      status: json['status'] ?? json['estado'] ?? 'Disponible',
      schedule: json['schedule'] ?? json['horario'] ?? '',
      icon: json['icon'] ?? '⌘',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'location': location,
      'capacity': capacity,
      'resources': resources,
      'availability': availability,
      'status': status,
      'schedule': schedule,
      'icon': icon,
    };
  }
}
