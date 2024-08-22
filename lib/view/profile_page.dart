import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../middleware/auth_middleware.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io'; // For File
import 'package:image_picker/image_picker.dart'; // For ImagePicker and XFile
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String displayName = '';
  String profilePicture = '';
  String location = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    var userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user?.uid)
        .get();

    setState(() {
      displayName = userData.data()?['customDisplayName'] ??
          widget.user?.displayName ??
          '';
      profilePicture =
          userData.data()?['profilePicture'] ?? widget.user?.photoURL ?? '';
      location = userData.data()?['location'] ?? 'Location Undefined';
    });
  }

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthMiddleware.checkAuthentication(context);
    User? user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading profile data'));
        }

        var userDoc = snapshot.data;
        String location = 'Location Undefined';
        String profilePicture = user?.photoURL ?? '';
        String displayName = user?.displayName ?? 'Guest';

        // Safely check if the document exists and if the 'location' field is present
        if (userDoc != null && userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('location')) {
            location = data['location'] ?? 'Location Undefined';
            profilePicture = data['profilePicture'] ?? user?.photoURL ?? '';
            displayName = data['customDisplayName'] ?? displayName;
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFEFFFF8),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  color: const Color(0xFF3B645E),
                  child: AppBar(
                    backgroundColor: const Color(0xFF3B645E),
                    title: const Text(
                      'Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      _buildProfileBox(
                          context, user, location, profilePicture, displayName),
                      const SizedBox(height: 20),
                      _buildVehicleBox(context),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A373B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 12),
                        ),
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/auth',
                              (Route<dynamic> route) => false,
                            );
                          } catch (e) {
                            print('Error logging out: $e');
                          }
                        },
                        child: const Text(
                          'Keluar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
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
      },
    );
  }

  Widget _buildProfileBox(BuildContext context, User? user, String location,
      String profilePicture, String displayName) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.only(
              top: 50.0, left: 16.0, right: 16.0, bottom: 16.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A373B), Color(0xFF3B645E)],
              begin: Alignment.center,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                displayName,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                location,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/img/leaf.png',
                        width: 32,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '3521',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: const Color(0xFF66D6A6)),
                          ),
                          const Text(
                            'kg produced',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '4500',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: const Color(0xFF66D6A6)),
                          ),
                          const Text(
                            'km traveled',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'assets/img/pin_range.png',
                        width: 32,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -50,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profilePicture),
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () async {
              // print('Edit profile');
              // Tampilkan modal edit profile
              final result = await showDialog(
                context: context,
                builder: (context) => EditProfileDialog(user: user),
              );
              // If the result is true, indicating the profile was updated, reload the profile data
              if (result == true) {
                _loadUserProfile();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleBox(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Kendaraan Terdaftar",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildVehicleList(context),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF66D6A6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {
                  print('Tambah button pressed');
                },
                child: const Text(
                  'Tambah',
                  style: TextStyle(
                    color: Colors.white, // Text color
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList(BuildContext context) {
    final List<Map<String, String>> vehicles = [
      {"name": "Motorcycle", "icon": "assets/img/motorcycle_icon.png"},
      {"name": "Car", "icon": "assets/img/car_icon.png"},
      {"name": "Motorcycle", "icon": "assets/img/motorcycle_icon.png"},
      {"name": "Car", "icon": "assets/img/car_icon.png"},
      {"name": "Motorcycle", "icon": "assets/img/motorcycle_icon.png"},
      {"name": "Car", "icon": "assets/img/car_icon.png"},
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: vehicles.map((vehicle) {
        return Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A373B),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: Image.asset(
                  vehicle["icon"]!,
                  width: 35,
                ),
                iconSize: 40,
                onPressed: () {
                  print('${vehicle["name"]} button pressed');
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              vehicle["name"]!,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        );
      }).toList(),
    );
  }
}

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
        _locationController.text = data?['location'] ?? 'Location Undefined';
        // Set initial profile picture URL
        setState(() {
          _profilePictureUrl = data?['profilePicture'] ??
              widget.user?.photoURL ??
              'default_profile_picture_url';
          _imageFile = null; // If needed, set initial image
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
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user?.uid}.jpg');
        await storageRef.putFile(_imageFile!);
        final imageUrl = await storageRef.getDownloadURL();

        // Update Firestore with new profile picture URL and custom display name
        await userDocRef.update({
          'profilePicture': imageUrl,
          'customDisplayName': _nameController.text,
          'location': _locationController.text,
        });
      } else {
        // Update Firestore without changing profile picture
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
    return AlertDialog(
      title: const Text('Ubah Profil'),
      content: SingleChildScrollView(
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
                        : NetworkImage(_profilePictureUrl) as ImageProvider,
                    // child: _imageFile == null
                    //     ? const Icon(Icons.camera_alt, color: Colors.white)
                    //     : null,
                  ),
                  Positioned(
                    bottom: 4,
                    right: 7,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF66D6A6), // Background color
                        border: Border.all(
                          // Border definition
                          color:
                              Color(0xFF66D6A6), // Border color using hex code
                          width: 2.0, // Border width
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20, // Icon size
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
                  borderSide: const BorderSide(color: Colors.grey, width: 0.5),
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
                  borderSide: const BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF66D6A6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
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
      ],
    );
  }
}
