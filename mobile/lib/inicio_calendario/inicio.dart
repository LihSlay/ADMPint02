import 'package:flutter/material.dart';
import 'package:mobile/inicio_calendario/calendario.dart';
import 'package:mobile/inicio_calendario/notificacao.dart';
import 'package:mobile/inicio_calendario/definicao.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Inicio());
  }
}

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _Inicio();
}

class _Inicio extends State<Inicio> {
  int currentPageIndex = 0;

  final List<String> titulos = [
    '',
    'Calendário',
    'Notificações',
    'Definições',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) => Colors.transparent,
        ),
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.transparent,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_month),
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Calendário',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.notifications),
            icon: Icon(Icons.notifications_outlined),
            label: 'Notificações',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Definições',
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          titulos[currentPageIndex],
          style: const TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF907041), Color(0xFF97774D), Color(0xFFA68A69)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          MenuAnchor(
            builder:
                (
                  BuildContext context,
                  MenuController controller,
                  Widget? child,
                ) {
                  return GestureDetector(
                    onTap: () {
                      controller.isOpen
                          ? controller.close()
                          : controller.open();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 19),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "AM",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
            menuChildren: [
              MenuItemButton(child: const Text("Perfil"), onPressed: () {}),
              MenuItemButton(
                child: const Text("Sobre Consultas"),
                onPressed: () {},
              ),
              MenuItemButton(
                child: const Text("Terminar Sessão"),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
      body: <Widget>[
        // Página Início com Botoes integrado
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Botoes(),
            ],
          ),
        ),
        Calendario(title: ''),
        Notificacao(title: ''),
        Definicao(title: ''),
      ][currentPageIndex],
    );
  }
}


class Botoes extends StatelessWidget {
  const Botoes({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBotao(
              context,
              icon: Icons.history_outlined,
              label: 'Histórico \n e Declarações',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Calendario(title: ''),
                  ),
                );
              },
            ),
            const SizedBox(width: 20),
            _buildBotao(
              context,
              icon: Icons.monitor_heart_outlined,
              label: 'Exames \n Clínicos',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Calendario(title: ''),
                  ),
                );
              },
            ),
            const SizedBox(width: 20),
            _buildBotao(
              context,
              icon: Icons.assignment_ind_outlined,
              label: 'Planos \n de Tratamento',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Calendario(title: ''),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotao(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 70, // largura do círculo
            height: 70, // altura do círculo (igual à largura)
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF907041),
                  Color(0xFF97774D),
                  Color(0xFFA68A69)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(35), // metade do width/height para círculo
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}