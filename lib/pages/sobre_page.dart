import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'CHECKPOINTO',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Este aplicativo permite que você explore um catálogo de jogos, veja detalhes como plataformas, gêneros e conquistas, e mantenha seus jogos favoritos organizados.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Versão: 1.0.0',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 10),
            Text(
              'Desenvolvido por Davy de Souza',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
