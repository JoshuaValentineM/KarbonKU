import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AddVehicleForm extends StatefulWidget {
  final void Function(String, String, int, String?, File?) onSubmit;

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
  File? _emissionCertificateImage;

  final ImagePicker _picker = ImagePicker();

  // Method to pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _emissionCertificateImage = File(pickedFile.path);
      });
    }
  }

  // Method to upload image to Firebase Storage and return the download URL
  Future<String?> _uploadImageToStorage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
          'emission_certificates/${DateTime.now().millisecondsSinceEpoch}.png');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final vehicleType = _selectedVehicleType ?? '';
      final vehicleName = _vehicleNameController.text;
      final vehicleAge = _vehicleAge.toInt(); // Convert to int

      String? imageUrl;

      // Upload the image if the user has selected one
      if (_emissionCertificateImage != null) {
        imageUrl = await _uploadImageToStorage(_emissionCertificateImage!);
      }

      // Add data to Firestore
      FirebaseFirestore.instance.collection('vehicles').add({
        'vehicleType': vehicleType,
        'vehicleName': vehicleName,
        'vehicleAge': vehicleAge,
        'fuelType': _fuelType,
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'emissionCertificateUrl': imageUrl // Save the image URL if uploaded
      }).then((_) {
        print('Vehicle added successfully');
        widget.onSubmit(vehicleType, vehicleName, vehicleAge, _fuelType,
            _emissionCertificateImage);

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
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row for label and image
              Row(
                children: [
                  // Label
                  Padding(
                    padding: const EdgeInsets.only(right: 30.0),
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
                  // Images for vehicle type
                  Wrap(
                    spacing: 12.0,
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
              // Vehicle name input field
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
              TextFormField(
                controller: _vehicleNameController,
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap masukkan nama kendaraan';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Vehicle age slider
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
                      _vehicleAge.toInt().toString(),
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Fuel type dropdown
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
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Emission certificate image picker
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: RichText(
                      text: const TextSpan(
                        text: 'Hasil Uji Emisi',
                        style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.upload,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Upload File',
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
               const SizedBox(height: 28),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66D6A6),
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Tambah',
                  style: TextStyle(
                    color: Colors.white,
                  ),
              ),
              ),
            )
            ],
          ),
        ),
      ),
    );
  }
}
