// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyDIaWwB0DPtAX82vOdAcbJR1m_AZfVIJyA',
    appId: '1:740336409478:web:3fa8ca76c665fecaf1aa07',
    messagingSenderId: '740336409478',
    projectId: 'memoir-app-bloc',
    authDomain: 'memoir-app-bloc.firebaseapp.com',
    storageBucket: 'memoir-app-bloc.appspot.com',
    measurementId: 'G-VZLQJMSQ4G',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCarD69NMYylQAM7bM0HP4Nx7d72Irqo7g',
    appId: '1:740336409478:android:28c54176f066b03ef1aa07',
    messagingSenderId: '740336409478',
    projectId: 'memoir-app-bloc',
    storageBucket: 'memoir-app-bloc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCxqln6fIU3Czp1S2vrsjWkVDiUsOluUqE',
    appId: '1:740336409478:ios:abe526253b08be24f1aa07',
    messagingSenderId: '740336409478',
    projectId: 'memoir-app-bloc',
    storageBucket: 'memoir-app-bloc.appspot.com',
    iosClientId: '740336409478-rua1qf9iel0mdidmev4ck2kclo0mbnl3.apps.googleusercontent.com',
    iosBundleId: 'com.example.memoirAppBloc',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCxqln6fIU3Czp1S2vrsjWkVDiUsOluUqE',
    appId: '1:740336409478:ios:abe526253b08be24f1aa07',
    messagingSenderId: '740336409478',
    projectId: 'memoir-app-bloc',
    storageBucket: 'memoir-app-bloc.appspot.com',
    iosClientId: '740336409478-rua1qf9iel0mdidmev4ck2kclo0mbnl3.apps.googleusercontent.com',
    iosBundleId: 'com.example.memoirAppBloc',
  );
}
