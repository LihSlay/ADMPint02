import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificacoesDados extends StatefulWidget {
  final String title;
  const NotificacoesDados({super.key, required this.title});

  @override
  State<NotificacoesDados> createState() => _NotificacoesDadosState();
}

class _NotificacoesDadosState extends State<NotificacoesDados> {
  int currentPageIndex = 2; // Notificações

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notificacoes = [
      {
        'icon': Icons.close,
        'texto': "A sua consulta no dia 24/08/2025 foi desmarcada.",
        'rota': '/calendario',
      },
      {
        'icon': Icons.calendar_month,
        'texto': "A sua consulta para dia 20/11/2025 foi agendada.",
        'rota': '/calendario',
      },
      {
        'icon': Icons.restart_alt,
        'texto':
            "Foi submetida a declaração de presença para a consulta de Clareamento dentário do dia 13/10/2025.",
        'rota': '/sobre_consultas',
      },
      {
        'icon': Icons.monitor_heart_outlined,
        'texto':
            "Foi submetido um novo exame clínico à sua ficha de paciente.",
        'rota': '/perfildependente',
      },
      {
        'icon': Icons.article_outlined,
        'texto': "O seu plano de tratamento dentário foi atualizado.",
        'rota': '/sobre_consultas',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      // ---------------- APPBAR COM GRADIENTE ----------------
      appBar: AppBar(
        title: const Text(
          "Notificações",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF907041),
                Color(0xFF97774D),
                Color(0xFFA68A69),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),

      // ---------------- LISTA DE NOTIFICAÇÕES ----------------
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: notificacoes.length,
        itemBuilder: (context, index) {
          final item = notificacoes[index];
          return NotificacaoItem(
            icon: item['icon'],
            texto: item['texto'],
            onTap: () {
              context.go(item['rota']); // Callback para abrir a página
            },
          );
        },
      ),

      // ---------------- NavigationBar ----------------
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

// ------------------- WIDGET DE UM ITEM DE NOTIFICAÇÃO -------------------
class NotificacaoItem extends StatelessWidget {
  final IconData icon;
  final String texto;
  final VoidCallback onTap;

  const NotificacaoItem({
    super.key,
    required this.icon,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2C8A6), width: 1),
                bottom: BorderSide(color: Color(0xFFE2C8A6), width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 32, color: Colors.black87),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    texto,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
