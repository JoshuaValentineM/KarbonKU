import 'package:flutter/material.dart';

class ViewVehicleDetailForm extends StatelessWidget {
  final String vehicleType;
  final String vehicleName;
  final int vehicleAge;
  final String fuelType;

  const ViewVehicleDetailForm({
    Key? key,
    required this.vehicleType,
    required this.vehicleName,
    required this.vehicleAge,
    required this.fuelType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 370,
      height: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 30.0),
                child: Text(
                  'Jenis Kendaraan',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
                ),
              ),
              Wrap(
                spacing: 12.0,
                children: [
                  vehicleType == 'motor' 
                  ? Image.asset(
                    'assets/img/MotorbikeIconFill.png',
                    width: 46,
                    height: 46,
                  )
                  : Image.asset(
                    'assets/img/CarIconFill.png',
                    width: 46,
                    height: 46,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Nama Kendaraan',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            initialValue: vehicleName,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            ),
            readOnly: true, // Set the TextFormField to be non-editable
          ),
          const SizedBox(height: 14),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Usia Kendaraan (tahun)',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Slider(
                  value: vehicleAge.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: vehicleAge.toString(),
                  onChanged: null, // Disable slider interaction
                  activeColor: const Color(0xFF1A373B),
                  inactiveColor: const Color(0xFF1A373B),
                  thumbColor: const Color(0xFF1A373B),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 50,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  vehicleAge.toString(),
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'Bahan Bakar',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
                ),
              ),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: fuelType,
                  items: <String>['Bensin', 'Diesel'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                    );
                  }).toList(),
                  onChanged: null, // Disable dropdown interaction
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
