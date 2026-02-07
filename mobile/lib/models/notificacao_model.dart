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

  // ---------- COPY WITH (NOVO) ----------
  NotificacaoModel copyWith({
    int? id,
    int? idNotificacoes,
    String? designacao,
    String? descricao,
    int? lida,
  }) {
    return NotificacaoModel(
      id: id ?? this.id,
      idNotificacoes: idNotificacoes ?? this.idNotificacoes,
      designacao: designacao ?? this.designacao,
      descricao: descricao ?? this.descricao,
      lida: lida ?? this.lida,
    );
  }

  // ---------- TO MAP ----------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_notificacoes': idNotificacoes,
      'designacao': designacao,
      'descricao': descricao,
      'lida': lida,
    };
  }

  // ---------- FROM MAP ----------
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
