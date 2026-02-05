class Documento {
  final int idDocumento;
  final String? titulo;
  final int? idTipoDocumento;
  final int? idConsultas;
  final String? url;

  Documento({
    required this.idDocumento,
    this.titulo,
    this.idTipoDocumento,
    this.idConsultas,
    this.url,
  });

  factory Documento.fromMap(Map<String, dynamic> map) {
    return Documento(
      idDocumento: map['id_documentos'],
      titulo: map['titulo'],
      idTipoDocumento: map['id_tipo_documentos'],
      idConsultas: map['id_consultas'],

      url: map['url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_documentos': idDocumento,
      'titulo': titulo,
      'id_tipo_documentos': idTipoDocumento,
      'id_consultas': idConsultas,
      'url': url,
    };
  }
}
