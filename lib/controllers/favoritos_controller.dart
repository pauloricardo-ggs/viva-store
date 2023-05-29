import 'package:get/get.dart';
import 'package:viva_store/repositorios/favoritos_repository.dart';

class FavoritosController extends GetxController {
  final FavoritosRepository _favoritosRepository = Get.put(FavoritosRepository());

  final RxList<String> _produtosId = <String>[].obs;
  RxList<String> get produtosId => _produtosId;

  Future<void> obterFavoritos() async {
    final produtosId = await _favoritosRepository.listar();
    _produtosId.value = produtosId;
  }

  Future<void> alternarSeEstaNoFavorito(String produtoId) async {
    if (estaNosFavoritos(produtoId)) {
      _produtosId.remove(produtoId);
    } else {
      _produtosId.add(produtoId);
    }

    await _favoritosRepository.atualizar(_produtosId);
  }

  bool estaNosFavoritos(String produtoId) {
    return _produtosId.contains(produtoId);
  }
}
