import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/storage/app_database.dart';

class FavoritesLocalService {
  /// CHECK if game is favorite
  static Future<bool> isFavorite({
    required int userId,
    required int gameId,
  }) async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'favorites',
      where: 'user_id = ? AND game_id = ?',
      whereArgs: [userId, gameId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  /// ADD favorite
  static Future<void> addFavorite({
    required int userId,
    required int gameId,
  }) async {
    final db = await AppDatabase.database;

    await db.insert('favorites', {
      'user_id': userId,
      'game_id': gameId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// REMOVE favorite
  static Future<void> removeFavorite({
    required int userId,
    required int gameId,
  }) async {
    final db = await AppDatabase.database;

    await db.delete(
      'favorites',
      where: 'user_id = ? AND game_id = ?',
      whereArgs: [userId, gameId],
    );
  }

  /// GET ALL FAVORITES (IDs only)
  static Future<List<int>> getFavorites(int userId) async {
    final db = await AppDatabase.database;

    final result = await db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.map((e) => e['game_id'] as int).toList();
  }
}
