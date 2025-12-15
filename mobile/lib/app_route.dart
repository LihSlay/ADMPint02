import 'package:go_router/go_router.dart';
import 'definicoes_sobreconsultas/alteraridioma.dart';
import 'definicoes_sobreconsultas/definicoes.dart';
import 'definicoes_sobreconsultas/definicoesTermoseCondicoes.dart';
import 'definicoes_sobreconsultas/palavrapasse.dart';
import 'definicoes_sobreconsultas/sobreconsultas.dart';


final GoRouter rotas = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'definições',
      builder: (context, state) => const Definicoes(title: 'Apl. HomePage'),
    ),
    GoRoute(
      name: 'Alterar Idioma',
      path: '/idioma',
      builder: (context, state) => const Idioma(title: 'Apl. Route2'),
    ),
    GoRoute(
      name: 'Alterar Palavra-passe',
      path: '/palavra_passe',
      builder: (context, state) => const Palavrapasse(title: 'Apl. Route3'),
    ),
    GoRoute(
      name: 'Termos e condições',
      path: '/termos_condicoes',
      builder: (context, state) => const TermosCondicoes(title: 'Apl. Route3'),
    ),
    GoRoute(
      name: 'Sobre consultas',
      path: '/sobre_consultas',
      builder: (context, state) => const SobreConsultasPage(title: 'Apl. Route3'),
    ),
  ],
);
