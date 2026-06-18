import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/local_notification_service.dart';

import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalNotificationService.inicializar();

  runApp(const QuermesseApp());
}

class QuermesseApp extends StatelessWidget {
  const QuermesseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Comunidade São Francisco de Assis",
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7EFE2),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5A2D12),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5A2D12),
            foregroundColor: Colors.white,

            minimumSize: const Size(0, 40),

            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),

            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF5A2D12),
          foregroundColor: Colors.white,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF5A2D12),
              width: 2,
            ),
          ),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        iconTheme: const IconThemeData(
          color: Color(0xFF5A2D12),
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A2D12),
          primary: const Color(0xFF5A2D12),
          secondary: const Color(0xFFF7EFE2),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            iconSize: 18,
          ),
        ),
      ),

      home: const HomeScreen(),
    );
  }
}