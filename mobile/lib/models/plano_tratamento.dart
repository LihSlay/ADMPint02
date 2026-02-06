import 'package:flutter/foundation.dart';

class PlanoTratamento {
  final int idPlanosTratamento;
  final String? nomePlano;
  final String? observacoes;
  final String? ficheiroUrl;
  final String? nomeFicheiro;
  final String dataCriacao;
  final String? dataFim;
  final int idPerfis;
  final int? idUtilizadores;
  final String? medicoNome;

  PlanoTratamento({
    required this.idPlanosTratamento,
    this.nomePlano,
    this.observacoes,
    this.ficheiroUrl,
    this.nomeFicheiro,
    required this.dataCriacao,
    this.dataFim,
    required this.idPerfis,
    this.idUtilizadores,
    this.medicoNome,
  });

  factory PlanoTratamento.fromMap(Map<String, dynamic> map) {
    debugPrint("🧩 MAP COMPLETO: $map");
    debugPrint("🧩 KEYS RAIZ: ${map.keys}");
    return PlanoTratamento(
      idPlanosTratamento: map['id_planos_tratamento'],
      nomePlano: map['nome_plano'],
      observacoes: map['observacoes'],
      ficheiroUrl: map['ficheiro_url'],
      nomeFicheiro: map['nome_ficheiro'],
      dataCriacao: map['data_criacao'],
      dataFim: map['data_fim'],
      idPerfis: map['id_perfis'],
      idUtilizadores: map['id_utilizadores'],
      medicoNome:
          map['Utilizadore'] != null && map['Utilizadore']['Medico'] != null
          ? map['Utilizadore']['Medico']['nome_med']
          : null,
    );
  }
}
