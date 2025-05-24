// ignore_for_file: unused_local_variable

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hackaton_sheepai_2025/firebase_options.dart';
import 'package:hackaton_sheepai_2025/pages/auth/auth_page.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  var box = await Hive.openBox('myBox'); 
if (!box.containsKey('money')) {
  await box.put('money', 120); 
}



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
