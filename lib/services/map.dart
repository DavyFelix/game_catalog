// map.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Retorna o nome do local com base nas coordenadas geográficas (Nominatim)
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
