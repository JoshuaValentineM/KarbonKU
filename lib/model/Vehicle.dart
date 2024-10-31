class Vehicle {
  final String vehicleType;
  final String vehicleName;
  final int vehicleEmission;
  final int? vehicleTravel;

  Vehicle({
    required this.vehicleType,
    required this.vehicleName,
    required this.vehicleEmission,
    this.vehicleTravel,
  });
}
