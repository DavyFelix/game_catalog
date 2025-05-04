import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/card_jogos.dart';
import '../services/api_jogos.dart';

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

  void openAddGameDialog() {
    final nameController = TextEditingController();
    double progress = 0.0;
    List<Map<String, dynamic>> searchResults = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          Future<void> search(String name) async {
            if (name.isEmpty) {
              setStateDialog(() {
                searchResults = [];
              });
              return;
            }

            final response = await GameApiService.searchGame(name);
            if (response != null) {
              setStateDialog(() => searchResults = [response]);
            }
          }

          return AlertDialog(
            title: const Text('Adicionar Novo Jogo'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome do Jogo'),
                      onChanged: search,
                    ),
                    const SizedBox(height: 12),
                    if (searchResults.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (_, index) {
                            final game = searchResults[index];
                            return ListTile(
                              leading: game['background_image'] != null
                                  ? Image.network(
                                      game['background_image'],
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.videogame_asset),
                              title: Text(game['name']),
                              onTap: () {
                                nameController.text = game['name'];
                                setStateDialog(() => searchResults = []);
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text('Progresso: ${progress.toStringAsFixed(1)}%'),
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
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final name = nameController.text;
                  if (name.isEmpty || progress == 0.0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor, insira todos os dados')),
                    );
                    return;
                  }

                  final game = await GameApiService.searchGame(name);
                  if (game != null) {
                    addGame(game, progress);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Jogo não encontrado')),
                    );
                  }
                },
                child: const Text('Adicionar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
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
          // Imagem de fundo
          Positioned.fill(
            child: Image.asset(
                'assets/background.png',
              fit: BoxFit.cover,
            ),
          ),

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
        onPressed: openAddGameDialog,
        child: const Icon(Icons.add),
      ),
    );
    }
}
