import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ignore: camel_case_types
class Dadospessoais_Dependente extends StatefulWidget {
  final String title;
  const Dadospessoais_Dependente({super.key, required this.title});

  @override
  State<Dadospessoais_Dependente> createState() =>
      dadospessoais_dependenteState();
}

// ignore: camel_case_types
class dadospessoais_dependenteState extends State<Dadospessoais_Dependente> {
  int currentPageIndex = 0;

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
              colors: [Color(0xFF907041), Color(0xFF97774D), Color(0xFFA68A69)],
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
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nome", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("Paula Manuel Pereira"),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Nº de utente:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("7345868879"),
                        SizedBox(height: 20),
                        Text(
                          "Género",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("Feminino"),
                        SizedBox(height: 20),
                        Text(
                          "NIF",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("257 136 892"),
                        SizedBox(height: 20),
                        Text(
                          "Subsistema de saúde",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("Multicare"),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Data de nascimento",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("10 Jun 2010"),
                        SizedBox(height: 20),
                        Text(
                          "Nacionalidade",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("Portuguesa"),
                        SizedBox(height: 20),
                        Text(
                          "Estado Civil",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("Solteira"),
                        SizedBox(height: 20),
                        Text(
                          "Profissão",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("Estudante"),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
              const Text(
                "Morada",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text("5400 – 221 Rua nova de Jugueiros nº21"),
              const SizedBox(height: 20),
              const Text(
                "Correio eletrónico",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text("AntMPereira@gmail.com"),
              const Text("paula.m.per@gmail.com"),
              const SizedBox(height: 20),
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

      // ------------------- BOTTOM NAVIGATION -------------------
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        indicatorColor: Colors.transparent,
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
