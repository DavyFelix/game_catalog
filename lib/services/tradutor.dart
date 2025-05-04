import 'dart:convert';
import 'package:http/http.dart' as http;

class Translator {
  static Future<String> translateToPortuguese(String text) async {
    final url = Uri.parse('https://libretranslate.de/translate');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'q': text,
        'source': 'en',
        'target': 'pt',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['translatedText'];
    } else {
      throw Exception('Erro ao traduzir: ${response.statusCode}');
    }
  }
}
