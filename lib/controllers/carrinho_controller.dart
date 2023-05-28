import 'package:get/get.dart';
import 'package:viva_store/models/produto.dart';
import 'package:viva_store/repositorios/carrinho_repository.dart';
import 'package:viva_store/repositorios/produto_repository.dart';

class CarrinhoController extends GetxController {
  final CarrinhoRepository _carrinhoRepository = Get.put(CarrinhoRepository());
  final ProdutoRepository _produtoRepository = Get.put(ProdutoRepository());

  final _itens = {}.obs;
  RxMap<dynamic, dynamic> get itens => _itens;

  final List<Produto> _produtos = [];
  List<Produto> get produtos => _produtos;

  Future recarregarCarrinho() async {
    final itens = await _carrinhoRepository.obterItens();

    _itens.clear();
    _produtos.clear();
    _itens.addAll(itens);

    itens.forEach((key, value) async {
      _produtos.add((await _produtoRepository.obter(key))!);
    });
  }

  Future adicionarItem(String produtoId) async {
    if (estaNoCarrinho(produtoId)) {
      _itens[produtoId] += 1;
    } else {
      _itens[produtoId] = 1;
    }
    await _carrinhoRepository.atualizar(itens);
    await recarregarCarrinho();
  }

  Future alternarSeEstaNoCarrinho(String produtoId) async {
    if (estaNoCarrinho(produtoId)) {
      _itens.remove(produtoId);
    } else {
      _itens[produtoId] = 1;
    }
    await _carrinhoRepository.atualizar(itens);
    await recarregarCarrinho();
  }

  bool estaNoCarrinho(String produtoId) {
    return _itens.containsKey(produtoId);
  }
}
