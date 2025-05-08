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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.game['name'],
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImage(),
                        const SizedBox(height: 16),
                        _buildDescription(),
                        const SizedBox(height: 20),
                        _buildPlatformList(theme),
                        const SizedBox(height: 16),
                        _buildGenreList(theme),
                        const SizedBox(height: 20),
                        _buildAchievements(theme),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildImage() {
    final imageUrl = gameDetails!['background_image'];
    return imageUrl != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(imageUrl),
          )
        : const SizedBox.shrink();
  }

  Widget _buildDescription() {
    return Text(
      gameDetails!['description_raw'] ?? 'Sem descrição disponível.',
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildPlatformList(ThemeData theme) {
    final platforms = gameDetails!['platforms'] as List?;
    if (platforms == null || platforms.isEmpty) return const SizedBox.shrink();

    final platformNames = platforms
        .map((p) => p['platform']['name'] as String)
        .join(', ');

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

    final genreNames = genres
        .map((g) => g['name'] as String)
        .join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gêneros:', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(genreNames, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildAchievements(ThemeData theme) {
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
            title: Text(ach['name']),
            subtitle: Text(ach['description'] ?? ''),
          );
        }).toList(),
      ],
    );
  }
}
