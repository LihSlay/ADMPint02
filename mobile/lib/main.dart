import 'package:flutter/material.dart';
import 'login.dart';
import 'IniciarSessaoPage.dart';
import 'EsqueceuPasseEmailPage.dart';
import 'EsqueceuPasse.dart';
import 'AlterarPassePage.dart';
import 'TermosCondicoesPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinimolelos',
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/iniciar_sessao': (context) => const IniciarSessaoPage(),
        '/esqueceu_email': (context) => const EsqueceuPasseEmailPage(),
        '/esqueceu_codigo': (context) => const EsqueceuPassePage(),
        '/alterar_passe': (context) => const AlterarPassePage(),
        '/termos_condicoes': (context) => const TermosCondicoesPage(),
      },
    );
  }
}
