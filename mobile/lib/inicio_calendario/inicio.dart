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
          ? PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: AppBar(
                backgroundColor: Colors.transparent,
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
                          controller.isOpen
                              ? controller.close()
                              : controller.open();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 20),
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
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                    menuChildren: [
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(cardColor: Colors.white),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MenuItemButton(
                              onPressed: () => context.go('/calendario'),
                              child: Row(
                                children: const [
                                  Icon(Icons.person, size: 20),
                                  SizedBox(width: 8),
                                  Text("Perfil"),
                                ],
                              ),
                            ),
                            MenuItemButton(
                              onPressed: () => context.go('/sobre_consultas'),
                              child: Row(
                                children: const [
                                  Icon(Icons.info_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text("Sobre Consultas"),
                                ],
                              ),
                            ),
                            MenuItemButton(
                              onPressed: () => context.go('/terminar_sessao'),
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
              ),
            )
          : null,
      body: Stack(
        children: [
          // Conteúdo principal
          IndexedStack(
            index: currentPageIndex,
            children: const [
              Center(child: Botoes()),
              Calendario(title: ''),
              Notificacao(title: ''),
              Definicoes(title: 'Definições'),
            ],
          ),

          // Container de texto à frente de tudo
          Positioned(
            top: 24, // altura a partir do topo
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'António Manuel Pereira',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Nº Utente 283740538',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Clínica Dentária',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Clinimolelos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.transparent,
        onDestinationSelected: (index) {
          setState(() {
            currentPageIndex = index;
          });

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
    return Padding(
padding: const EdgeInsets.only(top: 0), // aumenta este valor para descer os botões
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBotao(
              context,
              icon: Icons.history_outlined,
              label: 'Histórico \n e Declarações',
              onPressed: () {
                context.go('/historico_declaracoes');
              },
            ),
            const SizedBox(width: 20),
            _buildBotao(
              context,
              icon: Icons.monitor_heart_outlined,
              label: 'Exames \n Clínicos',
              onPressed: () {
                context.go('/exames_clinicos');
              },
            ),
            const SizedBox(width: 20),
            _buildBotao(
              context,
              icon: Icons.assignment_ind_outlined,
              label: 'Planos \n de Tratamento',
              onPressed: () {
                context.go('/plano_tratamento');
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBotao(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 67,
            height: 67,
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
              borderRadius: BorderRadius.circular(36),
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
