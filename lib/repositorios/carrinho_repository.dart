import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:viva_store/controllers/auth_controller.dart';
import 'package:viva_store/models/carrinho.dart';
import 'package:viva_store/models/item_carrinho.dart';

class CarrinhoRepository {
  final authController = Get.put(AuthController());
  final firebaseFirestore = FirebaseFirestore.instance;

  final collection = 'carrinhos';

  Future obterItens() async {
    if (authController.usuario == null) {
      return;
    }
    final usuarioId = authController.usuario!.uid;

    final carrinhoSnapshot = await firebaseFirestore.collection(collection).doc(usuarioId).get();

    final rxMap = {}.obs;

    if (carrinhoSnapshot.exists) {
      var itens = Carrinho.fromMap(carrinhoSnapshot.data()!).itens!;
      for (var item in itens) {
        rxMap[item.produtoId] = item.quantidade;
      }
      return rxMap;
    }

    final novoCarrinho = Carrinho(id: usuarioId, itens: []);
    await firebaseFirestore.collection(collection).doc(usuarioId).set(novoCarrinho.toMap());
    return rxMap;
  }

  Future atualizar(RxMap<dynamic, dynamic> itens) async {
    final usuarioId = authController.usuario!.uid;

    final doc = firebaseFirestore.collection(collection).doc(usuarioId);

    final listaItens = <ItemCarrinho>[];

    itens.forEach((key, value) {
      final item = ItemCarrinho(produtoId: key as String, quantidade: value as int);
      listaItens.add(item);
    });

    await doc.update({'itens': listaItens.map((item) => item.toMap())});
  }
}
