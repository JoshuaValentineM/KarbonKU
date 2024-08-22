import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Save user data to Firestore
        print('Google Sign-In successful, Data User: ${user.toString()}');
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
          'lastSignIn': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        // Successfully signed in
        print('Google Sign-In successful: ${user.displayName}');
        // Navigate to HomePage
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print('Google Sign-In error: $e');
    }
  }

  Future<void> _signInWithTwitter(BuildContext context) async {
    try {
      // Create a TwitterAuthProvider instance
      final twitterProvider = TwitterAuthProvider();

      // Attempt to sign in with Twitter
      final UserCredential userCredential =
          await _auth.signInWithProvider(twitterProvider);
      final User? user = userCredential.user;

      if (user != null) {
        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
          'lastSignIn': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        // Successfully signed in
        print('Twitter Sign-In successful: ${user.displayName}');
        // Navigate to HomePage
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on auth.FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException specifically
      switch (e.code) {
        case 'account-exists-with-different-credential':
          print('The account already exists with a different credential.');
          break;
        case 'invalid-credential':
          print('The credential is invalid.');
          break;
        case 'operation-not-allowed':
          print(
              'Operation not allowed. Please make sure you have enabled the provider.');
          break;
        case 'user-disabled':
          print('The user account has been disabled.');
          break;
        case 'user-not-found':
          print('No user found for the given credential.');
          break;
        case 'wrong-password':
          print('The password is incorrect.');
          break;
        case 'credential-already-in-use':
          print('The credential is already in use.');
          break;
        default:
          print('An undefined Error happened: ${e.message}');
      }
    } catch (e) {
      // Handle other types of errors (network issues, unexpected exceptions)
      print('An unexpected error occurred: $e');
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential facebookCredential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        final UserCredential userCredential =
            await _auth.signInWithCredential(facebookCredential);
        final User? user = userCredential.user;

        if (user != null) {
          // Save user data to Firestore
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName,
            'email': user.email,
            'photoUrl': user.photoURL,
            'lastSignIn': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          // Successfully signed in
          print('Facebook Sign-In successful: ${user.displayName}');
          // Navigate to HomePage
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Handle login error
        print('Facebook Sign-In error: ${result.message}');
      }
    } catch (e) {
      print('Facebook Sign-In error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFEFFFF8), // Background color
        ),
        child: Stack(
          children: [
            // Top image
            Positioned.fill(
              top: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'assets/img/auth_header.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            // Centered white box
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'DAFTAR/MASUK',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                    const SizedBox(height: 20),
                    _signInButton(
                      onPressed: () => _signInWithGoogle(context),
                      imagePath: 'assets/img/logo_google.png',
                      text: 'Lanjutkan dengan Google',
                    ),
                    const SizedBox(height: 10),
                    _signInButton(
                      onPressed: () => _signInWithTwitter(context),
                      imagePath: 'assets/img/logo_x.png',
                      text: 'Lanjutkan dengan X',
                    ),
                    const SizedBox(height: 10),
                    _signInButton(
                      onPressed: () => _signInWithFacebook(context),
                      imagePath: 'assets/img/logo_facebook.png',
                      text: 'Lanjutkan dengan Facebook',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _signInButton({
    required VoidCallback onPressed,
    required String imagePath,
    required String text,
  }) {
    return Container(
      margin:
          const EdgeInsets.symmetric(vertical: 5), // Add vertical margin here
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            backgroundColor: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                imagePath,
                height: 40,
                width: 45,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
