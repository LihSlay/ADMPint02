import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/database/database_helper.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/dadospessoais_responsavel.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/perfil_dependente.dart';

class PerfilComDep extends StatefulWidget {
  const PerfilComDep({super.key, required this.title});
  final String title;

  @override
  State<PerfilComDep> createState() => _PerfilComDepState();
}

class _PerfilComDepState extends State<PerfilComDep> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // ------------------- DADOS DO PACIENTE -------------------
  int? idPaciente;
  String nomePaciente = '';
  int? numeroUtente;

  // ------------------- LISTA DE DEPENDENTES -------------------
  List<Map<String, dynamic>> dependentes = [];

  @override
  void initState() {
    super.initState();
    _carregarDadosDaBase();
  }

  // ------------------- CARREGAR DADOS DA SQLITE -------------------
  Future<void> _carregarDadosDaBase() async {
    final db = await _dbHelper.database;

    // Perfil principal (responsável)
    final perfisPrincipais = await db.query(
      'perfis',
      where: 'responsavel IS NULL OR responsavel = ""',
      limit: 1,
    );

    if (perfisPrincipais.isEmpty) return;

    final paciente = perfisPrincipais.first;

    idPaciente = paciente['id_perfis'] as int?;
    nomePaciente = paciente['nome'] as String? ?? '';
    numeroUtente = paciente['n_utente'] as int?;

    // Dependentes
    final deps = await db.query(
      'perfis',
      where: 'responsavel = ?',
      whereArgs: [idPaciente.toString()],
    );

    dependentes = deps;

    if (mounted) setState(() {});
  }

  // ------------------- GERAR INICIAIS -------------------
  String _iniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) {
      return partes[0][0] + partes[1][0];
    }
    return nome.isNotEmpty ? nome[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ------------------- APPBAR -------------------
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180),
        child: Container(
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
          child: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),

                // Avatar responsável
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _iniciais(nomePaciente),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Nome + Nº utente
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nomePaciente.isNotEmpty ? nomePaciente : '—',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      numeroUtente != null
                          ? 'Nº de utente: $numeroUtente'
                          : '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      // ------------------- BODY -------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsCard(
              icon: Icons.person_outline,
              label: "Dados pessoais",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DadosPessoaisResponsavel(
                      title: 'Dadospessoais_Responsavel',
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

            const SizedBox(height: 25),

            const Text(
              "Dependentes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),

            // ------------------- DEPENDENTES COM BOLINHA -------------------
            dependentes.isEmpty
                ? const Text(
                    "Sem dependentes associados",
                    style: TextStyle(color: Colors.black54),
                  )
                : Column(
                    children: dependentes.map((dep) {
                      final nome = dep['nome'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PerfilDependente(title: nome),
                              ),
                            );
                          },
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
                                    _iniciais(nome),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(nome, style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 40),

            // ------------------- LOGOUT -------------------
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

                  if (!mounted) return;
                  context.go('/login');
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  "Terminar Sessão",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- SETTINGS CARD -------------------
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
