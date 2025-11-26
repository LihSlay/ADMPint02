import 'package:flutter/material.dart';
import 'botoesdefinicoes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinimolelos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Definicoes(title: 'Definições'),
      debugShowCheckedModeBanner: false,
    );
  }
}

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
              Color(0xFFA68A69),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),

    // botões da página
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SettingsButton(
            icon: Icons.language,
            label: "Alterar Idioma",
            onTap: () {},
          ),
          SettingsButton(
            icon: Icons.key,
            label: "Alterar Palavra-passe",
            onTap: () {},
          ),
          SettingsButton(
            icon: Icons.shield_outlined,
            label: "Termos e Condições",
            onTap: () {},
          ),
        ],
      ),
    ),
  );
}
}

