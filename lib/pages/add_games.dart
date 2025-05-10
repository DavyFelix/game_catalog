import 'package:flutter/material.dart';
import '../services/api_jogos.dart';

class AddGamePage extends StatefulWidget {
  final Function(Map<String, dynamic>, double) onAdd;

  const AddGamePage({super.key, required this.onAdd});

  @override
  State<AddGamePage> createState() => _AddGamePageState();
}

class _AddGamePageState extends State<AddGamePage> {
  final nameController = TextEditingController();
  final FocusNode nameFocus = FocusNode();
  double progress = 0.0;
  List<Map<String, dynamic>> searchResults = [];
  Map<String, dynamic>? selectedGame;

  Future<void> search(String name) async {
    if (name.isEmpty) {
      setState(() {
        searchResults = [];
        selectedGame = null;
      });
      return;
    }

    final results = await GameApiService.searchGame(name);
    if (results != null) {
      setState(() {
        searchResults = results;
        selectedGame = null;
      });
    }
  }

  void submit() async {
    if (selectedGame == null || progress == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um jogo e defina o progresso.')),
      );
      return;
    }

    widget.onAdd(selectedGame!, progress);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adicionar Novo Jogo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              focusNode: nameFocus,
              decoration: const InputDecoration(labelText: 'Nome do Jogo'),
              onChanged: search,
              maxLength: 40,
            ),
            if (searchResults.isNotEmpty)
              SizedBox(
                height: 200,
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
                        setState(() {
                          selectedGame = game;
                          searchResults = [];
                        });
                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            Text('Progresso: ${progress.toStringAsFixed(1)}%'),
            Slider(
              value: progress,
              min: 0.0,
              max: 100.0,
              divisions: 100,
              label: '${progress.toStringAsFixed(1)}%',
              onChanged: (value) => setState(() => progress = value),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submit,
              child: const Text('Adicionar Jogo'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    nameFocus.dispose();
    super.dispose();
  }
}
