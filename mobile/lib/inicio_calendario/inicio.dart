import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/inicio_calendario/calendario.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/notificacoes.dart';
import 'package:mobile/definicoes_sobreconsultas/definicoes.dart';
import 'package:mobile/database/database_helper.dart';
import 'package:mobile/models/perfil_model.dart';
import 'package:mobile/models/consulta_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  int currentPageIndex = 0; // Guarda página atual no navbar
  String nome = "";
  String nUtente = "";
  String alcunhas = "";

  final DatabaseHelper _dbHelper = DatabaseHelper(); // Acesso à bd local
  List<Consulta> consultas = [];
  bool _aCarregar = true; // Roda enquanto se espera

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
    _carregarConsultas();
  }

  // ================= CARREGAR DADOS PERFIL PACIENTE =================

  Future<void> _carregarPerfil() async {
    try {
      final db = await _dbHelper.database;
      // Ler id_perfis activo das SharedPreferences e carregar esse perfil
      final prefs = await SharedPreferences.getInstance();
      final idPerfil = prefs.getInt('id_perfis');
      List<Map<String, dynamic>> perfis;
      if (idPerfil != null) {
        perfis = await db.query(
          'perfis',
          where: 'id_perfis = ?',
          whereArgs: [idPerfil],
          limit: 1,
        );
      } else {
        perfis = await db.query('perfis', limit: 1);
      }

      if (perfis.isNotEmpty) {
        Perfil perfil = Perfil.fromMap(perfis.first);
        setState(() {
          nome = perfil.nome ?? "";
          nUtente = perfil.nUtente?.toString() ?? "";
          alcunhas = perfil.alcunhas ?? "";
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar perfil: $e");
    }
  }

  // ================= CARREGAR CONSULTAS PACIENTE  =================
  Future<void> _carregarConsultas() async {
    setState(() => _aCarregar = true);
    try {
      debugPrint("A carregar consultas locais para o perfil activo...");
      final db = await _dbHelper.database;
      final prefs = await SharedPreferences.getInstance();
      final idPerfil = prefs.getInt('id_perfis');

      List<Map<String, dynamic>> maps;
      if (idPerfil != null) {
        maps = await db.query(
          'consultas',
          where: 'id_perfis = ?',
          whereArgs: [idPerfil],
        );
      } else {
        maps = await db.query('consultas');
      }

      final list = maps.map((m) => Consulta.fromMap(m)).toList();
      debugPrint("Consultas locais encontradas: ${list.length}");
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
      appBar: currentPageIndex == 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: AppBar(
                backgroundColor: Colors.white,
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
                  // ================= MENU POP-UP =================
                  Padding(
                    padding: const EdgeInsets.only(right: 10, bottom: 5),
                    child: MenuAnchor(
                      style: MenuStyle(
                        backgroundColor: MaterialStateProperty.all(
                          Colors.white,
                        ), // fundo branco
                        elevation: MaterialStateProperty.all(4),
                      ),
                      builder: (context, controller, child) {
                        return GestureDetector(
                          onTap: () {
                            controller.isOpen
                                ? controller.close()
                                : controller.open();
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: alcunhas.isNotEmpty
                                ? Text(
                                    alcunhas,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                          ),
                        );
                      },
                      menuChildren: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MenuItemButton(
                              onPressed: () => context.go(
                                '/PerfilSemDependentes',
                              ), // redireciona para o perfil (restored)
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
                              onPressed: () async {
                                // Limpar token ou dados de sessão
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('token'); // remove o token

                                // Depois navega para a rota original
                                context.go('/login');
                              },
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 60,
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
              // ================= DASHBOARD PACIENTE  =================
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _cardDashboard(
                      nome: nome.isNotEmpty ? nome : "Carregando...",
                      nUtente: nUtente.isNotEmpty ? nUtente : "-",
                      clinica: "Clinimolelos",
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    // ================= BOTÕES =================
                    child: Botoes(),
                  ),
                  const SizedBox(height: 18),
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

                      // ================= CONSULTAS =================
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cabeçalho com título e número de consultas
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
                            // Lista das consultas
                            Expanded(
                              child: _aCarregar
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : consultas.isEmpty
                                  ? const _SemConsultas() // se não tiver consulta mostra isto
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
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
            ],
          ),
          const Calendario(title: ''),
          const NotificacoesDados(title: ''),
          const Definicoes(title: ''),
        ],
      ),

      // ================= BARRA NAVEGAÇÃO (botnavbar) =================
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
}

// ================= WIDGETS  =================

// Card dashboard
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
        Text(
          nome,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text('Nº Utente $nUtente', style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 6),
        const Text('Clínica Dentária', style: TextStyle(fontSize: 12)),
        Text(
          clinica,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

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

// Botões
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
