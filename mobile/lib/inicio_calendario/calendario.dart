import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mobile/models/consulta_model.dart';
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Calendario extends StatefulWidget {
  const Calendario({super.key, required this.title});
  final String title;

  @override
  State<Calendario> createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  int currentPageIndex = 1;

  // No _CalendarioState adiciona esta função:
  List<Consulta> _consultasDoDia(DateTime day) {
    return consultas.where((c) {
      try {
        final data = DateTime.parse(c.dataConsulta ?? '');
        return data.year == day.year &&
            data.month == day.month &&
            data.day == day.day;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  List<Consulta> consultas = [];
  bool _aCarregar = true;

  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _carregarConsultas();
  }

  Future<void> _carregarConsultas() async {
    setState(() => _aCarregar = true);
    try {
      debugPrint("A carregar consultas...");
      List<Consulta> list = await ApiService().getConsultas();
      // Filtrar pelo perfil ativo (id_perfis) para respeitar a troca de dependente
      final prefs = await SharedPreferences.getInstance();
      final int? idPerfisAtivo = prefs.getInt('id_perfis');
      if (idPerfisAtivo != null) {
        list = list.where((c) => c.idPerfis == idPerfisAtivo).toList();
      }
      debugPrint("Consultas recebidas: ${list.length}");
      final hoje = DateTime.now();

      list.sort((a, b) {
        DateTime dataA;
        DateTime dataB;

        try {
          dataA = DateTime.parse(a.dataConsulta ?? '');
        } catch (_) {
          dataA = DateTime(2100); // vai para o fim
        }

        try {
          dataB = DateTime.parse(b.dataConsulta ?? '');
        } catch (_) {
          dataB = DateTime(2100);
        }

        // prioridade: datas futuras mais próximas
        final diffA = dataA.difference(hoje).inMinutes;
        final diffB = dataB.difference(hoje).inMinutes;

        return diffA.compareTo(diffB);
      });

      setState(() {
        consultas = list;
      });
    } catch (e) {
      debugPrint("Erro ao carregar consultas: $e");
    } finally {
      setState(() => _aCarregar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/inicio'), // vai para a rota /inicio
        ),
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

      body: Column(
        children: [
          // Calendário dentro de container com bordas
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white, // fundo do container
              borderRadius: BorderRadius.circular(12), // bordas arredondadas
              border: Border.all(
                color: Colors.transparent, // cor da borda
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              height: 217,

              child: TableCalendar(
                locale: 'pt_PT', // 🇵🇹 meses e datas em português

                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,

                selectedDayPredicate: (day) => false, // desativa seleção
                eventLoader: (day) => _consultasDoDia(day),

                calendarStyle: const CalendarStyle(
                  outsideDaysVisible:
                      false, // ⬅️ remove dias do mês anterior/seguinte
                ),

                calendarBuilders: CalendarBuilders(
                  todayBuilder: (context, day, focusedDay) {
                    return Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: Color(0xFFA68A69),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },

                  defaultBuilder: (context, day, focusedDay) {
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  },

                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 16,
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF907041),
                                Color(0xFF97774D),
                                Color(0xFFA68A69),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),

                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronPadding: EdgeInsets.zero,
                  rightChevronPadding: EdgeInsets.zero,

                  titleTextStyle: const TextStyle(
                    color: Color(0xFF907041),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),

                  // ⬇️ garante o nome do mês em português
                  titleTextFormatter: (date, locale) {
                    const meses = [
                      'Janeiro',
                      'Fevereiro',
                      'Março',
                      'Abril',
                      'Maio',
                      'Junho',
                      'Julho',
                      'Agosto',
                      'Setembro',
                      'Outubro',
                      'Novembro',
                      'Dezembro',
                    ];
                    return '${meses[date.month - 1]} ${date.year}';
                  },
                ),

                daysOfWeekHeight: 20,
                rowHeight: 26,

                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                  weekendStyle: const TextStyle(fontSize: 12),
                  dowTextFormatter: (date, locale) {
                    const diasSemana = [
                      'Seg',
                      'Ter',
                      'Qua',
                      'Qui',
                      'Sex',
                      'Sáb',
                      'Dom',
                    ];
                    return diasSemana[date.weekday - 1];
                  },
                ),

                onDaySelected: (_, __) {}, // clique desativado
              ),
            ),
          ),

          const SizedBox(height: 2),

          // Container das consultas com gradiente
          Expanded(
            child: Container(
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
                          child: Text(
                            "${consultas.length}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _aCarregar
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : consultas.isEmpty
                          ? const _SemConsultas()
                          : ListView.builder(
                              itemCount: consultas.length,
                              itemBuilder: (context, index) {
                                final c = consultas[index];
                                return _cardConsulta(
                                  context: context,
                                  tipoConsulta:
                                      c.especialidadeNome ??
                                      c.medicoNome ??
                                      "Consulta",
                                  data: c.dataConsulta ?? "2025-01-01",
                                  horario:
                                      "${c.horarioInicio ?? "--:--"} - ${c.horarioFim ?? "--:--"}",
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.transparent,
        backgroundColor: Colors.white,
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

// ================= WIDGETS  =================

// Card consulta
Widget _cardConsulta({
  required BuildContext context, // precisa do context para navegar
  required String tipoConsulta,
  required String data,
  required String horario,
}) {
  DateTime dataParsed;

  try {
    dataParsed = DateTime.parse(data);
  } catch (_) {
    dataParsed = DateTime.now();
  }

  final dia = dataParsed.day.toString().padLeft(2, '0');
  final mesNumero = dataParsed.month;
  final ano = dataParsed.year.toString();
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

  String formatarHora(String hora) {
    try {
      final partes = hora.split(':');
      return '${partes[0].padLeft(2, '0')}:${partes[1].padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }

  String horarioFormatado = horario;
  if (horario.contains('-')) {
    final partes = horario.split('-');
    horarioFormatado =
        '${formatarHora(partes[0].trim())} - ${formatarHora(partes[1].trim())}';
  }

  return GestureDetector(
    onTap: () {
      context.go('/detalhes_consulta'); // aqui redireciona
    },
    child: Container(
      constraints: const BoxConstraints(minHeight: 70),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
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
              Text(
                dia,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(ano, style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consulta',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(tipoConsulta, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 2),
                Text(horarioFormatado, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Sem Consultas
class _SemConsultas extends StatelessWidget {
  const _SemConsultas();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.event_busy, size: 60, color: Colors.white),
          SizedBox(height: 12),
          Text(
            'Não tem consultas marcadas.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
