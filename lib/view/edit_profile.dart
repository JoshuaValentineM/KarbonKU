import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileDialog extends StatefulWidget {
  final User? user;

  const EditProfileDialog({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String _profilePictureUrl = '';

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  Future<void> _getUserProfile() async {
    if (widget.user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.uid)
          .get();
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>?;
        _nameController.text =
            data?['customDisplayName'] ?? widget.user?.displayName ?? '';
        _locationController.text = data?['location'] ?? '';
        setState(() {
          _profilePictureUrl = data?['profilePicture'] ??
              widget.user?.photoURL ??
              'default_profile_picture_url';
          _imageFile = null;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user?.uid);

      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user?.uid}.jpg');
        await storageRef.putFile(_imageFile!);
        final imageUrl = await storageRef.getDownloadURL();

        await userDocRef.update({
          'profilePicture': imageUrl,
          'customDisplayName': _nameController.text,
          'location': _locationController.text,
        });
      } else {
        await userDocRef.update({
          'customDisplayName': _nameController.text,
          'location': _locationController.text,
        });
      }

      Navigator.pop(context, true);
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ubah Profil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider
                              : NetworkImage(_profilePictureUrl)
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 4,
                          right: 7,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF66D6A6),
                              border: Border.all(
                                color: const Color(0xFF66D6A6),
                                width: 2.0,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Domisili',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Menggunakan SizedBox untuk menyamakan lebar tombol dengan TextField
                  SizedBox(
                    width: double.infinity, // Mengisi seluruh lebar container
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66D6A6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 8),
                      ),
                      onPressed: _updateProfile,
                      child: const Text(
                        'Perbarui',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
