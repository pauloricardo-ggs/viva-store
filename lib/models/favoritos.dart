import 'package:get/get.dart';

class Favoritos {
  String? id;
  RxList<String> produtosId = RxList<String>([]);

  Favoritos({
    this.id,
    List<String>? produtosId,
  }) {
    this.produtosId.value = produtosId ?? [];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produtosId': produtosId,
    };
  }

  static Favoritos fromMap(Map<String, dynamic> map) {
    return Favoritos(
      id: map['id'],
      produtosId: List<String>.from(map['produtosId']),
    );
  }
}
