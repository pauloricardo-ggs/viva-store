import 'package:get/get.dart';
import 'package:viva_store/models/produto.dart';
import 'package:viva_store/repositorios/produto_repository.dart';

class ProdutoController extends GetxController {
  final ProdutoRepository _produtoRepository = Get.put(ProdutoRepository());

  Future<Produto?> obter(String produtoId) async {
    return await _produtoRepository.obter(produtoId);
  }

  // Future<Produto?> obter(String produtoId) async {
  //   return await _produtoRepository.obter(produtoId);
  // }

  // Future adicionarItem(String produtoId) async {
  //   if (estaNoCarrinho(produtoId)) {
  //     _itens[produtoId] += 1;
  //   } else {
  //     _itens[produtoId] = 1;
  //   }
  //   await _carrinhoRepository.atualizar(itens);
  // }

  // Future alternarSeEstaNoCarrinho(String produtoId) async {
  //   if (estaNoCarrinho(produtoId)) {
  //     _itens.remove(produtoId);
  //   } else {
  //     _itens[produtoId] = 1;
  //   }
  //   await _carrinhoRepository.atualizar(itens);
  // }

  // bool estaNoCarrinho(String produtoId) {
  //   return _itens.containsKey(produtoId);
  // }
}
