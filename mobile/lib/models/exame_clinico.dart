class ExameClinico {
  final int idExamesClinicos;
  final String? tipoExame;
  final String? medicoNome;
  final String? dataConsulta;
  final String? ficheiroUrl;
  final String? nomeFicheiro;
  final String dataUpload;
  final int idPerfis;

  ExameClinico({
    required this.idExamesClinicos,
    this.tipoExame,
    this.medicoNome,
    this.dataConsulta,
    this.ficheiroUrl,
    this.nomeFicheiro,
    required this.dataUpload,
    required this.idPerfis,
  });

  factory ExameClinico.fromMap(Map<String, dynamic> map) {
    final utilizador = map['Utilizadore'] as Map<String, dynamic>?;
    final medico = utilizador?['Medico'] as Map<String, dynamic>?;

    return ExameClinico(
      idExamesClinicos: map['id_exames_clinicos'],
      tipoExame: map['tipo_exame'],
      medicoNome: medico?['nome_med'],
      dataConsulta: map['data_consulta'],
      ficheiroUrl: map['ficheiro_url'],
      nomeFicheiro: map['nome_ficheiro'],
      dataUpload: map['data_upload'],
      idPerfis: map['id_perfis'],
    );
  }
}
