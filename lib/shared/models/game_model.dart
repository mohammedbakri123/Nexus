class GameRequirements {
  final String? minimum;
  final String? recommended;

  GameRequirements({this.minimum, this.recommended});

  bool get hasRequirements => minimum != null || recommended != null;

  factory GameRequirements.fromJson(Map<String, dynamic>? json) {
    if (json == null) return GameRequirements();

    return GameRequirements(
      minimum: json['minimum'] as String?,
      recommended: json['recommended'] as String?,
    );
  }
}

class GameModel {
  final int id;
  final String name;
  final String image;
  final double rating;
  final List<String> genres;
  final String description;
  final String? released;
  final int? ratingsCount;
  final int? playtime;
  final int? metacritic;
  final GameRequirements? pcRequirements;

  GameModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.genres,
    required this.description,
    this.released,
    this.ratingsCount,
    this.playtime,
    this.metacritic,
    this.pcRequirements,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    // Parse release date
    String? releasedDate;
    if (json['released'] != null) {
      try {
        final date = DateTime.parse(json['released']);
        releasedDate = '${date.year}';
      } catch (_) {
        releasedDate = json['released']?.toString();
      }
    }

    // Parse ratings count
    int? ratingsCount;
    if (json['ratings_count'] != null) {
      ratingsCount = json['ratings_count'] as int;
    }

    // Parse playtime
    int? playtime;
    if (json['playtime'] != null) {
      playtime = json['playtime'] as int;
    }

    // Parse metacritic score
    int? metacritic;
    if (json['metacritic'] != null) {
      metacritic = json['metacritic'] as int;
    }

    // Parse PC requirements from platforms array
    GameRequirements? pcRequirements;
    if (json['platforms'] != null) {
      try {
        final platforms = json['platforms'] as List;
        final pcPlatform = platforms.firstWhere(
          (p) =>
              p['platform']?['name'] == 'PC' || p['platform']?['slug'] == 'pc',
          orElse: () => null,
        );

        if (pcPlatform != null) {
          // Try requirements_en first, then requirements
          final requirementsJson =
              pcPlatform['requirements_en'] ??
              pcPlatform['requirements'] ??
              pcPlatform['requirements_minimum'];
          pcRequirements = GameRequirements.fromJson(requirementsJson);
        }
      } catch (_) {
        // If parsing fails, requirements will remain null
      }
    }

    return GameModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['background_image'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      genres: (json['genres'] as List? ?? [])
          .map((g) => g['name'].toString())
          .toList(),
      description: json['description_raw'] ?? '',
      released: releasedDate,
      ratingsCount: ratingsCount,
      playtime: playtime,
      metacritic: metacritic,
      pcRequirements: pcRequirements,
    );
  }
}
