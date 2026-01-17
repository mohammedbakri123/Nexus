import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/storage/session_manager.dart';
import '../../shared/models/game_model.dart';
import '../home/game_details_page.dart';
import '../home/rawg_service.dart';
import 'favorites_local_service.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isLoading = true;
  List<GameModel> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites({bool refresh = false}) async {
    if (!refresh) {
      setState(() => _isLoading = true);
    }

    final userId = await SessionManager.getUserId();
    if (userId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    final ids = await FavoritesLocalService.getFavorites(userId);

    if (ids.isEmpty) {
      if (mounted) {
        setState(() {
          _favorites = [];
          _isLoading = false;
        });
      }
      return;
    }

    // Load all games in parallel instead of sequentially
    final futures = ids.map((id) => RawgService.fetchGameDetails(id));

    try {
      final results = await Future.wait(futures, eagerError: false);

      if (mounted) {
        // Filter out any null results from failed requests
        final games = results.whereType<GameModel>().toList();
        setState(() {
          _favorites = games;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Collection',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadFavorites(refresh: true),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _favorites.isEmpty
                      ? const SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 400,
                            child: Center(
                              child: Text(
                                'No favorites yet',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ),
                        )
                      : _favoritesGrid(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── UI

  Widget _favoritesGrid() {
    return GridView.builder(
      itemCount: _favorites.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final game = _favorites[index];

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameDetailsPage(gameId: game.id),
                ),
              );
              // Only refresh if returning from details page (avoid unnecessary reload)
              if (mounted) {
                _loadFavorites(refresh: true);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: game.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: Colors.white.withOpacity(0.05),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.white.withOpacity(0.05),
                          child: const Icon(
                            Icons.error_outline,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(game.rating.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
