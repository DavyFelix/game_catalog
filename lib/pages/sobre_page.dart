import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagem de fundo cobrindo tudo
        Positioned.fill(
          child: Image.asset(
            'assets/images/menuft.png',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Sobre o App'),
            backgroundColor: const Color.fromARGB(255, 230, 252, 152).withOpacity(0.9),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'CHECKPOINTO',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Este aplicativo permite que você explore um catálogo de jogos, veja detalhes como plataformas, gêneros e conquistas, e mantenha seus jogos favoritos organizados.',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'Versão: 1.0.0',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white70),
                ),
                SizedBox(height: 10),
                Text(
                  'Desenvolvido por Davy de Souza',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
