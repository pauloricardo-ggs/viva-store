import 'package:get/get.dart';
import 'package:viva_store/repositorios/carrinho_repository.dart';

class CarrinhoController extends GetxController {
  final CarrinhoRepository _carrinhoRepository = Get.put(CarrinhoRepository());
  final _itens = {}.obs;
  RxMap<dynamic, dynamic> get itens => _itens;

  Future carregarItens() async {
    _itens.clear();
    _itens.addAll(await _carrinhoRepository.obterItens());
  }

  Future adicionarItem(String produtoId) async {
    if (estaNoCarrinho(produtoId)) {
      _itens[produtoId] += 1;
    } else {
      _itens[produtoId] = 1;
    }
    await _carrinhoRepository.atualizar(itens);
  }

  Future alternarSeEstaNoCarrinho(String produtoId) async {
    if (estaNoCarrinho(produtoId)) {
      _itens.remove(produtoId);
    } else {
      _itens[produtoId] = 1;
    }
    await _carrinhoRepository.atualizar(itens);
  }

  bool estaNoCarrinho(String produtoId) {
    return _itens.containsKey(produtoId);
  }
}
