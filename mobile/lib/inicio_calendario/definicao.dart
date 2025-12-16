import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class Definicao extends StatefulWidget {
  const Definicao({super.key, required this.title});
  final String title;

  @override
  State<Definicao> createState() => _DefinicaoState();
}

class _DefinicaoState extends State<Definicao> {
  int currentPageIndex = 3; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title.isEmpty ? 'Definição' : widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Página Definição.'),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.transparent,
        onDestinationSelected: (index) {
          setState(() {
            currentPageIndex = index;
          });

          // Navegação entre páginas
          switch (index) {
            case 0:
              context.go('/'); // Início
              break;
            case 1:
              context.go('/calendario'); // Calendário
              break;
            case 2:
              context.go('/notificacao'); // Notificações
              break;
            case 3:
              context.go('/definicoes'); // Definições
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendário',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notificações',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Definições',
          ),
        ],
      ),
    );
  }
}
