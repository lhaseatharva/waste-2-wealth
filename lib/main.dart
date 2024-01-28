import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waste2wealth/Provider/pickuprequest_provider.dart';
import 'package:waste2wealth/Provider/registration_provider.dart';

import 'screens/Home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyBfOzKM2uzmdEdf7xHk25I2-VKgy2K2HLA',
              appId: '1:873819962396:android:6c769c7dc0e8f906d4b3d9',
              messagingSenderId: '873819962396',
              projectId: 'waste2wealth-92dfb'))
      : await Firebase.initializeApp();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RegistrationProvider()),
        ChangeNotifierProvider(create: (context) => PickupRequestProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
