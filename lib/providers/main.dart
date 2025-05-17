import 'package:flutter/material.dart';
import 'package:game_catalog/pages/principal_page.dart';
import 'package:game_catalog/pages/sobre_page.dart';
import 'package:game_catalog/routers/routers.dart';
void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Jogos',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 6, 10, 245)),
      ),
      //home: const HomePage(),
        routes: {
          Routes.HOME: (context) => HomePage(),
          Routes.SOBRE: (context) => SobrePage(),
        },
    );
  }
}


