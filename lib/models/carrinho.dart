import 'dart:convert';

import 'package:viva_store/models/item_carrinho.dart';

class Carrinho {
  String? id;
  List<ItemCarrinho>? itens;

  Carrinho({
    this.id,
    this.itens,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'itens': itens?.map((item) => item.toMap()).toList(),
    };
  }

  factory Carrinho.fromMap(Map<String, dynamic> json) {
    return Carrinho(
      id: json['id'],
      itens: (json['itens'] as List).map((element) => ItemCarrinho.fromMap(element)).toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Carrinho.fromJson(String source) => Carrinho.fromMap(json.decode(source) as Map<String, dynamic>);
}
