import 'package:flutter/material.dart';

class GameProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _games = [];

  List<Map<String, dynamic>> get games => _games;

  void addGame(Map<String, dynamic> game, double progress, double? lat, double? lng) {
    _games.add({
      ...game,
      'progress': progress,
      'latitude': lat,
      'longitude': lng,
      'lastModified': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  void updateGame(int index, double progress, double? lat, double? lng, String? placeName) {
    _games[index]['progress'] = progress;
    _games[index]['latitude'] = lat;
    _games[index]['longitude'] = lng;
    _games[index]['place_name'] = placeName;
    _games[index]['lastModified'] = DateTime.now().toIso8601String();
    notifyListeners();
  }

  void deleteGame(int index) {
    _games.removeAt(index);
    notifyListeners();
  }
}
