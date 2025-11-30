import 'package:flutter/material.dart';

// ignore: camel_case_types
class Dadospessoais_Dependente extends StatelessWidget {
  const Dadospessoais_Dependente({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ---------------- APPBAR COM GRADIENTE ----------------
      appBar: AppBar(
        title: const Text(
          "Dados pessoais",
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

      // ------------------- CONTEÚDO -------------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------- NOME (1 linha completa) -----------
              const Text(
                "Nome",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text("Paula Manuel Pereira"),
              const SizedBox(height: 20),

              // ----------- 2 COLUNAS -------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------- COLUNA ESQUERDA -------
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Nº de utente:",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("7345868879"),
                        SizedBox(height: 20),

                        Text("Género",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Feminino"),
                        SizedBox(height: 20),

                        Text("NIF",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("257 136 892"),
                        SizedBox(height: 20),

                        Text("Subsistema de saúde",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Multicare"),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // ------- COLUNA DIREITA -------
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Data de nascimento",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("10 Jun 2010"),
                        SizedBox(height: 20),

                        Text("Nacionalidade",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Portuguesa"),
                        SizedBox(height: 20),

                        Text("Estado Civil",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Solteira"),
                        SizedBox(height: 20),

                        Text("Profissão",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Estudante"),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),

              // -------------- Morada (linha completa) --------------
              const Text(
                "Morada",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text("5400 – 221 Rua nova de Jugueiros nº21"),
              const SizedBox(height: 20),

              // -------------- Email --------------
              const Text(
                "Correio eletrónico",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text("AntMPereira@gmail.com"),
              const Text("paula.m.per@gmail.com"),
              const SizedBox(height: 20),

              // -------------- Telefone --------------
              const Text(
                "Contacto telefónico",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text("257 136 892"),
              const Text("931 693 684"),
            ],
          ),
        ),
      ),
    );
  }
}
