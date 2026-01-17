import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/storage/session_manager.dart';
import '../../core/theme/app_colors.dart';

String rankFromLevel(int level) {
  if (level >= 50) return 'Grand Master';
  if (level >= 40) return 'Elite Runner';
  if (level >= 30) return 'Veteran';
  if (level >= 20) return 'Challenger';
  if (level >= 10) return 'Rookie';
  return 'Beginner';
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _header(context),
            const SizedBox(height: 24),
            _rankCard(),
            const SizedBox(height: 24),
            _statsRow(),
            const SizedBox(height: 32),
            _sectionTitle('RECENT ACHIEVEMENTS'),
            const SizedBox(height: 12),
            _achievement(
              icon: Icons.emoji_events,
              title: 'Grand Master',
              subtitle: 'Reach Level 50',
              progress: 0.84,
              color: AppColors.primary,
            ),
            _achievement(
              icon: Icons.flash_on,
              title: 'Speed Demon',
              subtitle: 'Complete a race under 2 mins',
              progress: 1.0,
              color: Colors.greenAccent,
            ),
            _achievement(
              icon: Icons.people_outline,
              title: 'Socialite',
              subtitle: 'Make 50 friends',
              progress: 0.6,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── HEADER

  Widget _header(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        const Text(
          'Player Profile',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ───────────────── RANK CARD

  Widget _rankCard() {
    return FutureBuilder(
      future: Future.wait([
        SessionManager.getUsername(),
        SessionManager.getLevel(),
      ]),
      builder: (context, snapshot) {
        final username = snapshot.hasData
            ? snapshot.data![0] as String?
            : 'PLAYER';
        final level = snapshot.hasData ? snapshot.data![1] as int? : 1;

        return _glass(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT RANK',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.4,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Elite\nRunner',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    username!.toUpperCase(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('LVL', style: TextStyle(color: Colors.white54)),
                  Text(
                    '$level',
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text('75%', style: TextStyle(color: Colors.white54)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ───────────────── STATS

  Widget _statsRow() {
    return Row(
      children: [
        Expanded(
          child: _stat('STREAK', '12 Days', Icons.local_fire_department),
        ),
        const SizedBox(width: 12),
        Expanded(child: _stat('PLAYTIME', '320h', Icons.calendar_today)),
      ],
    );
  }

  Widget _stat(String title, String value, IconData icon) {
    return _glass(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
        ],
      ),
    );
  }

  // ───────────────── ACHIEVEMENTS

  Widget _achievement({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _glass(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────── GLASS

  Widget _glass({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.45),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.6,
        color: Colors.white54,
      ),
    );
  }
}
