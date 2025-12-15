import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Definicoes extends StatelessWidget {
  final String title;

  const Definicoes({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
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
            ),
          ),
        ),
      ),

      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Alterar Idioma"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.go('/idioma'),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.key),
            title: const Text("Alterar Palavra-passe"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.go('/palavra_passe'),
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text("Termos e Condições"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.go('/termos_condicoes'),
          ),
        ],
      ),
    );
  }
}
