import 'package:flutter/material.dart';
import 'package:game_catalog/utils/colorsbar.dart';
import '../services/api_jogos.dart';

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> game;

  const DetailsPage({super.key, required this.game});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Map<String, dynamic>? gameDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGameDetails();
  }

  Future<void> _fetchGameDetails() async {
    final details = await GameApiService.getGameDetails(widget.game['id']);
    setState(() {
      gameDetails = details;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.game['name'],
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: ColorsbBars.fromGenre(
          (gameDetails?['genres']?.isNotEmpty ?? false)
              ? gameDetails!['genres'][0]['name']
              : '',
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : gameDetails == null
              ? const Center(child: Text('Erro ao carregar detalhes do jogo'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 600;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildImage(isSmallScreen),
                              const SizedBox(height: 16),
                              _buildDescription(isSmallScreen),
                              const SizedBox(height: 20),
                              _buildPlatformList(theme),
                              const SizedBox(height: 16),
                              _buildGenreList(theme),
                              const SizedBox(height: 20),
                              _buildAchievements(theme, isSmallScreen),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildImage(bool isSmallScreen) {
    final imageUrl = gameDetails!['background_image'];
    return imageUrl != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: isSmallScreen ? 180 : 300,
              fit: BoxFit.cover,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildDescription(bool isSmallScreen) {
    return Text(
      gameDetails!['description_raw'] ?? 'Sem descrição disponível.',
      style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
    );
  }

  Widget _buildPlatformList(ThemeData theme) {
    final platforms = gameDetails!['platforms'] as List?;
    if (platforms == null || platforms.isEmpty) return const SizedBox.shrink();

    final platformNames =
        platforms.map((p) => p['platform']['name'] as String).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plataformas:', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(platformNames, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildGenreList(ThemeData theme) {
    final genres = gameDetails!['genres'] as List?;
    if (genres == null || genres.isEmpty) return const SizedBox.shrink();

    final genreNames = genres.map((g) => g['name'] as String).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gêneros:', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(genreNames, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildAchievements(ThemeData theme, bool isSmallScreen) {
    final achievements = gameDetails!['achievements'] as List?;
    if (achievements == null || achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Conquistas:', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...achievements.take(5).map<Widget>((ach) {
          return ListTile(
            leading: ach['image'] != null
                ? Image.network(ach['image'], width: 40, height: 40)
                : const Icon(Icons.emoji_events),
            title: Text(
              ach['name'],
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
            subtitle: Text(
              ach['description'] ?? '',
              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            ),
          );
        }),
      ],
    );
  }
}
