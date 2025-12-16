import 'package:go_router/go_router.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/dadospessoais_dependente.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/dadospessoais_responsavel.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/notificacoes.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/perfil_com_dependentes.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/perfil_dependente.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/perfil_sem_dependentes.dart';
import 'definicoes_sobreconsultas/alteraridioma.dart';
import 'definicoes_sobreconsultas/definicoes.dart';
import 'definicoes_sobreconsultas/definicoesTermoseCondicoes.dart';
import 'definicoes_sobreconsultas/palavrapasse.dart';
import 'definicoes_sobreconsultas/sobreconsultas.dart';
import 'package:mobile/inicio_calendario/inicio.dart';
import 'package:mobile/inicio_calendario/calendario.dart';
import 'package:mobile/download_documentos/exames_clinicos.dart';
import 'package:mobile/download_documentos/historico_declaracoes.dart';
import 'package:mobile/download_documentos/plano_tratamento.dart';


final GoRouter rotas = GoRouter(
  initialLocation: '/plano_tratamento',  //TESTAR MAIN
  routes: [
            GoRoute(
      path: '/',
      name: 'login',
      builder: (context, state) => const Definicoes(title: 'Login'),
    ),
        GoRoute(
      path: '/definicoes',
      name: 'definicoes',
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
      builder: (context, state) =>
          const SobreConsultasPage(title: 'Apl. Route3'),
    ),
    GoRoute(
      name: 'inicio',
      path: '/inicio',
      builder: (context, state) => const Inicio(),
    ),
    GoRoute(
      name: 'calendario',
      path: '/calendario',
      builder: (context, state) => const Calendario(title: 'Calendário'),
    ),

    GoRoute(
      name: 'perfilcomdependentes',
      path: '/perfilcomdependentes',
      builder: (context, state) => const PerfilComDep(title: 'PerfilComDep'),
    ),
    GoRoute(
      name: 'perfildependente',
      path: '/perfildependente',
      builder: (context, state) => const PerfilDependente(title: 'PerfilDependente'),
    ),
    GoRoute(
      name: 'perfilsemdependentes',
      path: '/perfilsemdependentes',
      builder: (context, state) => const PerfilSemDependentes(title: 'PerfilSemDependentes'),
    ),
    GoRoute(
      name: 'dadosdependente',
      path: '/dadosdependente',
      builder: (context, state) => const Dadospessoais_Dependente(title: 'Dadospessoais_Dependente'),
    ),
    GoRoute(
      name: 'dadosresponsavel',
      path: '/dadosresponsavel',
      builder: (context, state) => const DadosPessoaisResponsavel(title: 'Dadospessoais_Responsavel'),
    ),
     GoRoute(
      name: 'notificacoes',
      path: '/notificacoes',
      builder: (context, state) => const NotificacoesDados(title: 'Notificações'),
    ),

     GoRoute(
      name: 'exames_clinicos',
      path: '/exames_clinicos',
      builder: (context, state) => const ExamesClinicos(title: 'Exames_Clínicos'),
    ),

     GoRoute(
      name: 'historico_declaracoes',
      path: '/historico_declaracoes',
      builder: (context, state) => const HistoricoDeclaracoes(title: 'Historico_Declarações'),
    ),

    GoRoute(
      name: 'plano_tratamento',
      path: '/plano_tratamento',
      builder: (context, state) => const PlanoTratamento(title: 'Plano_Tratamento'),
    ),
  ],
);
