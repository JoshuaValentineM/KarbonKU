import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karbonku/view/custom_bottom_nav.dart';
import '../middleware/auth_middleware.dart';
import 'add_vehicle_form.dart';
import 'view_vehicle_detail.dart';
import 'edit_profile.dart';
import 'home_page.dart';
import 'education_page.dart';
import 'tracking_page.dart';
import 'calculator_page.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 4;
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
      location = userData.data()?['location'] ?? '';
    });
  }

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/auth');
    } catch (e) {
      print('Error logging out: $e');
    }
  }

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
        String location = '';
        String profilePicture = user?.photoURL ?? '';
        String displayName = user?.displayName ?? 'Guest';

        if (userDoc != null && userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('location')) {
            location = data['location'] ?? '';
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
                        onPressed: () => _signOut(context),
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
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            user: user,
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
                  _showAddVehicleDialog();
                },
                child: const Text(
                  'Tambah',
                  style: TextStyle(
                    color: Colors.white,
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
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    return FutureBuilder<QuerySnapshot>(
      future: firestore
          .collection('vehicles')
          .where('userId', isEqualTo: auth.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching vehicles'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No vehicles found'));
        }

        final List<Map<String, dynamic>> vehicles =
            snapshot.data!.docs.map((doc) {
          String iconPath;
          if (doc['vehicleType'] == 'motor') {
            iconPath = 'assets/img/motorcycle_icon.png';
          } else {
            iconPath = 'assets/img/car_icon.png';
          }

          return {
            "id": doc.id,
            "name": doc['vehicleName'],
            "icon": iconPath,
          };
        }).toList();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: vehicles.map((vehicle) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
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
                        onPressed: () async {
                          DocumentSnapshot vehicleDoc = await firestore
                              .collection('vehicles')
                              .doc(vehicle["id"])
                              .get();

                          if (vehicleDoc.exists) {
                            _showVehicleDetailDialog(
                              context,
                              vehicle["id"],
                              vehicleDoc['vehicleType'],
                              vehicleDoc['vehicleName'],
                              vehicleDoc['vehicleAge'],
                              vehicleDoc['fuelType'],
                            );
                          } else {
                            print('Vehicle not found');
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 70,
                      child: Text(
                        vehicle["name"]!,
                        style: const TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showAddVehicleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Tambah Kendaraan',
            style: TextStyle(fontSize: 20),
          ),
          content: AddVehicleForm(
            onSubmit: (type, name, age, fuel, picture) {
              // Print the result to console
              print('Jenis Kendaraan: $type');
              print('Nama Kendaraan: $name');
              print('Usia Kendaraan: $age');
              print('Jenis Bahan Bakar: $fuel');
              print('Foto Sertifikat : $picture');

              // Data sudah ditambahkan di AddVehicleForm, tidak perlu menambah lagi di sini

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kendaraan berhasil ditambahkan')),
              );
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        );
      },
    );
  }

  void _showVehicleDetailDialog(BuildContext context, String vehicleId,
      String vehicleType, String vehicleName, int vehicleAge, String fuelType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool editMode = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Informasi Kendaraan',
                    style: TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF1A373B),
                    ),
                    onPressed: () {
                      setState(() {
                        editMode = !editMode; // Toggle edit mode
                      });
                    },
                  ),
                ],
              ),
              content: ViewVehicleDetailForm(
                vehicleId: vehicleId,
                vehicleType: vehicleType,
                vehicleName: vehicleName,
                vehicleAge: vehicleAge,
                fuelType: fuelType,
                editMode: editMode,
                onUpdated: _loadUserProfile, // Refresh the profile page
              ),
            );
          },
        );
      },
    );
  }
}
