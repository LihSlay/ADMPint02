class Documento {
  final int idDocumento;
  final String? titulo;
  final int? idTipoDocumento;

  Documento({
    required this.idDocumento,
    this.titulo,
    this.idTipoDocumento,
  });

  factory Documento.fromMap(Map<String, dynamic> map) {
    return Documento(
      idDocumento: map['id_documentos'],
      titulo: map['titulo'],
      idTipoDocumento: map['id_tipo_documentos'],
    );
  }
}
