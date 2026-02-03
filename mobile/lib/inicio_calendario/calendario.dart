import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key, required this.title});
  final String title;

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  int currentPageIndex = 1;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title.isEmpty ? 'Calendário' : widget.title),
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
      ),
      body: SingleChildScrollView(
        // remove o padding aqui
        child: Column(
          children: [
            // Calendário
            SizedBox(
              height: 217,
              child: TableCalendar(
  firstDay: DateTime.utc(2020, 1, 1),
  lastDay: DateTime.utc(2030, 12, 31),
  focusedDay: _focusedDay,
  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
  onDaySelected: (selectedDay, focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  },
  headerStyle: const HeaderStyle(
    formatButtonVisible: false,
    titleTextStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    titleCentered: true,
    leftChevronPadding: EdgeInsets.zero,
    rightChevronPadding: EdgeInsets.zero,
  ),
  daysOfWeekHeight: 20,
  rowHeight: 31, // aumenta a altura da linha para círculos maiores
  calendarStyle: const CalendarStyle(
    defaultTextStyle: TextStyle(fontSize: 12),
    weekendTextStyle: TextStyle(fontSize: 12),
    todayDecoration: BoxDecoration(
      color: Color(0xFF97774D),
      shape: BoxShape.circle,
    ),
    todayTextStyle: TextStyle(
      fontSize: 16, // aumenta o tamanho do número do dia atual
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    selectedDecoration: BoxDecoration(
      color: Color(0xFFA68A69),
      shape: BoxShape.circle,
    ),
  ),
),

            ),

            const SizedBox(height: 20),

            // Container do gradiente ocupa toda a largura
            Container(
              width: double.infinity, // toca nas bordas
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
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text(
                            "2",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.transparent,
        backgroundColor: Colors.white,
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

  // -------------------- CARD CONSULTA --------------------

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
