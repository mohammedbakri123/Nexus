import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../shared/models/game_model.dart';
import 'rawg_service.dart';
import '../../features/favorites/favorites_local_service.dart';
import '../../core/storage/session_manager.dart';

class GameDetailsPage extends StatefulWidget {
  final int gameId;

  const GameDetailsPage({super.key, required this.gameId});

  @override
  State<GameDetailsPage> createState() => _GameDetailsPageState();
}

class _GameDetailsPageState extends State<GameDetailsPage> {
  late Future<GameModel> _game;
  bool _isFavorite = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _game = RawgService.fetchGameDetails(widget.gameId);
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return;

    final fav = await FavoritesLocalService.isFavorite(
      userId: userId,
      gameId: widget.gameId,
    );

    if (mounted) {
      setState(() {
        _userId = userId;
        _isFavorite = fav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null) return;

    setState(() {
      _isFavorite = !_isFavorite; // optimistic UI
    });

    if (_isFavorite) {
      await FavoritesLocalService.addFavorite(
        userId: _userId!,
        gameId: widget.gameId,
      );
    } else {
      await FavoritesLocalService.removeFavorite(
        userId: _userId!,
        gameId: widget.gameId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<GameModel>(
        future: _game,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Stack(
              children: [
                const Center(
                  child: Text(
                    'Failed to load game',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                _topBar(showActions: false),
              ],
            );
          }

          final game = snapshot.data!;
          return Stack(
            children: [
              _heroImage(game.image),
              _content(game),
              _topBar(showActions: true),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────── UI

  Widget _heroImage(String image) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: image,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.black87,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.black87,
          child: const Icon(Icons.error_outline, color: Colors.white54),
        ),
      ),
    );
  }

  Widget _topBar({bool showActions = false}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circleButton(Icons.arrow_back, () {
              Navigator.pop(context);
            }),
            if (showActions)
              Row(
                children: [
                  _circleButton(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    _toggleFavorite,
                  ),

                  const SizedBox(width: 8),
                  _circleButton(Icons.share, () {}),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _content(GameModel game) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.65,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF0A0A0F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: controller,
            children: [
              _title(game),
              const SizedBox(height: 16),
              _genres(game.genres),
              const SizedBox(height: 16),
              _stats(game),
              const SizedBox(height: 24),
              _sectionTitle('About'),
              const SizedBox(height: 8),
              Text(
                game.description,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
              if (game.pcRequirements != null &&
                  game.pcRequirements!.hasRequirements) ...[
                const SizedBox(height: 24),
                _sectionTitle('System Requirements'),
                const SizedBox(height: 12),
                _requirementsSection(game.pcRequirements!),
              ],
              const SizedBox(height: 120),
            ],
          ),
        );
      },
    );
  }

  Widget _title(GameModel game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            game.name,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(game.rating.toString()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _genres(List<String> genres) {
    return Wrap(
      spacing: 8,
      children: genres
          .map(
            (g) => Chip(
              label: Text(g),
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          )
          .toList(),
    );
  }

  Widget _stats(GameModel game) {
    // Format release date
    final releaseDate = game.released ?? 'TBA';

    // Format ratings count
    String ratingsText = 'N/A';
    if (game.ratingsCount != null && game.ratingsCount! > 0) {
      if (game.ratingsCount! >= 1000000) {
        ratingsText = '${(game.ratingsCount! / 1000000).toStringAsFixed(1)}M+';
      } else if (game.ratingsCount! >= 1000) {
        ratingsText = '${(game.ratingsCount! / 1000).toStringAsFixed(1)}K+';
      } else {
        ratingsText = '${game.ratingsCount}+';
      }
    }

    // Format playtime or use metacritic if available
    String playtimeText = 'N/A';
    if (game.playtime != null && game.playtime! > 0) {
      playtimeText = '${game.playtime}h';
    } else if (game.metacritic != null) {
      playtimeText = '${game.metacritic}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatItem(label: 'RELEASED', value: releaseDate),
        _StatItem(label: 'RATINGS', value: ratingsText),
        _StatItem(
          label: game.metacritic != null ? 'METACRITIC' : 'PLAYTIME',
          value: playtimeText,
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: const Color(0xFF9B5CFF)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontFamily: 'Orbitron', fontSize: 18),
        ),
      ],
    );
  }

  Widget _requirementsSection(GameRequirements requirements) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (requirements.minimum != null) ...[
            _requirementItem('Minimum', requirements.minimum!),
            if (requirements.recommended != null) const SizedBox(height: 16),
          ],
          if (requirements.recommended != null)
            _requirementItem('Recommended', requirements.recommended!),
        ],
      ),
    );
  }

  Widget _requirementItem(String label, String requirements) {
    // Clean up HTML tags and format text
    final cleanText = requirements
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF9B5CFF),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          cleanText,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── HELPERS

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
