import 'package:flutter/material.dart';

class _IdiomaCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _IdiomaCard({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Idioma extends StatelessWidget {
  final String title;
  const Idioma({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF907041), Color(0xFF97774D), Color(0xFFA68A69)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selecione o idioma",
              style: TextStyle(fontSize: 20, height: 1.45),
            ),
            const SizedBox(height: 20),

            // botão português com estilo do card
            _IdiomaCard(text: "Português", onTap: () {}),

            const SizedBox(height: 16),

            // botão inglês com estilo do card
            _IdiomaCard(text: "Inglês", onTap: () {}),
          ],
        ),
      ),
    );
  }
}
