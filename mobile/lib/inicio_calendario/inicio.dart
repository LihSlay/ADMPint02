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
              preferredSize: const Size.fromHeight(30),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
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
                  Padding(
                    padding: const EdgeInsets.only(right: 10, bottom: 5), // Afasta o botão do lado direito
                    child: MenuAnchor(
                      builder: (context, controller, child) {
                        return GestureDetector(
                          onTap: () {
                            controller.isOpen ? controller.close() : controller.open();
                          },
                          child: Container(
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
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
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
                  ),
                ],
              ),
            )
          : null,
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          SingleChildScrollView(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Gradiente atrás do dashboard só até metade
                Container(
                  height: 60, // metade do container dashboard 
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
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _cardDashboard(
                        nome: "António Manuel Pereira",
                        nUtente: "283740538",
                        clinica: "Clinimolelos",
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Botoes(),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF907041),
                            Color(0xFF97774D),
                            Color(0xFFA68A69),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Consultas marcadas",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Text(
                                    "2",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
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
                    ),
                  ],
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
      borderRadius: BorderRadius.circular(4),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Nº Utente $nUtente', style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        const Text('Clínica Dentária', style: TextStyle(fontSize: 12)),
        Text(clinica, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}


Widget _cardConsulta({
  required String tipoConsulta,
  required String data,
  required String horario,
}) {
  final partesData = data.split('/'); // [dd, MM, yyyy]
  final dia = partesData[0];
  final mesNumero = int.parse(partesData[1]);
  final ano = partesData[2];

  const meses = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];
  final mesTexto = meses[mesNumero - 1];

  return Container(
    constraints: const BoxConstraints(minHeight: 70),
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.fromLTRB(20, 10, 10, 10), // mais espaço à esquerda
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mesTexto, style: const TextStyle(fontSize: 12)),
            Text(dia, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(ano, style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Consulta', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(tipoConsulta, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 2),
              Text(horario, style: const TextStyle(fontSize: 12)),
            ],
          ),
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
