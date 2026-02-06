import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/database/database_helper.dart';

class DadosPessoaisResponsavel extends StatefulWidget {
  final String title;
  final int idPerfil;

  const DadosPessoaisResponsavel({
    super.key,
    required this.title,
    required this.idPerfil,
  });

  @override
  State<DadosPessoaisResponsavel> createState() =>
      _DadosPessoaisResponsavelState();
}

class _DadosPessoaisResponsavelState
    extends State<DadosPessoaisResponsavel> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Map<String, dynamic>? perfil;
  List<Map<String, dynamic>> dependentes = [];

  bool carregado = false;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final db = await _dbHelper.database;

    final perfis = await db.query(
      'perfis',
      where: 'id_perfis = ?',
      whereArgs: [widget.idPerfil],
      limit: 1,
    );

    if (perfis.isEmpty) {
      if (!mounted) return;
      setState(() => carregado = true);
      return;
    }

    perfil = perfis.first;

    // 🔹 DEPENDENTES DO RESPONSÁVEL
    dependentes = await db.query(
      'perfis',
      where: 'responsavel = ?',
      whereArgs: [widget.idPerfil.toString()],
    );

    if (!mounted) return;
    setState(() => carregado = true);
  }

  Widget _campo(String titulo, String? valor) {
    if (valor == null || valor.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(valor),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ---------------- APPBAR ----------------
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
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
      ),

      // ---------------- BODY ----------------
      body: !carregado
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------- COLUNA ESQUERDA --------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _campo("Nome", perfil!['nome']),
                          _campo(
                            "Nº de utente",
                            perfil!['n_utente']?.toString(),
                          ),
                          _campo(
                            "Data de nascimento",
                            perfil!['data_nasc'],
                          ),
                          _campo("NIF", perfil!['nif']),
                          _campo("Profissão", perfil!['profissao']),
                        ],
                      ),
                    ),

                    const SizedBox(width: 30),

                    // -------- COLUNA DIREITA --------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _campo("Morada", perfil!['morada']),
                          _campo(
                            "Contacto telefónico",
                            perfil!['contacto_tel'],
                          ),

                          if (dependentes.isNotEmpty) ...[
                            const Divider(height: 30),
                            const Text(
                              "Dependentes",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            ...dependentes.map(
                              (d) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Text("• ${d['nome']}"),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

      // ================= BARRA NAVEGAÇÃO =================
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
