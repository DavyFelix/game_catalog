import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final Map<String, dynamic> game;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String lastModified;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.lastModified,
  });

  String _formatLocation(Map<String, dynamic> game) {
    if (game['place_name'] != null && game['place_name'].toString().isNotEmpty) {
      final place = game['place_name'].toString();
      return place.length > 50 ? '${place.substring(0, 47)}...' : place;
    } else if (game['latitude'] != null && game['longitude'] != null) {
      final lat = game['latitude'].toStringAsFixed(4);
      final lon = game['longitude'].toStringAsFixed(4);
      return '($lat, $lon)';
    } else {
      return 'Localização não informada';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rating = game['rating']?.toString() ?? 'N/A';
    final progress = game['progress']?.toString() ?? '0';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo(context, rating, progress)),
              _buildMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        game['background_image'] ?? '',
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.videogame_asset, size: 40),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, String rating, String progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          game['name'] ?? 'Nome não informado',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          'Nota: $rating | Progresso: $progress%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Última modificação: $lastModified',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 4),
        Text(
          _formatLocation(game),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'edit', child: Text('Editar Progresso')),
        PopupMenuItem(value: 'delete', child: Text('Excluir')),
      ],
    );
  }
}
