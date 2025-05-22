import 'package:flutter/material.dart';
import 'package:game_catalog/routers/routers.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../components/card_jogos.dart';
import '../components/drawermenu.dart';
import 'details.dart';
import '../pages/upd_games.dart';
import '../providers/gameprovider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return 'Data inválida';
    }
  }

void _openAddGamePage(BuildContext context) {
  Navigator.pushNamed(context, Routes.ADDJOGO);
}

  void _showUpdateProgressPage(BuildContext context, int index, Map<String, dynamic> game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UpdateProgressPage(gameIndex: index),
      ),
    );
  }

  void _deleteGame(BuildContext context, int index) {
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
              Provider.of<GameProvider>(context, listen: false).deleteGame(index);
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final games = context.watch<GameProvider>().games;

    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        title: const Text('Catálogo de Jogos', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/fundo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Colors.white.withOpacity(0.95),
              padding: const EdgeInsets.all(16),
              child: games.isEmpty
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
                      itemCount: games.length,
                      itemBuilder: (_, index) {
                        final game = games[index];
                        return GameCard(
                          game: game,
                          lastModified: _formatDate(game['lastModified']),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailsPage(game: game),
                            ),
                          ),
                          onEdit: () => _showUpdateProgressPage(context, index, game),
                          onDelete: () => _deleteGame(context, index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: isSmallScreen
          ? FloatingActionButton.small(
              onPressed: () => _openAddGamePage(context),
              child: const Icon(Icons.add),
            )
          : FloatingActionButton(
              onPressed: () => _openAddGamePage(context),
              child: const Icon(Icons.add),
            ),
    );
  }
}
