import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/map.dart';
import '../services/locationselector.dart';

class UpdateProgressPage extends StatefulWidget {
  final double initialProgress;
  final double? initialLat;
  final double? initialLon;
  final Function(double, double?, double?, String?) onUpdate;

  const UpdateProgressPage({
    super.key,
    required this.initialProgress,
    required this.onUpdate,
    this.initialLat,
    this.initialLon,
  });

  @override
  State<UpdateProgressPage> createState() => _UpdateProgressPageState();
}

class _UpdateProgressPageState extends State<UpdateProgressPage> {
  late double progress;
  bool useCurrentLocation = true;
  Map<String, dynamic>? selectedLocation;
  late Future<Position> locationFuture;
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    progress = widget.initialProgress;
    locationFuture = _getLocation();
  }

  Future<Position> _getLocation() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) return Future.error("Serviço de localização desativado");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return Future.error("Permissão de localização negada");
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> submit() async {
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

    widget.onUpdate(progress, lat, lon, placeName);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar Progresso'),
        centerTitle: true,
      ),
      body: FutureBuilder<Position>(
        future: locationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            userPosition = snapshot.data;
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Progresso Atual: ${progress.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Slider(
                          value: progress,
                          min: 0.0,
                          max: 100.0,
                          divisions: 100,
                          label: '${progress.toStringAsFixed(1)}%',
                          onChanged: (value) => setState(() => progress = value),
                        ),
                        const SizedBox(height: 24),
                        SwitchListTile(
                          title: const Text('Usar localização atual'),
                          value: useCurrentLocation,
                          onChanged: (val) {
                            setState(() {
                              useCurrentLocation = val;
                              selectedLocation = null;
                            });
                          },
                        ),
                        if (!useCurrentLocation)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: LocationSelector(
                              enabled: true,
                              onLocationSelected: (place) {
                                setState(() => selectedLocation = place);
                              },
                            ),
                          ),
                        const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: submit,
                            icon: const Icon(Icons.save),
                            label: const Text('Salvar'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
