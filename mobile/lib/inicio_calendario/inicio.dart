import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/inicio_calendario/calendario.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/notificacoes.dart';
import 'package:mobile/definicoes_sobreconsultas/definicoes.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  int currentPageIndex = 0;

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
                              onPressed: () => context.go('/perfilcomdependentes'),
                              child: const Row(
                                children: [
                                  Icon(Icons.person, size: 20),
                                  SizedBox(width: 8),
                                  Text("Perfil"),
                                ],
                              ),
                            ),
                            MenuItemButton(
                              onPressed: () => context.go('/sobre_consultas'),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text("Sobre Consultas"),
                                ],
                              ),
                            ),
                            MenuItemButton(
                              onPressed: () => context.go('/terminar_sessao'),
                              child: const Row(
                                children: [
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

      body: IndexedStack(
        index: currentPageIndex,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Card do utilizador (em cima dos botões)
                _cardDashboard(
                  nome: "António Manuel Pereira",
                  nUtente: "283740538",
                  clinica: "Clinimolelos",
                ),
                const SizedBox(height: 20),

                const Botoes(),
                const SizedBox(height: 20),

                // Cards de consultas
                _cardConsulta(
                  tipoConsulta: "Consulta de rotina",
                  data: "16/12/2025",
                  horario: "10:30",
                ),
                _cardConsulta(
                  tipoConsulta: "Consulta de revisão",
                  data: "20/12/2025",
                  horario: "14:00",
                ),
              ],
            ),
          ),
          const Calendario(title: ''),
          const NotificacoesDados(title: ''),
          const Definicoes(title: 'Definições'),
        ],
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

// -------------------- BOTOES --------------------
class Botoes extends StatelessWidget {
  const Botoes({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _botao(
          context,
          icon: Icons.history_outlined,
          label: 'Histórico \n e Declarações',
          route: '/historico_declaracoes',
        ),
        const SizedBox(width: 20),
        _botao(
          context,
          icon: Icons.monitor_heart_outlined,
          label: 'Exames \n Clínicos',
          route: '/exames_clinicos',
        ),
        const SizedBox(width: 20),
        _botao(
          context,
          icon: Icons.assignment_ind_outlined,
          label: 'Planos \n de Tratamento',
          route: '/plano_tratamento',
        ),
      ],
    );
  }

  Widget _botao(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => context.go(route),
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF907041),
                  Color(0xFF97774D),
                  Color(0xFFA68A69),
                ],
              ),
              borderRadius: BorderRadius.circular(36),
            ),
            child: Icon(icon, size: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// -------------------- CARD UTILIZADOR --------------------
Widget _cardDashboard({
  required String nome,
  required String nUtente,
  required String clinica,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nome,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),

        Text('Nº Utente $nUtente', style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),

        const Text('Clínica Dentária', style:  TextStyle(fontSize: 12)),
        Text(
          clinica,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

// -------------------- CARD CONSULTA --------------------
Widget _cardConsulta({
  required String tipoConsulta,
  required String data, // ex: 16/12/2025
  required String horario,
}) {
  final partesData = data.split('/'); // [dd, MM, yyyy]
  final dia = partesData[0];
  final mesNumero = int.parse(partesData[1]);
  final ano = partesData[2];

  const meses = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];

  final mesTexto = meses[mesNumero - 1];


  return Container(
    constraints: const BoxConstraints(
      minHeight: 90, // altura mínima
    ),
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DATA À ESQUERDA
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mesTexto, style: const TextStyle(fontSize: 12)),
            Text(
              dia,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(ano, style: const TextStyle(fontSize: 12)),
          ],
        ),

        const SizedBox(width: 16),


        // CONTEÚDO À DIREITA
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consulta',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tipoConsulta,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                horario,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
