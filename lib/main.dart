import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'pages/input_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: InputPage(),
      ),
    ),
  );
}
