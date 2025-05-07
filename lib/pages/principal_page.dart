import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/card_jogos.dart';
import '../services/api_jogos.dart';
import 'add_games.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> myGames = [];

  void addGame(Map<String, dynamic> game, double progress) {
    setState(() {
      myGames.add({
        ...game,
        'progress': progress,
        'lastModified': DateTime.now().toIso8601String(),
      });
    });
  }

  void updateGame(int index, double newProgress) {
    setState(() {
      myGames[index]['progress'] = newProgress;
      myGames[index]['lastModified'] = DateTime.now().toIso8601String();
    });
  }

  void deleteGame(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja excluir este jogo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              setState(() {
                myGames.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

 void openAddGamePage() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => AddGamePage(onAdd: addGame),
    ),
  );
}

  void openUpdateProgressDialog(int index) {
    double progress = myGames[index]['progress'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualizar Progresso'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Progresso Atual: ${progress.toStringAsFixed(1)}%'),
              Slider(
                value: progress,
                min: 0.0,
                max: 100.0,
                divisions: 100,
                label: '${progress.toStringAsFixed(1)}%',
                onChanged: (value) => setStateDialog(() => progress = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              updateGame(index, progress);
              Navigator.pop(context);
            },
            child: const Text('Atualizar'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ],
      ),
    );
  }

  void showGameDetails(Map<String, dynamic> game) async {
    final details = await GameApiService.getGameDetails(game['id']);
    if (details != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(game['name']),
          content: Text(details['description_raw'] ?? 'Sem descrição disponível.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          ],
        ),
      );
    }
  }

  String formatDate(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (_) {
      return 'Data inválida';
    }
  }

  @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catálogo de Jogos',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: Stack(
        children: [
          // Conteúdo sobreposto à imagem
          Padding(
            padding: const EdgeInsets.all(16),
            child: myGames.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum jogo adicionado ainda.\nClique no botão "+" para começar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    itemCount: myGames.length,
                    itemBuilder: (_, index) => GameCard(
                      game: myGames[index],
                      onTap: () => showGameDetails(myGames[index]),
                      onEdit: () => openUpdateProgressDialog(index),
                      onDelete: () => deleteGame(index),
                      lastModified: formatDate(myGames[index]['lastModified']),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddGamePage,
        child: const Icon(Icons.add),
      ),
    );
    }
}
