import 'package:go_router/go_router.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/dadospessoais_responsavel.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/notificacoes.dart';
import 'package:mobile/dadospessoais_notificacoes_perfil/perfil_sem_dependentes.dart';
import 'definicoes_sobreconsultas/definicoes.dart';
import 'definicoes_sobreconsultas/definicoesTermoseCondicoes.dart';
import 'definicoes_sobreconsultas/palavrapasse.dart';
import 'definicoes_sobreconsultas/sobreconsultas.dart';
import 'definicoes_sobreconsultas/detalhes_consulta.dart';
import 'package:mobile/inicio_calendario/inicio.dart';
import 'package:mobile/inicio_calendario/calendario.dart';
import 'package:mobile/download_documentos/exames_clinicos.dart';
import 'package:mobile/download_documentos/historico_declaracoes.dart';
import 'package:mobile/download_documentos/plano_tratamento.dart';
import 'package:mobile/login/login.dart';
import 'package:mobile/login/IniciarSessaoPage.dart';
import 'package:mobile/login/EsqueceuPasseEmailPage.dart';
import 'package:mobile/login/EsqueceuPasse.dart';
import 'package:mobile/login/TermosCondicoesPage.dart';
import 'package:mobile/login/AlterarPassePage.dart';
import 'package:mobile/services/api_service.dart';

final ApiService _apiService = ApiService();

Future<String> verificarRotaInicial(int idPerfis) async {
  if (await _apiService.verificarConsentimentoLocal(idPerfis)) {
    return '/inicio';
  }
  return '/termos_condicoes_login';
}

final GoRouter rotas = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/iniciar_sessao',
      name: 'iniciar_sessao',
      builder: (context, state) => const IniciarSessaoPage(),
    ),
    GoRoute(
      path: '/esqueceu_email',
      name: 'esqueceu_email',
      builder: (context, state) => const EsqueceuPasseEmailPage(),
    ),
    GoRoute(
      path: '/recuperar_codigo',
      name: 'recuperar_codigo',
      builder: (context, state) {
        final email = state.extra as String? ?? "";
        return EsqueceuPassePage(email: email);
      },
    ),
    GoRoute(
      path: '/termos_condicoes_login',
      name: 'termos_condicoes_login',
      builder: (context, state) {
        final idPerfis = state.extra as int?;
        return TermosCondicoesPage(idPerfis: idPerfis);
      },
    ),
    GoRoute(
      path: '/alterar_passe_recuperacao',
      name: 'alterar_passe_recuperacao',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return AlterarPassePage(
          email: data?['email'] ?? "",
          code: data?['code'] ?? "",
        );
      },
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const Inicio(),
    ),
    GoRoute(
      path: '/definicoes',
      name: 'definicoes',
      builder: (context, state) => const Definicoes(title: 'Definições'),
    ),
    GoRoute(
      name: 'Alterar Palavra-passe',
      path: '/palavra_passe',
      builder: (context, state) =>
          const Palavrapasse(title: 'Alterar Palavra-passe'),
    ),
    GoRoute(
      name: 'Termos e condições',
      path: '/termos_condicoes',
      builder: (context, state) =>
          const TermosCondicoes(title: 'Termos e Condições'),
    ),
    GoRoute(
      name: 'Sobre consultas',
      path: '/sobre_consultas',
      builder: (context, state) =>
          const SobreConsultasPage(title: 'Sobre ConsultasS'),
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
      name: 'perfilsemdependentes',
      path: '/perfilsemdependentes',
      builder: (context, state) =>
          const PerfilSemDependentes(title: 'PerfilSemDependentes'),
    ),
    
    //Dados pessoais do responsável e dependentes associados
    GoRoute(
      name: 'dadosresponsavel',
      path: '/dadosresponsavel',
      builder: (context, state) {
        final int idPerfil = state.extra as int;

        return DadosPessoaisResponsavel(
          title: 'Dados pessoais',
          idPerfil: idPerfil,
        );
      },
    ),

    GoRoute(
      name: 'notificacoes',
      path: '/notificacoes',
      builder: (context, state) =>
          const NotificacoesDados(title: 'Notificações'),
    ),

    GoRoute(
      name: 'exames_clinicos',
      path: '/exames_clinicos',
      builder: (context, state) =>
          const ExamesClinicos(title: 'Exames_Clínicos'),
    ),

    GoRoute(
      name: 'historico_declaracoes',
      path: '/historico_declaracoes',
      builder: (context, state) =>
          const HistoricoDeclaracoes(title: 'Historico_Declarações'),
    ),

    GoRoute(
      name: 'plano_tratamento',
      path: '/plano_tratamento',
      builder: (context, state) =>
          const PlanoTratamentoPage(title: 'Plano_Tratamento'),
    ),
    GoRoute(
      path: '/logininicio',
      name: 'logininicio',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/detalhes_consulta',
      name: 'detalhes_consulta',
      builder: (context, state) => const DetalhesConsulta(),
    ),
  ],
);
