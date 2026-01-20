class NotificacaoModel {
  final int? id;
  final int? idNotificacoes;
  final String designacao;
  final String descricao;
  final int lida;

  NotificacaoModel({
    this.id,
    this.idNotificacoes,
    required this.designacao,
    required this.descricao,
    this.lida = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_notificacoes': idNotificacoes,
      'designacao': designacao,
      'descricao': descricao,
      'lida': lida,
    };
  }

  factory NotificacaoModel.fromMap(Map<String, dynamic> map) {
    return NotificacaoModel(
      id: map['id'],
      idNotificacoes: map['id_notificacoes'],
      designacao: map['designacao'] ?? '',
      descricao: map['descricao'] ?? '',
      lida: map['lida'] ?? 0,
    );
  }
}
