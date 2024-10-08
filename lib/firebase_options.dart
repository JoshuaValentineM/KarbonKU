// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAbnQ7uMV8ZklKHipDTs0k1E3ZtvCtq0lw',
    appId: '1:624367082894:web:5db1a1efa53d319a4298df',
    messagingSenderId: '624367082894',
    projectId: 'karbonku-d7e7b',
    authDomain: 'karbonku-d7e7b.firebaseapp.com',
    storageBucket: 'karbonku-d7e7b.appspot.com',
    measurementId: 'G-YWVJSK0RZ1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDXnJknfzHN6BHIIi-5nUz2xv9xzM50Wwo',
    appId: '1:624367082894:android:ea31f990903dd6a14298df',
    messagingSenderId: '624367082894',
    projectId: 'karbonku-d7e7b',
    storageBucket: 'karbonku-d7e7b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCL213rEyqZe2Dj3DqDGDV8plbknD2ij78',
    appId: '1:624367082894:ios:0009d0f57b43a71c4298df',
    messagingSenderId: '624367082894',
    projectId: 'karbonku-d7e7b',
    storageBucket: 'karbonku-d7e7b.appspot.com',
    iosBundleId: 'com.example.karbonku',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCL213rEyqZe2Dj3DqDGDV8plbknD2ij78',
    appId: '1:624367082894:ios:0009d0f57b43a71c4298df',
    messagingSenderId: '624367082894',
    projectId: 'karbonku-d7e7b',
    storageBucket: 'karbonku-d7e7b.appspot.com',
    iosBundleId: 'com.example.karbonku',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAbnQ7uMV8ZklKHipDTs0k1E3ZtvCtq0lw',
    appId: '1:624367082894:web:1f504ac95d4f19b54298df',
    messagingSenderId: '624367082894',
    projectId: 'karbonku-d7e7b',
    authDomain: 'karbonku-d7e7b.firebaseapp.com',
    storageBucket: 'karbonku-d7e7b.appspot.com',
    measurementId: 'G-62N4PR9Q4Y',
  );
}
