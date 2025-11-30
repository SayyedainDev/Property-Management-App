import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project/Model/OwnerModel.dart';

import 'package:project/theme/theme.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import "package:shared_preferences/shared_preferences.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(OwnermodelAdapter()); // <-- You'll create this adapter

  await Hive.openBox('propertyBox');

  // 1️⃣ Load .env BEFORE using its variables
  await dotenv.load(fileName: ".env");

  // Debug check

  // 2️⃣ Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3️⃣ SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('token');

  // 4️⃣ Initialize Supabase with env variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 5️⃣ Run app
  runApp(
    DevicePreview(enabled: true, builder: (context) => MyApp(token: token)),
  );
}

class MyApp extends StatelessWidget {
  final String? token;

  MyApp({required this.token});

  @override
  Widget build(BuildContext context) {
    return theme(tokens: token);
  }
}
