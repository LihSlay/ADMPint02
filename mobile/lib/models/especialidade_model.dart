class Especialidade {
  final int idEspecialidades;
  final String designacao;

  Especialidade({
    required this.idEspecialidades,
    required this.designacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_especialidades': idEspecialidades,
      'designacao': designacao,
    };
  }

  factory Especialidade.fromMap(Map<String, dynamic> map) {
    return Especialidade(
      idEspecialidades: map['id_especialidades'],
      designacao: map['designacao'],
    );
  }
}
