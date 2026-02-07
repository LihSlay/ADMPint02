import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/database/database_helper.dart';
import 'package:mobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/dadospessoais_responsavel.dart';

class PerfilSemDependentes extends StatefulWidget {
  const PerfilSemDependentes({super.key, required this.title});
  final String title;

  @override
  State<PerfilSemDependentes> createState() => _PerfilSemDependentesState();
}

class _PerfilSemDependentesState extends State<PerfilSemDependentes> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  int? idPaciente;
  String nomePaciente = '';
  int? numeroUtente;
  int? idGenero;
  int? idEstadoCivil;
  int? _idPerfilAtivo;

  List<Map<String, dynamic>> dependentes = [];
  bool carregado = false;

  // Adicionado para dropdowns
  List<Map<String, dynamic>> generos = [];
  List<Map<String, dynamic>> estadosCivis = [];

  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _carregarDadosDaBase();
    _carregarDropdowns(); // Novo: carregar opções de género e estado civil
  }

  // Novo: Carregar opções de dropdowns via API
  Future<void> _carregarDropdowns() async {
    try {
      final api = ApiService();
      final genRes = await api.getGeneros(); // Assumindo que há métodos no ApiService
      final estRes = await api.getEstadosCivis();
      if (mounted) {
        setState(() {
          generos = genRes;
          estadosCivis = estRes ;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar dropdowns: $e');
    }
  }

  // ------------------- CARREGAR PERFIL + DEPENDENTES -------------------
  Future<void> _carregarDadosDaBase() async {
    final db = await _dbHelper.database;

    // 🔹 UTILIZADOR LOGADO
    final user = await db.query('utilizadores', limit: 1);
    if (user.isEmpty) {
      if (mounted) setState(() => carregado = true);
      return;
    }

    final idUtilizador = user.first['id_utilizadores'];

    // 🔹 PERFIL PRINCIPAL DO UTILIZADOR
    final perfisPrincipais = await db.query(
      'perfis',
      where: 'id_utilizadores = ?',
      whereArgs: [idUtilizador],
      limit: 1,
    );

    if (perfisPrincipais.isEmpty) {
      if (mounted) setState(() => carregado = true);
      return;
    }

    final paciente = perfisPrincipais.first;

    idPaciente = paciente['id_perfis'] as int?;

    // Determinar qual o perfil activo (pode ser o principal ou um dependente)
    final prefs = await SharedPreferences.getInstance();
    _idPerfilAtivo = prefs.getInt('id_perfis');

    // Se existe um perfil activo e é diferente do principal, carregamos esse
    if (_idPerfilAtivo != null && _idPerfilAtivo != idPaciente) {
      final ativo = await db.query(
        'perfis',
        where: 'id_perfis = ?',
        whereArgs: [_idPerfilAtivo],
        limit: 1,
      );
      if (ativo.isNotEmpty) {
        final dep = ativo.first;
        nomePaciente = dep['nome'] as String? ?? '';
        numeroUtente = dep['n_utente'] as int?;
        idGenero = dep['id_generos'] as int?;
        idEstadoCivil = dep['id_estados_civis'] as int?;
      } else {
        // fallback para o paciente principal
        nomePaciente = paciente['nome'] as String? ?? '';
        numeroUtente = paciente['n_utente'] as int?;
        idGenero = paciente['id_generos'] as int?;
        idEstadoCivil = paciente['id_estados_civis'] as int?;
        _idPerfilAtivo = idPaciente;
        await prefs.setInt('id_perfis', idPaciente!);
      }
    } else {
      // Sem perfil activo definido ou é o principal → usar dados do paciente principal
      nomePaciente = paciente['nome'] as String? ?? '';
      numeroUtente = paciente['n_utente'] as int?;
      idGenero = paciente['id_generos'] as int?;
      idEstadoCivil = paciente['id_estados_civis'] as int?;
      _idPerfilAtivo = idPaciente;
      await prefs.setInt('id_perfis', idPaciente!);
    }
    // 🔹 DEPENDENTES
    // Primeiro tentamos sincronizar com o backend (se houver internet)
    // para garantir que a BD local tem os dependentes mais recentes.
    if (idPaciente == null) {
      if (mounted) setState(() => carregado = true);
      return;
    }

    try {
      final api = ApiService();
      await api.fetchAndSaveDependentes(idPaciente!);
    } catch (e) {
      debugPrint('Erro ao sincronizar dependentes: $e');
      // ignorar e continuar a ler localmente
    }

    // Depois de tentar sincronizar, lemos os dependentes da BD local
    // Só mostrar a lista de dependentes quando estivermos a ver o perfil principal
    if (_idPerfilAtivo == idPaciente) {
      dependentes = await db.query(
        'perfis',
        where: 'responsavel = ? OR responsavel = ?',
        whereArgs: [idPaciente.toString(), idPaciente],
      );
    } else {
      dependentes = [];
    }

    // 🧪 DEBUG
    debugPrint('================ PERFIL DEBUG ================');
    debugPrint('ID UTILIZADOR: $idUtilizador');
    debugPrint('ID PACIENTE: $idPaciente');
    debugPrint('DEPENDENTES (${dependentes.length}):');
    for (final d in dependentes) {
      debugPrint('→ ${d['nome']} | responsavel=${d['responsavel']}');
    }
    debugPrint('==============================================');

    // Se nenhum dependente for encontrado, deixamos logs para ajudar no
    // debugging (úteis para testes em dispositivos específicos).
    if (dependentes.isEmpty) {
      debugPrint('Nenhum dependente encontrado para responsavel=$idPaciente');
    }

    if (mounted) setState(() => carregado = true);
  }

  // ------------------- INICIAIS -------------------
  String _iniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) {
      return partes[0][0] + partes[1][0];
    }
    return nome.isNotEmpty ? nome[0] : '';
  }

  // Novo: Função auxiliar para obter designação por ID
  String _getDesignacao(List<Map<String, dynamic>> lista, int? id, String keyId, String keyDesignacao) {
    if (id == null || lista.isEmpty) return 'N/A';
    final item = lista.firstWhere(
      (item) => item[keyId] == id,
      orElse: () => {},
    );
    return item[keyDesignacao] ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ------------------- APPBAR -------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140), // reduzido para tamanho mais compacto
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF907041),
                Color(0xFF97774D),
                Color(0xFFA68A69),
              ],
            ),
          ),
          child: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go('/inicio'),
                ),
                const SizedBox(width: 8),
                const SizedBox(width: 12),
                _Avatar(texto: _iniciais(nomePaciente)),
                const SizedBox(width: 16),
                Expanded( // Adicionado para evitar overflow
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nomePaciente,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (numeroUtente != null)
                        Text(
                          'Nº de utente: $numeroUtente',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      // Novo: Mostrar género e estado civil
                      if (idGenero != null)
                        Text(
                          'Género: ${_getDesignacao(generos, idGenero, 'id_generos', 'designacao')}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      if (idEstadoCivil != null)
                        Text(
                          'Estado Civil: ${_getDesignacao(estadosCivis, idEstadoCivil, 'id_estados_civis', 'designacao')}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ------------------- BODY -------------------
      body: !carregado
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsCard(
                    icon: Icons.person_outline,
                    label: "Dados pessoais",
                    onTap: () {
                        final alvo = _idPerfilAtivo ?? idPaciente!;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DadosPessoaisResponsavel(
                              title: 'Dados pessoais',
                              idPerfil: alvo,
                            ),
                          ),
                        );
                    },
                  ),

                  const SizedBox(height: 12),

                  SettingsCard(
                    icon: Icons.settings_outlined,
                    label: "Definições",
                    onTap: () => context.go('/definicoes'),
                  ),

                  const SizedBox(height: 30),

                  // Only show "Dependentes" title if viewing main profile
                  if (_idPerfilAtivo == idPaciente)
                    const Text(
                      "Dependentes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  const SizedBox(height: 15),

                  // Se estivermos a ver um dependente, mostrar botão para voltar à conta principal
                  if (_idPerfilAtivo != null && _idPerfilAtivo != idPaciente)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            // voltar ao paciente principal
                            await prefs.setInt('id_perfis', idPaciente!);
                            await prefs.remove('id_perfis_prev');
                            // recarregar dados desta página
                            await _carregarDadosDaBase();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Voltado à conta principal')),
                              );
                            }
                          },
                          icon: const Icon(Icons.undo),
                          label: const Text('Voltar à conta principal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF907041),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Lista de dependentes apenas se estivermos a ver o perfil principal
                  if (_idPerfilAtivo == idPaciente)
                    dependentes.isEmpty
                        ? const Text(
                            "Sem dependentes associados",
                            style: TextStyle(color: Colors.black54),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: dependentes.map((dep) {
                              final nomeDependente = dep['nome'] as String? ?? '';
                              final idDep = dep['id_perfis'] as int?;

                              return InkWell(
                                onTap: idDep == null
                                    ? null
                                    : () async {
                                        // Guardar id atual como prev
                                        final prefs = await SharedPreferences.getInstance();
                                        final current = prefs.getInt('id_perfis');
                                        if (current != null) {
                                          await prefs.setInt('id_perfis_prev', current);
                                        }
                                        await prefs.setInt('id_perfis', idDep);

                                        // Navigate to initial page directly
                                        context.go('/inicio');
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 70,
                                        height: 70,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            _iniciais(nomeDependente).toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        nomeDependente,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                  const SizedBox(height: 40),

                  // ---------------- LOGOUT ----------------
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF907041),
                          Color(0xFF97774D),
                          Color(0xFFA68A69),
                        ],
                      ),
                    ),
                    child: TextButton.icon(
                      onPressed: () async {
                        final db = await _dbHelper.database;
                        await db.delete('utilizadores');
                        await db.delete('perfis');

                        if (!context.mounted) return;
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Terminar Sessão",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
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

// ------------------- AVATAR -------------------
class _Avatar extends StatelessWidget {
  final String texto;

  const _Avatar({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          texto.toUpperCase(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ------------------- CARD -------------------
class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.brown.shade800),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.brown.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}