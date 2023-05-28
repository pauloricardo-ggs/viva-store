import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:viva_store/models/produto.dart';

class ProdutoRepository {
  final firebaseFirestore = FirebaseFirestore.instance;

  final collection = 'produtos';

  Future<Produto?> obter(String produtoId) async {
    final doc = await firebaseFirestore.collection(collection).doc(produtoId).get();
    final map = doc.data();
    if (map != null) return Produto.fromMap(map);
    return null;
  }
}
