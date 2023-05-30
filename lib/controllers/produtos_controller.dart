import 'package:get/get.dart';
import 'package:viva_store/models/produto.dart';
import 'package:viva_store/repositorios/produto_repository.dart';

class ProdutosController extends GetxController {
  final ProdutoRepository _produtoRepository = Get.put(ProdutoRepository());

  Future<Produto?> obter(String produtoId) async {
    return await _produtoRepository.obter(produtoId);
  }

  Stream<List<Produto>> obterEmOferta() {
    return _produtoRepository.obterEmOferta();
  }

  Stream<List<Produto>> obterPorCategoria(String categoria) {
    return _produtoRepository.obterPorCategoria(categoria);
  }
}
