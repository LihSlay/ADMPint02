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
  String? _emailUsuario;
  static const Map<int, String> _subsistemasMap = {
    1: 'SNS',
    2: 'Medis',
    3: 'Outra',
  };
  String? _generoTexto;
  String? _estadoCivilTexto;
  String? _subsistemaTexto;

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

    // obter email do utilizador associado (se existir)
    try {
      final utilizadorId = perfil!['id_utilizadores'];
      if (utilizadorId != null) {
        final usuarios = await db.query(
          'utilizadores',
          where: 'id_utilizadores = ?',
          whereArgs: [utilizadorId],
          limit: 1,
        );
        if (usuarios.isNotEmpty) {
          _emailUsuario = usuarios.first['email'] as String?;
        }
      }
    } catch (_) {
      _emailUsuario = null;
    }

    // 🔹 DEPENDENTES DO RESPONSÁVEL
    dependentes = await db.query(
      'perfis',
      where: 'responsavel = ?',
      whereArgs: [widget.idPerfil.toString()],
    );

    // tentar obter designações de genero / estado civil das respetivas tabelas locais
    try {
      final generoId = perfil!['id_genero'];
      if (generoId != null) {
        final g = await db.query('generos', where: 'id_generos = ?', whereArgs: [generoId], limit: 1);
        if (g.isNotEmpty) _generoTexto = g.first['designacao'] as String?;
      }
    } catch (_) {
      _generoTexto = null;
    }
    try {
      final estadoId = perfil!['id_estado_civil'];
      if (estadoId != null) {
        final e = await db.query('estados_civis', where: 'id_estados_civis = ?', whereArgs: [estadoId], limit: 1);
        if (e.isNotEmpty) _estadoCivilTexto = e.first['designacao'] as String?;
      }
    } catch (_) {
      _estadoCivilTexto = null;
    }

    // tentar obter designação do subsistema de saúde
    try {
      final subsId = perfil!['id_subsistemas_saude'];
      if (subsId != null) {
        final s = await db.query('subsistemas_saude', where: 'id_subsistemas_saude = ?', whereArgs: [subsId], limit: 1);
        if (s.isNotEmpty) _subsistemaTexto = s.first['designacao'] as String?;
      }
    } catch (_) {
      _subsistemaTexto = null;
    }

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
    Widget? _subsistemaWidget = _subsistemaTexto != null && _subsistemaTexto!.isNotEmpty ? _campo('Subsistema de Saúde', _subsistemaTexto) : null;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _campo('Nome completo', perfil!['nome']),
                    _campo('Nº Utente', perfil!['n_utente']?.toString()),
                    _campo('Data de Nascimento', perfil!['data_nasc']),
                    _campo('Estado Civil', _estadoCivilTexto),
                    _campo('Género', _generoTexto),
                    _campo('Profissão', perfil!['profissao']),
                    _campo('NIF', perfil!['nif']?.toString()),
                    _campo('Telefone', perfil!['contacto_tel']?.toString()),
                    _campo('Endereço', perfil!['morada']),
                    _campo('Código Postal', perfil!['cod_postal']?.toString()),
                    // Subsistema: mostrar nome se conhecido
                    if (_subsistemaWidget != null) _subsistemaWidget,
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
