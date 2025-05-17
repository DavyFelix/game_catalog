import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/card_jogos.dart';
import '../components/drawermenu.dart';
import 'add_games.dart';
import 'details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _myGames = [];

  // Adiciona novo jogo
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

  // Atualiza progresso de um jogo existente
  void _updateGame(int index, double progress) {
    setState(() {
      _myGames[index]['progress'] = progress;
      _myGames[index]['lastModified'] = DateTime.now().toIso8601String();
    });
  }

  // Remove jogo com confirmação
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

  // Formata data para exibição
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return 'Data inválida';
    }
  }

  // Abre a tela de adicionar jogo
  void _openAddGamePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddGamePage(onAdd: addGame),
      ),
    );
  }

  // Diálogo para atualizar o progresso
  void _showUpdateProgressDialog(int index) {
    double tempProgress = _myGames[index]['progress'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Atualizar Progresso'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Progresso Atual: ${tempProgress.toStringAsFixed(1)}%'),
              Slider(
                value: tempProgress,
                min: 0,
                max: 100,
                divisions: 100,
                label: '${tempProgress.toStringAsFixed(1)}%',
                onChanged: (value) => setStateDialog(() => tempProgress = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _updateGame(index, tempProgress);
              Navigator.pop(context);
            },
            child: const Text('Atualizar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        title: const Text('Catálogo de Jogos', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: Stack(
  children: [
    // Fundo com imagem
    Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/fundo.jpg'), // Caminho da imagem
          fit: BoxFit.cover,
        ),
      ),
    ),

    // Conteúdo principal com padding e cor de fundo com opacidade
    Container(
      // ignore: deprecated_member_use
      color: Colors.white.withOpacity(0.95),
      padding: const EdgeInsets.all(16),
      child: _myGames.isEmpty
          ? const Center(
              child: Text(
                'Nenhum jogo adicionado ainda.\nClique no botão "+" para começar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.black54),
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
                  onEdit: () => _showUpdateProgressDialog(index),
                  onDelete: () => _deleteGame(index),
                );
              },
            ),
    ),
  ],
),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddGamePage,
        child: const Icon(Icons.add),
      ),
    );
  }
}
