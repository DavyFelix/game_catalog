import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../services/api_jogos.dart';
import '../services/map.dart';
import '../services/locationselector.dart'; 
import 'package:game_catalog/providers/gameprovider.dart';

class AddGamePage extends StatefulWidget {

  const AddGamePage({super.key});

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

 void submit() async {
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

    if (lat != null && lon != null) {
      placeName = await getPlaceNameFromCoordinates(lat, lon);
    }
  } else {
    lat = selectedLocation?['lat'];
    lon = selectedLocation?['lon'];
    placeName = selectedLocation?['place_name'];
  }

  final game = {
    ...selectedGame!,
    'progress': progress,
    'latitude': lat,
    'longitude': lon,
    'place_name': placeName,
  };

  // Usa o Provider para adicionar o jogo
  Provider.of<GameProvider>(context, listen: false).addGame(
    game,
    progress,
    lat,
    lon,
  );

  Navigator.pop(context);
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Adicionar Novo Jogo')),
    body: Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fundo.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth < 600 ? constraints.maxWidth : 600.0;

            return Center(
              child: Container(
                width: maxWidth,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(16),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Campo Nome Jogo
                            TextField(
                              controller: nameController,
                              focusNode: nameFocus,
                              decoration: const InputDecoration(labelText: 'Nome do Jogo'),
                              onChanged: search,
                              maxLength: 55,
                              textInputAction: TextInputAction.done,
                            ),

                            if (searchResults.isNotEmpty)
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: searchResults.length,
                                  itemBuilder: (_, index) {
                                    final game = searchResults[index];
                                    return ListTile(
                                      leading: game['background_image'] != null
                                          ? Image.network(game['background_image'],
                                              width: 40, height: 40, fit: BoxFit.cover)
                                          : const Icon(Icons.videogame_asset),
                                      title: Text(game['name']),
                                      onTap: () {
                                        nameController.text = game['name'];
                                        FocusScope.of(context).unfocus();
                                        setState(() {
                                          selectedGame = game;
                                          searchResults = [];
                                        });
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
                              onPressed: (selectedGame != null && progress > 0) ? submit : null,
                              child: const Text('Adicionar Jogo'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
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
