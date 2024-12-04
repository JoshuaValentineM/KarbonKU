class Vehicle {
  final String vehicleType;
  final String vehicleName;
  final double vehicleEmission;
  final double vehicleTravel;

  Vehicle({
    required this.vehicleType,
    required this.vehicleName,
    required this.vehicleEmission,
    required this.vehicleTravel,
  });

  // Method untuk membuat instance dari Map (Firestore)
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      vehicleType: map['vehicleType'] ?? 'Unknown',
      vehicleName: map['vehicleName'] ?? 'Unknown',
      vehicleEmission: map['vehicleEmission']?.toDouble() ?? 0.0,
      vehicleTravel: map['vehicleTravel']?.toDouble() ?? 0.0,
    );
  }
}
