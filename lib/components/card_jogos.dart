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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            game['background_image'] ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.videogame_asset, size: 40),
          ),
        ),
        title: Text(
          game['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Nota: ${game['rating']} | Progresso: ${game['progress']}%\n'
          'Última Modificação: $lastModified\n'
          '${_formatLocation(game)}',
          style: const TextStyle(height: 1.4),
        ),
        trailing: PopupMenuButton<String>(
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
        ),
        onTap: onTap,
      ),
    );
  }
}
