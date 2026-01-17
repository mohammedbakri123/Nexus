import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../../core/storage/app_database.dart';
import '../../shared/models/user_model.dart';

/// Authentication related exceptions
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class EmailAlreadyExistsException extends AuthException {
  EmailAlreadyExistsException() : super('Email already registered');
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Invalid email or password');
}

class AuthLocalService {
  /// SIGN UP
  static Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final db = await AppDatabase.database;

    try {
      final user = UserModel(
        username: username,
        email: email,
        password: password,
        level: Random().nextInt(100) + 1,
      );

      await db.insert('users', user.toMap());
      return true;
    } on DatabaseException catch (e) {
      final msg = e.toString();
      if (msg.contains('UNIQUE') || msg.contains('unique')) {
        // email already exists
        throw EmailAlreadyExistsException();
      }
      throw AuthException(msg);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// LOGIN
  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final row = result.first;
      return UserModel(
        userId: row['user_id'] as int,
        username: row['username'] as String,
        email: row['email'] as String,
        password: row['password'] as String,
        level: row['level'] as int,
      );
    }

    // no matching user
    throw InvalidCredentialsException();
  }

  /// UPDATE USER
  static Future<UserModel> updateUser({
    required int userId,
    String? username,
    String? email,
    String? password,
  }) async {
    final db = await AppDatabase.database;

    final updates = <String, Object?>{};
    if (username != null) updates['username'] = username;
    if (email != null) updates['email'] = email;
    if (password != null) updates['password'] = password;

    if (updates.isEmpty) {
      // nothing to update, return current user
      final result = await db.query(
        'users',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final row = result.first;
        return UserModel(
          userId: row['user_id'] as int,
          username: row['username'] as String,
          email: row['email'] as String,
          password: row['password'] as String,
          level: row['level'] as int,
        );
      }
      throw AuthException('User not found');
    }

    try {
      await db.update(
        'users',
        updates,
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      final result = await db.query(
        'users',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      if (result.isNotEmpty) {
        final row = result.first;
        return UserModel(
          userId: row['user_id'] as int,
          username: row['username'] as String,
          email: row['email'] as String,
          password: row['password'] as String,
          level: row['level'] as int,
        );
      }
      throw AuthException('Failed to load updated user');
    } on DatabaseException catch (e) {
      final msg = e.toString();
      if (msg.contains('UNIQUE') || msg.contains('unique')) {
        throw EmailAlreadyExistsException();
      }
      throw AuthException(msg);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  /// VERIFY PASSWORD (by user id)
  static Future<bool> verifyPassword({
    required int userId,
    required String password,
  }) async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'users',
      where: 'user_id = ? AND password = ?',
      whereArgs: [userId, password],
      limit: 1,
    );

    return result.isNotEmpty;
  }
}
