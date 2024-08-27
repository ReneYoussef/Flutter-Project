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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBpctCcZ2SRQS0g2_EdjVBY9Jknt1-JSEQ',
    appId: '1:605295722573:android:b49c7fcbb594db5d8adc04',
    messagingSenderId: '605295722573',
    projectId: 'adminielect',
    storageBucket: 'adminielect.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBSGzVMW4FkQUtMAaYSd958ja52haK8LRk',
    appId: '1:605295722573:ios:23e8410ef01e31368adc04',
    messagingSenderId: '605295722573',
    projectId: 'adminielect',
    storageBucket: 'adminielect.appspot.com',
    iosBundleId: 'com.example.ielect',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDza7w0QKAgo_Sa26sQRc_iATHXQxda-CM',
    appId: '1:605295722573:web:15aca933efd6bb9b8adc04',
    messagingSenderId: '605295722573',
    projectId: 'adminielect',
    authDomain: 'adminielect.firebaseapp.com',
    storageBucket: 'adminielect.appspot.com',
  );

}