import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../shared/models/game_model.dart';

class RawgService {
  static Future<List<GameModel>> fetchGames({
    required int page,
    String? search,
    String? ordering,
  }) async {
    final query = {
      'key': ApiConstants.rawgApiKey,
      'page': page.toString(),
      'page_size': '20',
      if (search != null && search.isNotEmpty) 'search': search,
      if (ordering != null) 'ordering': ordering,
    };

    final uri = Uri.parse(
      '${ApiConstants.rawgBaseUrl}/games',
    ).replace(queryParameters: query);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load games');
    }

    final data = json.decode(response.body);
    final List results = data['results'];

    return results.map((e) => GameModel.fromJson(e)).toList();
  }

  static Future<GameModel> fetchGameDetails(int gameId) async {
    final uri = Uri.parse(
      '${ApiConstants.rawgBaseUrl}/games/$gameId?key=${ApiConstants.rawgApiKey}',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load game details');
    }

    final data = json.decode(response.body);
    return GameModel.fromJson(data);
  }
}
