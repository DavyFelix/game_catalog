import 'package:flutter/material.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://sdmntpreastus2.oaiusercontent.com/files/00000000-6e4c-61f6-ad17-ce9966a8293f/raw?se=2025-05-09T14%3A42%3A36Z&sp=r&sv=2024-08-04&sr=b&scid=00000000-0000-0000-0000-000000000000&skoid=c156db82-7a33-468f-9cdd-06af263ceec8&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2025-05-09T12%3A56%3A09Z&ske=2025-05-10T12%3A56%3A09Z&sks=b&skv=2024-08-04&sig=JbmJFbWKldx5sC1Wi%2BmzaJQAJ%2Btawk7qv5kKhV/D5No%3D',
                ),
                fit: BoxFit.fitWidth,
              ),
            ),
            child: Center(
              child: Stack(
                children: [
                  // Contorno
                  Text(
                    'CHECKPOINTO',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = const Color.fromARGB(255, 22, 22, 22),
                      shadows: [
                        Shadow(
                          blurRadius: 8,
                          color: Colors.black45,
                          offset: Offset(6, 6),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Preenchimento
                  Text(
                    'CHECKPOINTO',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 234, 252, 76),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.star_outlined),
            title: Text("Favoritos"),
            trailing: Icon(Icons.arrow_right),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text("Sobre"),
            trailing: Icon(Icons.arrow_right),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
