import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_jogos.dart';
import '../services/map.dart';  // Import do widget LocationSelector (ajuste o caminho conforme seu projeto)

class AddGamePage extends StatefulWidget {
  final Function(Map<String, dynamic> game, double progress, double? lat, double? lon) onAdd;

  const AddGamePage({super.key, required this.onAdd});

  @override
  State<AddGamePage> createState() => _AddGamePageState();
}

class _AddGamePageState extends State<AddGamePage> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final FocusNode nameFocus = FocusNode();
  double progress = 0.0;
  List<Map<String, dynamic>> searchResults = [];
  Map<String, dynamic>? selectedGame;
  Map<String, dynamic>? selectedLocation;
  bool useCurrentLocation = true;
  late Future<Position> locationFuture;
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    locationFuture = _getLocation();
  }

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

  Future<Position> _getLocation() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) return Future.error("Serviço de localização desativado");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return Future.error("Permissão negada");
    }

    return await Geolocator.getCurrentPosition();
  }

  void submit() {
    if (selectedGame == null || progress == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um jogo e defina o progresso.')),
      );
      return;
    }

    double? lat;
    double? lon;
    String? placeName;

    if (useCurrentLocation) {
      lat = userPosition?.latitude;
      lon = userPosition?.longitude;
      placeName = 'Localização atual';
    } else {
      lat = selectedLocation?['lat'];
      lon = selectedLocation?['lon'];
      placeName = selectedLocation?['place_name'];
    }

    // Adiciona os dados ao objeto do jogo
    selectedGame!['progress'] = progress;
    selectedGame!['latitude'] = lat;
    selectedGame!['longitude'] = lon;
    selectedGame!['place_name'] = placeName;

    widget.onAdd(selectedGame!, progress, lat, lon);
    Navigator.pop(context);
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Adicionar Novo Jogo')),
    body: Stack(
      children: [
        // 📷 Imagem de fundo
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fundo.jpg'), 
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 🧱 Conteúdo com fundo transparente
        Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FutureBuilder<Position>(
              future: locationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Ocorreu um erro ao obter localização."));
                } else {
                  userPosition = snapshot.data;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          focusNode: nameFocus,
                          decoration: const InputDecoration(labelText: 'Nome do Jogo'),
                          onChanged: search,
                          maxLength: 55,
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
                                      ? Image.network(game['background_image'], width: 40, height: 40, fit: BoxFit.cover)
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
                        const Text('Última vez em que foi jogado:'),
                        SwitchListTile(
                          title: const Text('Usar localização atual'),
                          value: useCurrentLocation,
                          onChanged: (val) {
                            setState(() {
                              useCurrentLocation = val;
                              selectedLocation = null;
                              locationController.clear();
                            });
                          },
                        ),
                        if (!useCurrentLocation)
                          LocationSelector(
                            enabled: true,
                            onLocationSelected: (place) {
                              setState(() {
                                selectedLocation = place;
                              });
                            },
                          ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: submit,
                          child: const Text('Adicionar Jogo'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ],
    ),
  );
}


  @override
  void dispose() {
    nameController.dispose();
    nameFocus.dispose();
    locationController.dispose();
    super.dispose();
  }
}
