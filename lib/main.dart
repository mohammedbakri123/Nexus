// lib/main.dart
import 'package:flutter/material.dart';
import 'package:nexus/features/splash/splash_page.dart';
import 'dart:io' show Platform;

// sqflite desktop initialization
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'package:nexus/core/theme/app_theme.dart';
import 'package:nexus/core/providers/theme_provider.dart';
import 'package:nexus/features/auth/auth_page.dart';
import 'package:nexus/core/navigation/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite FFI for desktop platforms so getDatabasesPath/openDatabase work.
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'NEXUS - Future of Gaming',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashPage(),
            routes: {
              '/auth': (context) => const AuthPage(),
              '/home': (_) => const MainShell(),

              // Add other routes
            },
          );
        },
      ),
    );
  }
}

// const API_KEY = "96a9d6f7f18f49da9d17ea8db9fb33b2";
