class Usuario {
  final int idUtilizadores;
  final String email;
  final int? idPerfis;
  final int idTipoUtilizadores;
  final String? token;
  final dynamic termosAssinados; // Pode ser int, bool ou String ('assinado')

  Usuario({
    required this.idUtilizadores,
    required this.email,
    this.idPerfis,
    required this.idTipoUtilizadores,
    this.token,
    this.termosAssinados,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_utilizadores': idUtilizadores,
      'email': email,
      'id_perfis': idPerfis,
      'id_tipo_utilizadores': idTipoUtilizadores,
      'token': token,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUtilizadores: map['id_utilizadores'],
      email: map['email'],
      idPerfis: map['id_perfis'],
      idTipoUtilizadores: map['id_tipo_utilizadores'],
      token: map['token'],
      termosAssinados: map['termos_assinados'],
    );
  }
}
