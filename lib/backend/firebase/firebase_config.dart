import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyAv7-DD9AwVkLfg3PKbRNgyPkZUGo8fjCY",
            authDomain: "deficit-calorico-52663.firebaseapp.com",
            projectId: "deficit-calorico-52663",
            storageBucket: "deficit-calorico-52663.firebasestorage.app",
            messagingSenderId: "987021976902",
            appId: "1:987021976902:web:fc7c15b8d91ac256a7f147",
            measurementId: "G-6W6NC87XLV"));
  } else {
    await Firebase.initializeApp();
  }
}
