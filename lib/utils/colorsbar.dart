// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ColorsbBars {
  static Color fromGenre(String genre) {
    switch (genre.toLowerCase()) {
      case 'action':
        return Colors.red;
      case 'rpg':
        return Colors.deepPurple;
      case 'strategy':
        return Colors.blue;
      case 'sports':
        return Colors.green;
      case 'adventure':
        return Colors.orange;
      default:
        return const Color.fromARGB(255, 32, 193, 233); // cor padrão
    }
  }
}
