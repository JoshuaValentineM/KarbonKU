import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddVehicleForm extends StatefulWidget {
  final void Function(String, String, int, String?) onSubmit;

  const AddVehicleForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _AddVehicleFormState createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<AddVehicleForm> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleNameController = TextEditingController();
  String? _selectedVehicleType;
  String? _fuelType;
  double _vehicleAge = 1; // Initialize with default value

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final vehicleType = _selectedVehicleType ?? '';
      final vehicleName = _vehicleNameController.text;
      final vehicleAge = _vehicleAge.toInt(); // Convert to int

      // Menambahkan data ke Firestore
      FirebaseFirestore.instance.collection('vehicles').add({
        'vehicleType': vehicleType,
        'vehicleName': vehicleName,
        'vehicleAge': vehicleAge,
        'fuelType': _fuelType,
        'userId': FirebaseAuth.instance.currentUser?.uid
      }).then((_) {
        print('Vehicle added successfully');
        widget.onSubmit(vehicleType, vehicleName, vehicleAge, _fuelType);

        final user = FirebaseAuth.instance.currentUser;
        Navigator.pushReplacementNamed(
          context,
          '/profile',
          arguments: user, // Pass user as argument
        );
      }).catchError((error) {
        print('Failed to add vehicle: $error');
      });
    }
  }

  void _selectVehicle(String vehicleType) {
    setState(() {
      _selectedVehicleType = vehicleType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
        width: 370,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row untuk label dan gambar
            Row(
              children: [
                // Label
                Padding(
                  padding: const EdgeInsets.only(right: 30.0), // Jarak antara label dan gambar
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: const TextSpan(
                      text: 'Jenis Kendaraan',
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                // Gambar
                Wrap(
                  spacing: 12.0, // Jarak antara gambar 1 dan 2
                  children: [
                    GestureDetector(
                      onTap: () => _selectVehicle('motor'),
                      child: Image.asset(
                        _selectedVehicleType == 'motor'
                            ? 'assets/img/MotorbikeIconFillSelected.png'
                            : 'assets/img/MotorbikeIconFill.png',
                        width: 46,
                        height: 46,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _selectVehicle('mobil'),
                      child: Image.asset(
                        _selectedVehicleType == 'mobil'
                            ? 'assets/img/CarIconFillSelected.png'
                            : 'assets/img/CarIconFill.png',
                        width: 46,
                        height: 46,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Label di luar box untuk Nama Kendaraan
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: const TextSpan(
                  text: 'Nama Kendaraan',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            // TextFormField untuk Nama Kendaraan dengan border box
            TextFormField(
              controller: _vehicleNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.blue, // Warna border saat di-focus
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Atur padding
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harap masukkan nama kendaraan';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: const TextSpan(
                  text: 'Usia Kendaraan (tahun)',
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Slider(
                    value: _vehicleAge,
                    min: 1,
                    max: 20,
                    divisions: 19,
                    label: _vehicleAge.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _vehicleAge = value;
                      });
                    },
                    activeColor: const Color(0xFF1A373B), // Warna slider saat aktif
                    inactiveColor: const Color(0xFF1A373B), // Warna slider saat tidak aktif
                    thumbColor: const Color(0xFF1A373B), // Warna thumb slider
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
                    _vehicleAge.toInt().toString(),
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Label dan DropdownField dalam satu Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: RichText(
                    text: const TextSpan(
                      text: 'Bahan Bakar',
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _fuelType,
                    items: <String>['Bensin', 'Diesel'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _fuelType = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Harap pilih jenis bahan bakar';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Atur padding
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            // Button Tambahkan
            SizedBox(
              width: double.infinity, // Match the width of the text fields
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF66D6A6), // Set the background color
                  padding: const EdgeInsets.symmetric(vertical: 12.0), // Adjust padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Border radius
                  ),
                ),
                child: const Text(
                  'Tambah',
                  style: TextStyle(
                    color: Colors.white, // Set the text color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
