import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationSelector extends StatefulWidget {
  final bool enabled;
  final Function(Map<String, dynamic>?) onLocationSelected;

  const LocationSelector({
    super.key,
    required this.enabled,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> suggestions = [];
  bool isLoading = false;
  String _lastQuery = '';

  Future<List<Map<String, dynamic>>> fetchSuggestions(String input) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(input)}&format=json&limit=5&addressdetails=1',
    );

    final response = await http.get(url, headers: {'User-Agent': 'flutter_app'});

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<Map<String, dynamic>>((item) {
        return {
          'place_name': item['display_name'],
          'lat': double.tryParse(item['lat']),
          'lon': double.tryParse(item['lon']),
        };
      }).toList();
    }

    return [];
  }

  Future<String?> getPlaceNameFromCoordinates(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon',
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'catalogo-jogos-app',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['display_name'];
    } else {
      return null;
    }
  }

  void onSelect(Map<String, dynamic> place) {
    controller.text = place['place_name'];
    widget.onLocationSelected(place);
    setState(() => suggestions = []);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();

    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Digite um local'),
          maxLength: 250,
          onChanged: (value) async {
            if (value.length < 3 || value == _lastQuery) return;
            _lastQuery = value;

            setState(() {
              isLoading = true;
            });

            final results = await fetchSuggestions(value);
            setState(() {
              suggestions = results;
              isLoading = false;
            });
          },
        ),
        if (isLoading)
          const LinearProgressIndicator(),
        if (!isLoading && suggestions.isEmpty && controller.text.length >= 3)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Nenhum local encontrado',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        if (suggestions.isNotEmpty)
          SizedBox(
            height: 150,
            child: ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (_, index) {
                final item = suggestions[index];
                return ListTile(
                  title: Text(item['place_name']),
                  onTap: () => onSelect(item),
                );
              },
            ),
          ),
      ],
    );
  }
}
