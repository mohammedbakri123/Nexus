import 'package:flutter/material.dart';
import 'package:nexus/core/storage/session_manager.dart';
import 'package:nexus/features/auth/auth_page.dart';
import 'package:nexus/features/home/home_page.dart';
import 'package:nexus/features/splash/splash_page.dart';

class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SessionManager.isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SplashPage();
        }

        return snapshot.data! ? const HomePage() : const AuthPage();
      },
    );
  }
}
