class Medico {
  final int idMedicos;
  final int? idUtilizadores;
  final String nomeMed;
  final int? nOmd;
  final int? idEspecialidades;
  final String? alcunha;
  final int? idTipoUtilizadores;

  Medico({
    required this.idMedicos,
    this.idUtilizadores,
    required this.nomeMed,
    this.nOmd,
    this.idEspecialidades,
    this.alcunha,
    this.idTipoUtilizadores,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_medicos': idMedicos,
      'id_utilizadores': idUtilizadores,
      'nome_med': nomeMed,
      'n_omd': nOmd,
      'id_especialidades': idEspecialidades,
      'alcunha': alcunha,
      'id_tipo_utilizadores': idTipoUtilizadores,
    };
  }

  factory Medico.fromMap(Map<String, dynamic> map) {
    return Medico(
      idMedicos: map['id_medicos'],
      idUtilizadores: map['id_utilizadores'],
      nomeMed: map['nome_med'] ?? '',
      nOmd: map['n_omd'],
      idEspecialidades: map['id_especialidades'],
      alcunha: map['alcunha'],
      idTipoUtilizadores: map['id_tipo_utilizadores'],
    );
  }
}
