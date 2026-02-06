import 'documento_model.dart';

class Consulta {
  final int idConsultas;
  final String? dataConsulta;
  final String? horarioInicio;
  final String? horarioFim;
  final String? observacoes;
  final String estado;
  final int? idPerfis;
  final int? idMedicos;
  final int? idTipoMarcacao;
  final int? idTipoConsultas;
  // Campos auxiliares para visualização rápida no mobile
  final String? medicoNome;
  final String? especialidadeNome;
  final List<Documento> documentos;

  Consulta({
    required this.idConsultas,
    this.dataConsulta,
    this.horarioInicio,
    this.horarioFim,
    this.observacoes,
    required this.estado,
    this.idPerfis,
    this.idMedicos,
    this.idTipoMarcacao,
    this.idTipoConsultas,
    this.medicoNome,
    this.especialidadeNome,
    this.documentos = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id_consultas': idConsultas,
      'data_consulta': dataConsulta,
      'horario_inicio': horarioInicio,
      'horario_fim': horarioFim,
      'observacoes': observacoes,
      'estado': estado,
      'id_perfis': idPerfis,
      'id_medicos': idMedicos,
      'id_tipo_marcacao': idTipoMarcacao,
      'id_tipo_consultas': idTipoConsultas,
      'medico_nome': medicoNome,
      'especialidade_nome': especialidadeNome,
    };
  }
  

  factory Consulta.fromMap(Map<String, dynamic> map) {
    return Consulta(
      idConsultas: map['id_consultas'],
      dataConsulta: map['data_consulta'],
      horarioInicio: map['horario_inicio'],
      horarioFim: map['horario_fim'],
      observacoes: map['observacoes'],
      estado: map['estado'] ?? 'confirmada',
      idPerfis: map['id_perfis'],
      idMedicos: map['id_medicos'],
      idTipoMarcacao: map['id_tipo_marcacao'],
      idTipoConsultas: map['id_tipo_consultas'],
      medicoNome: map['medico_nome'],
      especialidadeNome: map['especialidade_nome'],
    );
  }
}
