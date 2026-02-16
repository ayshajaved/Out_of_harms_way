import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyDiD5c9bhaCf89TlYi5OTLX4yVXrNM3qt8",
    authDomain: "out-of-harms-way-14cfb.firebaseapp.com",
    projectId: "out-of-harms-way-14cfb",
    storageBucket: "out-of-harms-way-14cfb.firebasestorage.app",
    messagingSenderId: "809219061277",
    appId: "1:809219061277:web:b9485162225ebd8c6838f4",
    measurementId: "G-VCL4C9LN7B",
  );

  static FirebaseOptions get currentPlatform => web;
}
