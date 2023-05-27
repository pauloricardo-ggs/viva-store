import 'dart:convert';

class ItemCarrinho {
  String produtoId;
  int quantidade;

  ItemCarrinho({
    required this.produtoId,
    required this.quantidade,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'produtoId': produtoId,
      'quantidade': quantidade,
    };
  }

  factory ItemCarrinho.fromMap(Map<String, dynamic> map) {
    return ItemCarrinho(
      produtoId: map['produtoId'] as String,
      quantidade: map['quantidade'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemCarrinho.fromJson(String source) => ItemCarrinho.fromMap(json.decode(source) as Map<String, dynamic>);
}
