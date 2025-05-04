import 'dart:convert';
import 'package:http/http.dart' as http;

class GameApiService {
  static const String _apiKey = '405fff01985046128081fa8079201873';
  static const String _baseUrl = 'https://api.rawg.io/api/games';

  // Função para buscar um jogo pelo nome
  static Future<Map<String, dynamic>?> searchGame(String name) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?search=$name&key=$_apiKey'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]; // Retorna o primeiro jogo encontrado
        }
      }
      return null;
    } catch (e) {
      print('Erro na requisição de busca: $e');
      return null;
    }
  }

  // Função para pegar os detalhes de um jogo com base no ID
  static Future<Map<String, dynamic>?> getGameDetails(int gameId) async {
    try {
      final detailsRes = await http.get(Uri.parse('$_baseUrl/$gameId?key=$_apiKey'));
      if (detailsRes.statusCode == 200) {
        final gameDetails = json.decode(detailsRes.body);
        
        // Obter as conquistas do jogo
        final achievementsRes = await http.get(Uri.parse('$_baseUrl/$gameId/achievements?key=$_apiKey'));
        if (achievementsRes.statusCode == 200) {
          final achievements = json.decode(achievementsRes.body);
          gameDetails['achievements'] = achievements['results'] ?? [];
        }
        return gameDetails;
      }
      return null;
    } catch (e) {
      print('Erro na requisição de detalhes do jogo: $e');
      return null;
    }
  }
}
