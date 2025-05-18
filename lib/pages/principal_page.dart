import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/card_jogos.dart';
import '../components/drawermenu.dart';
import 'add_games.dart';
import 'details.dart';
import '../pages/upd_games.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _myGames = [];

  void addGame(Map<String, dynamic> game, double progress, double? lat, double? lng) {
    setState(() {
      _myGames.add({
        ...game,
        'progress': progress,
        'latitude': lat,
        'longitude': lng,
        'lastModified': DateTime.now().toIso8601String(),
      });
    });
  }

  void _updateGame(int index, double progress, double? lat, double? lng, String? placeName) {
    setState(() {
      _myGames[index]['progress'] = progress;
      _myGames[index]['latitude'] = lat;
      _myGames[index]['longitude'] = lng;
      _myGames[index]['place_name'] = placeName;
      _myGames[index]['lastModified'] = DateTime.now().toIso8601String();
    });
  }

  void _deleteGame(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja excluir este jogo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _myGames.removeAt(index));
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return 'Data inválida';
    }
  }

  void _openAddGamePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddGamePage(onAdd: addGame),
      ),
    );
  }

  void _showUpdateProgressPage(int index) {
    final game = _myGames[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateProgressPage(
          initialProgress: game['progress'],
          initialLat: game['latitude'],
          initialLon: game['longitude'],
          onUpdate: (updatedProgress, lat, lon, placeName) {
            _updateGame(index, updatedProgress, lat, lon, placeName);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        title: const Text(
          'Catálogo de Jogos',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Fundo com imagem
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fundo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Conteúdo principal adaptado
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  color: Colors.white.withOpacity(0.95),
                  padding: const EdgeInsets.all(16),
                  child: _myGames.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhum jogo adicionado ainda.\nClique no botão "+" para começar!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _myGames.length,
                          itemBuilder: (_, index) {
                            final game = _myGames[index];
                            return GameCard(
                              game: game,
                              lastModified: _formatDate(game['lastModified']),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailsPage(game: game),
                                ),
                              ),
                              onEdit: () => _showUpdateProgressPage(index),
                              onDelete: () => _deleteGame(index),
                            );
                          },
                        ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: isSmallScreen
          ? FloatingActionButton.small(
              onPressed: _openAddGamePage,
              child: const Icon(Icons.add),
            )
          : FloatingActionButton(
              onPressed: _openAddGamePage,
              child: const Icon(Icons.add),
            ),
    );
  }
}
