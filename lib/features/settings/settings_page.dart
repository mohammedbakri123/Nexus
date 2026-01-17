import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nexus/features/profile/edit_profile_page.dart';
import 'package:nexus/features/profile/profile_page.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/storage/session_manager.dart';
import '../../core/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            _title(),
            const SizedBox(height: 16),
            _profileCard(context),
            const SizedBox(height: 24),

            _sectionLabel('DISPLAY'),
            _glassTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              trailing: Switch(
                value: isDark,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ),

            _glassTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
              },
            ),

            _glassTile(
              icon: Icons.security_outlined,
              title: 'Security & Privacy',
              onTap: () {},
            ),
            _glassTile(
              icon: Icons.emoji_events_outlined,
              title: 'Gaming Achievements',
              onTap: () {},
            ),

            const SizedBox(height: 24),
            _sectionLabel('PREFERENCES'),
            _glassTile(
              icon: Icons.notifications_none,
              title: 'Notifications',
              trailing: _purpleSwitch(true),
            ),
            _glassTile(
              icon: Icons.vibration_outlined,
              title: 'Haptic Feedback',
              trailing: _purpleSwitch(true),
            ),
            _glassTile(
              icon: Icons.flash_on_outlined,
              title: 'High Performance Mode',
              trailing: _purpleSwitch(false),
            ),

            const SizedBox(height: 32),
            _disconnectButton(context),
            const SizedBox(height: 12),
            _hardwareId(),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── UI PARTS

  Widget _title() {
    return const Text(
      'System',
      style: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _profileCard(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        SessionManager.getUsername(),
        SessionManager.getLevel(),
      ]),
      builder: (context, snapshot) {
        final username = snapshot.hasData ? snapshot.data![0] as String? : null;
        final level = snapshot.hasData ? snapshot.data![1] as int? : null;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
            child: _glassContainer(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.black26,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (username ?? 'PLAYER').toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Level ${level ?? 1}',
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          letterSpacing: 1.6,
          fontSize: 12,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _glassTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _glassContainer(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Row(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 16),
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 16)),
              ),
              if (trailing != null) trailing,
              if (onTap != null && trailing == null)
                const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _purpleSwitch(bool value) {
    return Switch(
      value: value,
      activeColor: AppColors.primary,
      onChanged: (_) {},
    );
  }

  Widget _disconnectButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await SessionManager.logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/auth', (_) => false);
        }
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.red.withOpacity(0.35),
              Colors.red.withOpacity(0.15),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            'DISCONNECT',
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _hardwareId() {
    return const Center(
      child: Text(
        'HARDWARE ID · 88-AF-32-00-11',
        style: TextStyle(
          fontSize: 10,
          letterSpacing: 1.2,
          color: Colors.white30,
        ),
      ),
    );
  }
}
