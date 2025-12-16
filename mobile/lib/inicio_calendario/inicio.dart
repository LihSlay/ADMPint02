import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/inicio_calendario/calendario.dart';
import 'package:mobile/inicio_calendario/notificacao.dart';
import 'package:mobile/definicoes_sobreconsultas/definicoes.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  int currentPageIndex = 0;

  final List<String> titulos = [
    '', // Início
    'Calendário',
    'Notificações',
    'Definições',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentPageIndex == 0
          ? AppBar(
              title: Text(
                titulos[currentPageIndex],
                style: const TextStyle(color: Colors.white),
              ),
              foregroundColor: Colors.white,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF907041),
                      Color(0xFF97774D),
                      Color(0xFFA68A69),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              actions: [
                MenuAnchor(
                  builder: (context, controller, child) {
                    return GestureDetector(
                      onTap: () {
                        controller.isOpen ? controller.close() : controller.open();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 19),
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "AM",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                  menuChildren: [
                    Theme(
                      data: Theme.of(context).copyWith(cardColor: Colors.white),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MenuItemButton(
                            onPressed: () {
                              context.go('/calendario'); // Perfil
                            },
                            child: Row(
                              children: const [
                                Icon(Icons.person, size: 20),
                                SizedBox(width: 8),
                                Text("Perfil"),
                              ],
                            ),
                          ),
                          MenuItemButton(
                            onPressed: () {
                              context.go('/sobre_consultas');
                            },
                            child: Row(
                              children: const [
                                Icon(Icons.info_outline, size: 20),
                                SizedBox(width: 8),
                                Text("Sobre Consultas"),
                              ],
                            ),
                          ),
                          MenuItemButton(
                            onPressed: () {
                              context.go('/calendario'); // Terminar sessão
                            },
                            child: Row(
                              children: const [
                                Icon(Icons.logout, size: 20),
                                SizedBox(width: 8),
                                Text("Terminar Sessão"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            )
          : null,
      body: <Widget>[
        const Center(child: Botoes()),
        const Calendario(title: ''),
        const Notificacao(title: ''),
        const Definicoes(title: 'Definições'),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.transparent,
        onDestinationSelected: (index) {
          setState(() {
            currentPageIndex = index;
          });

          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/calendario');
              break;
            case 2:
              context.go('/notificacao');
              break;
            case 3:
              context.go('/definicao');
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

// Botões do início
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
                context.go('/calendario');
              },
            ),
            const SizedBox(width: 20),
            _buildBotao(
              context,
              icon: Icons.monitor_heart_outlined,
              label: 'Exames \n Clínicos',
              onPressed: () {
                context.go('/calendario');
              },
            ),
            const SizedBox(width: 20),
            _buildBotao(
              context,
              icon: Icons.assignment_ind_outlined,
              label: 'Planos \n de Tratamento',
              onPressed: () {
                context.go('/calendario');
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
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF907041),
                  Color(0xFF97774D),
                  Color(0xFFA68A69),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(35),
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
