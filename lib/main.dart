import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Jogos',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Catálogo de Jogos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => HomePage();
}

class HomePage extends State<MyHomePage> {
  List<Map<String, dynamic>> myGames = [];

  Future<Map<String, dynamic>?> searchGame(String name) async {
    final response = await http.get(Uri.parse(
        'https://api.rawg.io/api/games?search=$name&key=405fff01985046128081fa8079201873'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        return data['results'][0]; // Pega o primeiro resultado
      }
    }
    return null;
  }

  void addGame(Map<String, dynamic> game, double progress) {
    setState(() {
      myGames.add({
        'name': game['name'],
        'background_image': game['background_image'],
        'rating': game['rating'],
        'progress': progress,
      });
    });
  }

  void updateGame(int index, double newProgress) {
    setState(() {
      myGames[index]['progress'] = newProgress;
    });
  }

  void deleteGame(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text('Você tem certeza que deseja excluir este jogo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o diálogo sem excluir
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  myGames.removeAt(index); // Exclui o jogo
                });
                Navigator.pop(context); // Fecha o diálogo
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  void openAddGameDialog() {
    final nameController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];
    double progress = 0.0; // Valor inicial para o progresso

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          void search(String name) async {
            if (name.isEmpty) {
              setStateDialog(() {
                searchResults = [];
              });
              return;
            }

            final response = await http.get(Uri.parse(
                'https://api.rawg.io/api/games?search=$name&key=405fff01985046128081fa8079201873'));

            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              setStateDialog(() {
                searchResults = List<Map<String, dynamic>>.from(data['results']);
              });
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
                      decoration: const InputDecoration(
                        labelText: 'Nome do Jogo',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        search(value);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (searchResults.isNotEmpty)
                      SizedBox(
                        height: 200, // Aqui limitamos de verdade
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
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
                                setStateDialog(() {
                                  searchResults = [];
                                });
                              },
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Slider para selecionar o progresso
                    Text('Progresso: ${progress.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 16)),
                    Slider(
                      value: progress,
                      min: 0.0,
                      max: 100.0,
                      divisions: 100,
                      label: '${progress.toStringAsFixed(1)}%',
                      onChanged: (double newProgress) {
                        setStateDialog(() {
                          progress = newProgress; // Atualiza o valor do progresso
                        });
                      },
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

                  final game = await searchGame(name);
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
        });
      },
    );
  }

  void openUpdateProgressDialog(int index) {
    double progress = myGames[index]['progress']; // Valor inicial do progresso

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atualizar Progresso'),
          content: StatefulBuilder(
            builder: (context, setStateDialog) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Progresso Atual: ${progress.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16)),
                  Slider(
                    value: progress,
                    min: 0.0,
                    max: 100.0,
                    divisions: 100,
                    label: '${progress.toStringAsFixed(1)}%',
                    onChanged: (double newProgress) {
                      setStateDialog(() {
                        progress = newProgress; // Atualiza o valor do progresso
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                updateGame(index, progress); // Atualiza o progresso do jogo
                Navigator.pop(context);
              },
              child: const Text('Atualizar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Catálogo de Jogos', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
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
                itemBuilder: (context, index) {
                  final game = myGames[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 4,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
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
                        'Nota : ${game['rating']} | Progresso: ${game['progress']}%',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            openUpdateProgressDialog(index);
                          } else if (value == 'delete') {
                            deleteGame(index);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar Progresso'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Excluir'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openAddGameDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}