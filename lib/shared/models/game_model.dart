class GameModel {
  final int id;
  final String name;
  final String image;
  final double rating;
  final List<String> genres;
  final String description;

  GameModel({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.genres,
    required this.description,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['background_image'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      genres: (json['genres'] as List? ?? [])
          .map((g) => g['name'].toString())
          .toList(),
      description: json['description_raw'] ?? '',
    );
  }
}
