import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:viva_store/controllers/auth_controller.dart';
import 'package:viva_store/models/favoritos.dart';

class FavoritosRepository {
  final AuthController authController = Get.put(AuthController());
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  final collection = 'favoritos';

  Future<RxList<String>> listar() async {
    if (authController.usuario == null) {
      return RxList<String>([]);
    }

    final usuarioId = authController.usuario!.uid;

    final favoritosSnapshot = await firebaseFirestore.collection(collection).doc(usuarioId).get();

    if (favoritosSnapshot.exists) {
      return RxList<String>.of(Favoritos.fromMap(favoritosSnapshot.data()!).produtosId);
    }

    final novoFavorito = Favoritos(id: usuarioId, produtosId: []);
    await firebaseFirestore.collection(collection).doc(usuarioId).set(novoFavorito.toMap());
    return RxList<String>.of(novoFavorito.produtosId);
  }

  Future<void> atualizar(List<String> produtosId) async {
    final usuarioId = authController.usuario!.uid;

    final favoritos = Favoritos(id: usuarioId, produtosId: produtosId);

    final doc = firebaseFirestore.collection(collection).doc(usuarioId);

    await doc.update(favoritos.toMap());
  }
}
