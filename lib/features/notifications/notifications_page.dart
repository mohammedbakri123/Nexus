import 'dart:ui';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _selectedTab = 0;

  final tabs = ['ALL', 'ALERTS', 'MESSAGES', 'ACHIEVEMENTS'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topBar(context),
              const SizedBox(height: 20),
              _tabs(),
              const SizedBox(height: 24),
              Expanded(child: _notificationList()),
              _markAllRead(),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── UI

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        _circleButton(Icons.arrow_back, () {
          Navigator.pop(context);
        }),
        const SizedBox(width: 12),
        const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _tabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = _selectedTab == index;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),

                // kill all material effects
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,

                onTap: () {
                  setState(() => _selectedTab = index);
                },

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: selected
                        ? const Color(0xFF9B5CFF)
                        : Colors.white.withOpacity(0.05),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF9B5CFF).withOpacity(0.6)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.black : Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _notificationList() {
    return ListView(
      children: const [
        _NotificationCard(
          icon: Icons.flash_on,
          iconColor: Color(0xFF9B5CFF),
          title: 'System Update',
          message: 'New performance patches are available for download.',
          time: '2m ago',
          highlight: true,
        ),
        _NotificationCard(
          icon: Icons.emoji_events,
          iconColor: Color(0xFFFFC107),
          title: 'Achievement Unlocked!',
          message: "You've earned 'The Speedster' badge in Cyber Odyssey.",
          time: '1h ago',
        ),
        _NotificationCard(
          icon: Icons.chat_bubble_outline,
          iconColor: Color(0xFF00E5FF),
          title: 'Runner_X99',
          message: 'Hey! Ready for the tournament tonight?',
          time: '3h ago',
        ),
        _NotificationCard(
          icon: Icons.notifications_none,
          iconColor: Color(0xFF9B5CFF),
          title: 'Price Drop',
          message: 'Apex Racing is now 20% off on your wishlist.',
          time: '5h ago',
        ),
      ],
    );
  }

  Widget _markAllRead() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'MARK ALL AS READ',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.4,
            color: Colors.white.withOpacity(0.35),
          ),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

// ───────────────────────── CARD

class _NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;
  final bool highlight;

  const _NotificationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.45),
              border: Border.all(
                color: highlight
                    ? const Color(0xFF9B5CFF)
                    : Colors.white.withOpacity(0.08),
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withOpacity(0.15),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
