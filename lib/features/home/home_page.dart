import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nexus/core/storage/session_manager.dart';
import 'package:nexus/features/home/game_details_page.dart';
import 'package:nexus/features/notifications/notifications_page.dart';
import '../../shared/models/game_model.dart';
import 'rawg_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  GameModel? _featuredGame;
  final List<GameModel> _trendingGames = [];
  final List<GameModel> _searchResults = [];

  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _searchQuery = '';
  String _username = 'PLAYER';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
    _loadTrending();
    _loadUsername();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore &&
          _searchQuery.isEmpty) {
        _loadTrending();
      }
    });
  }

  // ───────────────────────── DATA LOADERS
  Future<void> _loadUsername() async {
    final name = await SessionManager.getUsername();
    if (name != null && mounted) {
      setState(() {
        _username = name;
      });
    }
  }

  Future<void> _loadFeatured() async {
    final games = await RawgService.fetchGames(page: 1, ordering: '-rating');

    if (games.isNotEmpty) {
      setState(() => _featuredGame = games.first);
    }
  }

  Future<void> _loadTrending() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;

    try {
      final games = await RawgService.fetchGames(
        page: _page,
        ordering: '-added',
      );

      if (!mounted) return;

      setState(() {
        _trendingGames.addAll(games);
        _page++;
        _hasMore = games.isNotEmpty;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasMore = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchGames(String query) async {
    // Cancel previous debounce timer
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchQuery = '';
        _searchResults.clear();
      });
      return;
    }

    // Debounce search to avoid too many API calls
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _searchQuery = query;
        _searchResults.clear();
      });

      final results = await RawgService.fetchGames(page: 1, search: query);

      if (mounted) {
        setState(() => _searchResults.addAll(results));
      }
    });
  }

  // ───────────────────────── UI

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: _scrollController,
            children: [
              _header(),
              const SizedBox(height: 16),
              _searchBar(),
              const SizedBox(height: 24),

              if (!isSearching && _featuredGame != null) ...[
                _sectionTitle('Featured'),
                const SizedBox(height: 12),
                _featuredCard(_featuredGame!),
                const SizedBox(height: 24),
              ],

              _sectionTitle(isSearching ? 'Search Results' : 'Trending Now'),
              const SizedBox(height: 12),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _trendingGrid(
                  isSearching ? _searchResults : _trendingGames,
                  key: ValueKey(isSearching),
                ),
              ),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (!_hasMore && !isSearching)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No more games',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── UI PARTS

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back,',
              style: TextStyle(color: Colors.white54),
            ),
            Text(
              _username,
              style: const TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (_, __, ___) => NotificationsPage(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.05),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
              ),
            );
          },
          child: const Icon(Icons.notifications_none),
        ),
      ],
    );
  }

  Widget _searchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _searchGames,
      onSubmitted: (value) {
        _searchDebounce?.cancel();
        _searchGames(value);
      },
      decoration: InputDecoration(
        hintText: 'Search database...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  _searchDebounce?.cancel();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          color: const Color(0xFF9B5CFF),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontFamily: 'Orbitron', fontSize: 18),
        ),
      ],
    );
  }

  Widget _featuredCard(GameModel game) {
    return RepaintBoundary(
      child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (_, __, ___) => GameDetailsPage(gameId: game.id),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        child: Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: CachedNetworkImageProvider(game.image),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.85), Colors.transparent],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    game.name,
                    style: const TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(game.rating.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _trendingGrid(List<GameModel> games, {Key? key}) {
    return GridView.builder(
      key: key,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: games.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final game = games[index];

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 300),
                  pageBuilder: (_, __, ___) => GameDetailsPage(gameId: game.id),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                ),
              );
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
                          child: const Icon(Icons.error_outline, color: Colors.white54),
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

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
