import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/storage/session_manager.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  Timer? _timer;
  double _progress = 0;

  static const Color accent = Color(0xFF9B5CFF); // same as LOGIN

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _boot();
  }

  void _boot() {
    _timer = Timer.periodic(const Duration(milliseconds: 40), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        _progress += 0.02;
        if (_progress >= 1) {
          t.cancel();
          // Automatically navigate after a short delay for smooth transition
          Timer(const Duration(milliseconds: 300), () {
            if (mounted) {
              _goNext();
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => Transform.scale(
                scale: _scale.value,
                child: Opacity(opacity: _fade.value, child: _content()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────

  Widget _background() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A0F), Color(0xFF12121F)],
        ),
      ),
    );
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _logo(),
          const SizedBox(height: 24),
          _title(),
          const SizedBox(height: 64),
          _loader(),
          const SizedBox(height: 40),
          _version(),
        ],
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: accent.withOpacity(0.15),
        boxShadow: [BoxShadow(color: accent.withOpacity(0.6), blurRadius: 30)],
      ),
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/icons/app_icon.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _title() {
    return Column(
      children: const [
        Text(
          'NEXUS',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 34,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Initializing neural interface…',
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _loader() {
    return Column(
      children: [
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 3,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(accent),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'BOOTING SYSTEM',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  void _goNext() async {
    final loggedIn = await SessionManager.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  Widget _version() {
    return const Text(
      'v2.0.77 // REPLIT BUILD',
      style: TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1.2),
    );
  }
}
