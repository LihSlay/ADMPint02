class Perfil {
  final int idPerfis;
  final int idUtilizadores;
  final String? nome;
  final int? nUtente;
  final String? dataNasc;
  final String? contactoTel;
  final String? profissao;
  final String? morada;
  final String? codPostal;
  final String? nif;
  final String? responsavel;
  final String? notas;
  final int? idSubsistemasSaude;
  final int? idEstadoCivil;
  final int? idGenero;
  final int? idParentesco;
  final String? alcunhas;
  final dynamic ativo;

  Perfil({
    required this.idPerfis,
    required this.idUtilizadores,
    this.nome,
    this.nUtente,
    this.dataNasc,
    this.contactoTel,
    this.profissao,
    this.morada,
    this.codPostal,
    this.nif,
    this.responsavel,
    this.notas,
    this.idSubsistemasSaude,
    this.idEstadoCivil,
    this.idGenero,
    this.idParentesco,
    this.alcunhas,
    this.ativo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_perfis': idPerfis,
      'id_utilizadores': idUtilizadores,
      'nome': nome,
      'n_utente': nUtente,
      'data_nasc': dataNasc,
      'contacto_tel': contactoTel,
      'profissao': profissao,
      'morada': morada,
      'cod_postal': codPostal,
      'nif': nif,
      'responsavel': responsavel,
      'notas': notas,
      'id_subsistemas_saude': idSubsistemasSaude,
      'id_estado_civil': idEstadoCivil,
      'id_genero': idGenero,
      'id_parentesco': idParentesco,
      'alcunhas': alcunhas,
      'ativo': ativo,
    };
  }

  factory Perfil.fromMap(Map<String, dynamic> map) {
    return Perfil(
      idPerfis: map['id_perfis'],
      idUtilizadores: map['id_utilizadores'],
      nome: map['nome'],
      nUtente: map['n_utente'],
      dataNasc: map['data_nasc'],
      contactoTel: map['contacto_tel'],
      profissao: map['profissao'],
      morada: map['morada'],
      codPostal: map['cod_postal'],
      nif: map['nif'],
      responsavel: map['responsavel'],
      notas: map['notas'],
      idSubsistemasSaude: map['id_subsistemas_saude'],
      idEstadoCivil: map['id_estado_civil'],
      idGenero: map['id_genero'],
      idParentesco: map['id_parentesco'],
      alcunhas: map['alcunhas'],
      ativo: map['ativo'],
    );
  }
}
