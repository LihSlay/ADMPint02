import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/database/database_helper.dart';
import 'package:mobile/models/notificacao_model.dart';
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificacoesDados extends StatefulWidget {
  final String title;
  const NotificacoesDados({super.key, required this.title});

  @override
  State<NotificacoesDados> createState() => _NotificacoesDadosState();
}

class _NotificacoesDadosState extends State<NotificacoesDados> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ApiService _apiService = ApiService();

  int currentPageIndex = 2;
  bool carregado = false;

  List<NotificacaoModel> notificacoes = [];

  @override
  void initState() {
    super.initState();
    _sincronizarECarregar();
  }

  // -------- SINCRONIZAR API -> SQLITE -> UI --------
  Future<void> _sincronizarECarregar() async {
    try {
      await _apiService.fetchAndSaveNotificacoes();
    } catch (_) {
      // offline-first → ignora
    }
    await _carregarNotificacoes();
  }

  // ---------------- CARREGAR NOTIFICAÇÕES ----------------
  Future<void> _carregarNotificacoes() async {
    final db = await _dbHelper.database;

    // Filtrar notificações pelo perfil ativo
    final prefs = await SharedPreferences.getInstance();
    final int? idPerfisAtivo = prefs.getInt('id_perfis');

    final result = await db.query(
      'notificacoes',
      where: idPerfisAtivo != null ? 'id_perfis = ?' : null,
      whereArgs: idPerfisAtivo != null ? [idPerfisAtivo] : null,
      orderBy: 'id_notificacoes DESC',
    );

    notificacoes = result.map((n) => NotificacaoModel.fromMap(n)).toList();

    if (mounted) setState(() => carregado = true);
  }

  // ---------------- MARCAR UMA COMO LIDA ----------------
  Future<void> _marcarComoLida(NotificacaoModel notificacao) async {
    if (notificacao.lida == 1 || notificacao.idNotificacoes == null) return;

    // UI imediata (evita "ressuscitar")
    setState(() {
      notificacoes = notificacoes.map((n) {
        if (n.idNotificacoes == notificacao.idNotificacoes) {
          return NotificacaoModel(
            id: n.id,
            idNotificacoes: n.idNotificacoes,
            designacao: n.designacao,
            descricao: n.descricao,
            lida: 1,
          );
        }
        return n;
      }).toList();
    });

    // LOCAL + BACKEND (fire & forget)
    _apiService.marcarNotificacoesComoLidas(
      idNotificacao: notificacao.idNotificacoes,
    );
  }

  // ---------------- MARCAR TODAS COMO LIDAS ----------------
  Future<void> _marcarTodasComoLidas() async {
    // UI imediata
    setState(() {
      notificacoes = notificacoes.map((n) {
        return NotificacaoModel(
          id: n.id,
          idNotificacoes: n.idNotificacoes,
          designacao: n.designacao,
          descricao: n.descricao,
          lida: 1,
        );
      }).toList();
    });

    // LOCAL + BACKEND (fire & forget)
    _apiService.marcarNotificacoesComoLidas();
  }

  // ---------------- ROTA POR DESIGNAÇÃO ----------------
  String _rotaPorDesignacao(String designacao) {
    final d = designacao.toLowerCase();

    if (d.contains('consulta')) return '/calendario';
    if (d.contains('plano')) return '/sobre_consultas';
    if (d.contains('exame')) return '/perfildependente';

    return '/inicio';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      // ---------------- APPBAR (CORRIGIDA) ----------------
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text(
          "Notificações",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF907041),
                Color(0xFF97774D),
                Color(0xFFA68A69),
              ],
            ),
          ),
        ),
      ),

      // ---------------- BODY ----------------
      body: !carregado
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (notificacoes.any((n) => n.lida == 0))
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _marcarTodasComoLidas,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF907041),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Marcar todas como lidas",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                Expanded(
                  child: notificacoes.isEmpty
                      ? const Center(
                          child: Text(
                            "Sem notificações",
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: notificacoes.length,
                          itemBuilder: (context, index) {
                            final n = notificacoes[index];

                            return _NotificacaoCard(
                              notificacao: n,
                              onTap: () {
                                _marcarComoLida(n);
                                context.go(
                                  _rotaPorDesignacao(n.designacao),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),

      // ---------------- NAVBAR ----------------
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
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

// ---------------- CARD DE NOTIFICAÇÃO ----------------
class _NotificacaoCard extends StatelessWidget {
  final NotificacaoModel notificacao;
  final VoidCallback onTap;

  const _NotificacaoCard({
    required this.notificacao,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool lida = notificacao.lida == 1;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lida ? Colors.white : const Color(0xFFFFF8EF),
          borderRadius: BorderRadius.circular(14),
          border: Border(
            left: BorderSide(
              width: 4,
              color:
                  lida ? Colors.grey.shade300 : const Color(0xFF907041),
            ),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              lida ? Icons.notifications_none : Icons.notifications,
              color: Colors.brown.shade700,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notificacao.designacao,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          lida ? FontWeight.w500 : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notificacao.descricao,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (!lida)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF907041),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "NOVA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
