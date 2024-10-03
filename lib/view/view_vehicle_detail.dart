import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ViewVehicleDetailForm extends StatefulWidget {
  final String vehicleType;
  final String vehicleName;
  final int vehicleAge;
  final String fuelType;
  final String vehicleId;
  final bool editMode;
  final VoidCallback onUpdated;

  const ViewVehicleDetailForm({
    Key? key,
    required this.vehicleType,
    required this.vehicleName,
    required this.vehicleAge,
    required this.fuelType,
    required this.vehicleId,
    required this.editMode,
    required this.onUpdated,
  }) : super(key: key);

  @override
  _ViewVehicleDetailFormState createState() => _ViewVehicleDetailFormState();
}

class _ViewVehicleDetailFormState extends State<ViewVehicleDetailForm> {
  late TextEditingController vehicleNameController;
  late int vehicleAge;
  late String selectedFuelType;
  late String selectedVehicleType;
  File? _emissionCertificateImage;
  String? _emissionCertificateUrl;

  @override
  void initState() {
    super.initState();
    vehicleNameController = TextEditingController(text: widget.vehicleName);
    vehicleAge = widget.vehicleAge;
    selectedFuelType = widget.fuelType;
    selectedVehicleType = widget.vehicleType;

    // Fetch existing emission certificate URL (if any)
    fetchEmissionCertificateUrl().then((url) {
      setState(() {
        _emissionCertificateUrl = url;
      });
    });
  }

  Future<String?> fetchEmissionCertificateUrl() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('vehicles')
        .doc(widget.vehicleId)
        .get();
    return docSnapshot.data()?['emissionCertificateUrl'] as String?;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _emissionCertificateImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadEmissionCertificate() async {
    if (_emissionCertificateImage == null) return;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('emission_certificates/${widget.vehicleId}');
      await storageRef.putFile(_emissionCertificateImage!);

      // Retrieve the file's download URL
      String downloadUrl = await storageRef.getDownloadURL();

      // Update Firestore with the emission certificate URL
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .update({'emissionCertificateUrl': downloadUrl});

      setState(() {
        _emissionCertificateUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Emission certificate uploaded successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload emission certificate: $e')),
      );
    }
  }

  Future<void> _deleteVehicle() async {
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .delete();
      widget.onUpdated(); // Call the callback to refresh UI
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete vehicle: $e')),
      );
    }
  }

  Future<void> _updateVehicle() async {
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicleId)
          .update({
        'vehicleName': vehicleNameController.text,
        'vehicleAge': vehicleAge,
        'fuelType': selectedFuelType,
        'vehicleType': selectedVehicleType,
      });

      // Upload emission certificate if a new one was selected
      if (_emissionCertificateImage != null) {
        await _uploadEmissionCertificate();
      }

      widget.onUpdated(); // Call the callback to refresh UI
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update vehicle: $e')),
      );
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Apakah Anda yakin ingin menghapus kendaraan ini?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE3E5E5),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    child: const Text('Batal'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFE3E5E5),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                    child: const Text('Hapus'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteVehicle();
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 370,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 30.0),
                  child: Text(
                    'Jenis Kendaraan',
                    style:
                        TextStyle(fontFamily: 'Poppins', color: Colors.black),
                  ),
                ),
                Wrap(
                  spacing: 12.0,
                  children: [
                    GestureDetector(
                      onTap: widget.editMode
                          ? () {
                              setState(() {
                                selectedVehicleType = 'motor';
                              });
                            }
                          : null,
                      child: Image.asset(
                        selectedVehicleType == 'motor'
                            ? 'assets/img/MotorbikeIconFillSelected.png'
                            : 'assets/img/MotorbikeIconFill.png',
                        width: 46,
                        height: 46,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.editMode
                          ? () {
                              setState(() {
                                selectedVehicleType = 'mobil';
                              });
                            }
                          : null,
                      child: Image.asset(
                        selectedVehicleType == 'mobil'
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
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Nama Kendaraan',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.black),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: vehicleNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              ),
              readOnly: !widget.editMode,
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
                    onChanged: widget.editMode
                        ? (double newValue) {
                            setState(() {
                              vehicleAge = newValue.toInt();
                            });
                          }
                        : null,
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
                    style:
                        TextStyle(fontFamily: 'Poppins', color: Colors.black),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedFuelType,
                    items: <String>['Bensin', 'Diesel'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontFamily: 'Poppins'),
                        ),
                      );
                    }).toList(),
                    onChanged: widget.editMode
                        ? (String? newValue) {
                            setState(() {
                              selectedFuelType = newValue!;
                            });
                          }
                        : null,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 12.0),
                    ),
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
                    'Hasil Uji Emisi',
                    style:
                        TextStyle(fontFamily: 'Poppins', color: Colors.black),
                  ),
                ),
                if (widget.editMode)
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _pickImage, // Method to pick image
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload,
                              size: 20,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
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
                  )
                else
                  Expanded(
                    flex: 2,
                    child: _emissionCertificateUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              _emissionCertificateUrl!,
                              width: 100,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Text('No emission certificate'),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.editMode) // Show buttons only in edit mode
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      onPressed:
                          _showDeleteConfirmationDialog, // Show confirmation dialog
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD66666),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: ElevatedButton(
                      onPressed: _updateVehicle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66D6A6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                      child: const Text(
                        'Perbarui',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
