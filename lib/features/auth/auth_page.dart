import 'package:flutter/material.dart';
import 'auth_local_service.dart';
import '../../core/storage/session_manager.dart';

enum AuthMode { login, signup }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  AuthMode _mode = AuthMode.login;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  bool _isLoading = false;

  Color get accent => _mode == AuthMode.login
      ? const Color(0xFF9B5CFF) // purple
      : const Color(0xFF00E5FF); // cyan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _logo(),
                    const SizedBox(height: 24),
                    _title(),
                    const SizedBox(height: 32),
                    _modeToggle(),
                    const SizedBox(height: 24),
                    if (_mode == AuthMode.signup)
                      _input(
                        controller: _username,
                        hint: 'Username',
                        icon: Icons.person_outline,
                      ),
                    _input(
                      controller: _email,
                      hint: 'Email Address',
                      icon: Icons.email_outlined,
                    ),
                    _input(
                      controller: _password,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),
                    const SizedBox(height: 12),
                    if (_mode == AuthMode.login)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot Access Code?',
                          style: TextStyle(color: accent, fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _primaryButton(),
                    const SizedBox(height: 24),
                    _socialDivider(),
                    const SizedBox(height: 16),
                    _socialButtons(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────

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

  Widget _logo() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: accent.withOpacity(0.15),
        boxShadow: [BoxShadow(color: accent.withOpacity(0.5), blurRadius: 25)],
      ),
      child: Icon(Icons.gamepad, color: accent),
    );
  }

  Widget _title() {
    return Column(
      children: const [
        Text(
          'Identity Check',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Connect your neural link to proceed.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _modeToggle() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _modeButton('LOGIN', AuthMode.login),
          _modeButton('SIGN UP', AuthMode.signup),
        ],
      ),
    );
  }

  Widget _modeButton(String text, AuthMode mode) {
    final selected = _mode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: selected ? accent : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.white38),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _primaryButton() {
    return Container(
      height: 56,
      width: double.infinity,
      child: GestureDetector(
        onTap: _isLoading ? null : _onPrimaryPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: accent,
            boxShadow: [
              BoxShadow(color: accent.withOpacity(0.6), blurRadius: 30),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _mode == AuthMode.login ? 'CONNECT' : 'INITIATE',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.black,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPrimaryPressed() async {
    // basic validation
    if (_mode == AuthMode.signup) {
      if (_username.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a username')),
        );
        return;
      }
    }

    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_mode == AuthMode.login) {
        try {
          final user = await AuthLocalService.login(
            email: _email.text.trim(),
            password: _password.text,
          );

          // persist session
          await SessionManager.saveUser(
            userId: user.userId!,
            username: user.username,
            email: user.email,
            level: user.level,
          );

          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/home');
        } on InvalidCredentialsException catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
        } on AuthException catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
        }
      } else {
        try {
          final success = await AuthLocalService.register(
            username: _username.text.trim(),
            email: _email.text.trim(),
            password: _password.text,
          );

          if (success) {
            if (!mounted) return;
            setState(() => _mode = AuthMode.login);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful — please login'),
              ),
            );
          }
        } on EmailAlreadyExistsException catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
        } on AuthException catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _socialDivider() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(fontSize: 10, color: Colors.white38),
          ),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _socialButtons() {
    return Row(
      children: [
        _social('Google'),
        const SizedBox(width: 12),
        _social('Discord'),
      ],
    );
  }

  Widget _social(String text) {
    return Expanded(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Center(child: Text(text)),
      ),
    );
  }
}
