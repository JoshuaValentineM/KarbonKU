import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:karbonku/view/custom_bottom_nav.dart';
import 'package:url_launcher/url_launcher.dart';
import '../middleware/auth_middleware.dart';

import 'package:firebase_auth/firebase_auth.dart';

class EducationPage extends StatelessWidget {
  EducationPage({super.key});
  int _selectedIndex = 3;
  final user = FirebaseAuth.instance.currentUser;

  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  String formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.day} ${_monthNames[date.month - 1]} ${date.year}";
  }

  Future<List<Map<String, dynamic>>> _fetchVideos() async {
    final videoCollection = FirebaseFirestore.instance.collection('videos');
    final snapshot = await videoCollection.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchArticles() async {
    final articleCollection = FirebaseFirestore.instance.collection('articles');
    final snapshot = await articleCollection.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<String>> _fetchInfographics() async {
    final infographicCollection =
        FirebaseFirestore.instance.collection('infographics');
    final snapshot = await infographicCollection.get();
    return snapshot.docs.map((doc) => doc.data()['image'] as String).toList();
  }

  Future<String> _getImageUrl(String imagePath) async {
    final ref = FirebaseStorage.instance.ref().child(imagePath);
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFFF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B645E),
        elevation: 0,
        title: const Text(
          'Education',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: Future.wait([
          _fetchVideos(),
          _fetchArticles(),
          _fetchInfographics(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final videoData = snapshot.data![0] as List<Map<String, dynamic>>;
          final articleData = snapshot.data![1] as List<Map<String, dynamic>>;
          final infographicData = snapshot.data![2] as List<String>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Informative Videos
                  const Text(
                    'Video Rekomendasi',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  _buildHorizontalVideoScroll(videoData),

                  const SizedBox(height: 30),

                  // Section 2: Articles
                  const Text(
                    'Artikel',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  _buildHorizontalArticleScroll(articleData),

                  const SizedBox(height: 10),

                  // Section 3: Infographics
                  const Text(
                    'Infografis',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  _buildHorizontalInfographicScroll(infographicData),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        user: user,
      ),
    );
  }

  Widget _buildHorizontalVideoScroll(
      List<Map<String, dynamic>> videoThumbnails) {
    return SizedBox(
      height: 125,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: videoThumbnails.length,
        itemBuilder: (context, index) {
          final video = videoThumbnails[index];
          final imageUrl = video['imageUrl']; // Already contains full URL
          final title = video['title'];
          final videoUrl = video['url'];

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () async {
                Uri videoUri = Uri.parse(videoUrl);
                if (await canLaunchUrl(videoUri)) {
                  await launchUrl(videoUri,
                      mode: LaunchMode.externalApplication);
                } else {
                  print('Could not launch $videoUrl');
                }
              },
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
                      width: 175,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    width: 150, // Maximum width for the title
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Add "..." if text overflows
                      textAlign: TextAlign.center, // Optional for alignment
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalArticleScroll(List<Map<String, dynamic>> articles) {
    return SizedBox(
      height: 345,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 3 / 2.5,
        ),
        itemCount: (articles.length / 3).ceil(),
        itemBuilder: (context, index) {
          final startIndex = index * 3;
          final endIndex = (startIndex + 3 > articles.length)
              ? articles.length
              : startIndex + 3;
          final columnArticles = articles.sublist(startIndex, endIndex);

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columnArticles.map((article) {
                final imageUrl = article['image']; // Full URL
                final title = article['title'];
                final source = article['source'];
                final url = article['url'];
                final date = article['date'] as Timestamp;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: SizedBox(
                    width: 800, // Increased width to fit the date
                    child: GestureDetector(
                      onTap: () async {
                        Uri articleUri = Uri.parse(url);
                        if (await canLaunchUrl(articleUri)) {
                          await launchUrl(articleUri,
                              mode: LaunchMode.externalApplication);
                        } else {
                          print('Could not launch $url');
                        }
                      },
                      child: _buildArticleRow(
                        imageUrl: imageUrl,
                        title: title,
                        source: source,
                        date: date,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticleRow({
    required String imageUrl,
    required String title,
    required String source,
    required Timestamp date,
  }) {
    final formattedDate = formatTimestamp(date); // Only keep the date part

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  '$source · $formattedDate',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalInfographicScroll(List<String> infographicThumbnails) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: infographicThumbnails.length,
        itemBuilder: (context, index) {
          final imageUrl =
              infographicThumbnails[index]; // Directly use the path

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Tampilkan gambar lebih besar dalam popup
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Gambar yang diperbesar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // // Tombol close
                          // TextButton(
                          //   onPressed: () {
                          //     Navigator.of(context).pop(); // Tutup dialog
                          //   },
                          //   child: const Text("Close"),
                          // ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  imageUrl, // Directly use the image URL
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
