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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyCuVpqQ2ehQUQQOiRPUu99tZGKeQiSwtM4',
    appId: '1:854162831636:web:93f7cec934d4e712c22a01',
    messagingSenderId: '854162831636',
    projectId: 'myawesome-58b5d',
    authDomain: 'myawesome-58b5d.firebaseapp.com',
    storageBucket: 'myawesome-58b5d.firebasestorage.app',
    measurementId: 'G-W0JHXB4MES',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYmBL32FHflSC3MXvFLiMjnls9CwnYYDo',
    appId: '1:854162831636:android:422af5a3fa66ec3ec22a01',
    messagingSenderId: '854162831636',
    projectId: 'myawesome-58b5d',
    storageBucket: 'myawesome-58b5d.firebasestorage.app',
  );
}
