import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Palavrapasse extends StatefulWidget {
  final String title;

  const Palavrapasse({super.key, required this.title});

  @override
  State<Palavrapasse> createState() => _PalavrapasseState();
}

class _PalavrapasseState extends State<Palavrapasse> {
  int currentPageIndex = 3; // Definições

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white), // título branco
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF907041), Color(0xFF97774D), Color(0xFFA68A69)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          20,
        ), // aplica 20 pixels de espaço em todas as direções
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Palavra-passe atual",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            // caixas de texto
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            const Text(
              "Palavra-passe nova",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            // caixas de texto
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            const Text(
              "Confirmar palavra-passe nova",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            // caixas de texto
            TextField(
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity, // o botão fica no comprimento da tela
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Continuar"),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.transparent,
        onDestinationSelected: (index) {
          setState(() => currentPageIndex = index);

          switch (index) {
            case 0:
              context.go('/inicio');
              break;
            case 1:
              context.go('/calendario');
              break;
            case 2:
              context.go('/notificacoes');
              break;
            case 3:
              context.go('/definicoes');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Calendário'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Notificações'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Definições'),
        ],
      ),
    );
  }
}
