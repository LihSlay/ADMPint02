import 'package:flutter/material.dart';

class NotificacoesDados extends StatelessWidget {
  final String title;
  const NotificacoesDados({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          NotificacaoItem(
            icon: Icons.close,
            texto: "A sua consulta no dia 24/08/2025 foi desmarcada.",
          ),
          NotificacaoItem(
            icon: Icons.calendar_month,
            texto: "A sua consulta para dia 20/11/2025 foi agendada.",
          ),
          NotificacaoItem(
            icon: Icons.restart_alt,
            texto:
                "Foi submetida a declaração de presença para a consulta de Clareamento dentário do dia 13/10/2025.",
          ),
          NotificacaoItem(
            icon: Icons.monitor_heart_outlined,
            texto:
                "Foi submetido um novo exame clínico à sua ficha de paciente.",
          ),
          NotificacaoItem(
            icon: Icons.article_outlined,
            texto: "O seu plano de tratamento dentário foi atualizado.",
          ),
        ],
      ),

      // ---------------- Barra de Navegação ----------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // tab das notificações
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Início",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: "Calendário",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notificações",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: "Definições",
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

  const NotificacaoItem({
    super.key,
    required this.icon,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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
        const SizedBox(height: 12),
      ],
    );
  }
}
