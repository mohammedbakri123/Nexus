import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:nexus/features/profile/profile_page.dart';
import '../../core/storage/session_manager.dart';
import '../auth/auth_local_service.dart';
import '../../core/theme/app_colors.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final username = await SessionManager.getUsername();
    final bio = await SessionManager.getBio();

    final email = await SessionManager.getEmail();

    _usernameController.text = username ?? 'PLAYER';
    _bioController.text = bio ?? '';
    _emailController.text = email ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _header(context),
            const SizedBox(height: 24),
            _avatar(),
            const SizedBox(height: 24),
            _input(label: 'USERNAME', controller: _usernameController),
            const SizedBox(height: 16),
            _input(label: 'EMAIL', controller: _emailController),
            const SizedBox(height: 16),
            _input(
              label: 'CURRENT PASSWORD',
              controller: _currentPasswordController,
            ),
            const SizedBox(height: 12),
            _input(label: 'NEW PASSWORD', controller: _passwordController),
            const SizedBox(height: 12),
            _input(label: 'CONFIRM PASSWORD', controller: _confirmController),
            const SizedBox(height: 16),
            _input(label: 'BIO', controller: _bioController, maxLines: 3),
            const SizedBox(height: 24),
            _realStats(),
            const SizedBox(height: 32),
            _saveButton(),
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
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ───────────────── AVATAR

  Widget _avatar() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: Colors.black26,
            child: Icon(Icons.person, size: 48),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(Icons.edit, size: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  // ───────────────── INPUT FIELD

  Widget _input({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return _glass(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.4,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── READONLY STAT

  Widget _readonlyStat(String label, String value) {
    return _glass(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              letterSpacing: 1.4,
              color: Colors.white54,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _realStats() {
    return FutureBuilder<int?>(
      future: SessionManager.getLevel(),
      builder: (context, snapshot) {
        final level = snapshot.data ?? 1;
        final rank = rankFromLevel(level);

        return Column(
          children: [
            _readonlyStat('RANK', rank),
            const SizedBox(height: 12),
            _readonlyStat('LEVEL', level.toString()),
          ],
        );
      },
    );
  }

  // ───────────────── SAVE BUTTON

  Widget _saveButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _onSave,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.primary.withOpacity(0.4),
            ],
          ),
        ),
        child: const Center(
          child: Text(
            'SAVE CHANGES',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.4),
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    // basic validation
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email cannot be empty')));
      return;
    }
    if (password.isNotEmpty && password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }
    if (password.isNotEmpty && password != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userId = await SessionManager.getUserId();
      if (!mounted) return;
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No user session')));
        return;
      }

      // If user is changing email or password, verify current password first
      final currentEmail = await SessionManager.getEmail() ?? '';
      final emailChanged = email != currentEmail;
      final passwordChanging = password.isNotEmpty;

      if (emailChanged || passwordChanging) {
        final current = _currentPasswordController.text;
        if (current.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Current password is required to change email or password',
              ),
            ),
          );
          return;
        }

        final ok = await AuthLocalService.verifyPassword(
          userId: userId,
          password: current,
        );

        if (!ok) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Current password is incorrect')),
          );
          return;
        }
      }

      final updated = await AuthLocalService.updateUser(
        userId: userId,
        username: _usernameController.text.trim(),
        email: email,
        password: password.isEmpty ? null : password,
      );

      // update session
      await SessionManager.saveUser(
        userId: updated.userId!,
        username: updated.username,
        email: updated.email,
        level: updated.level,
      );

      await SessionManager.setBio(_bioController.text);

      if (!mounted) return;
      // clear sensitive fields
      _passwordController.clear();
      _confirmController.clear();
      _currentPasswordController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.pop(context);
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
}
