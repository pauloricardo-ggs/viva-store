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

  Future obterCarrinho() async {
    final itens = await _carrinhoRepository.obterItens();

    _itens.clear();
    _produtos.clear();
    _itens.addAll(itens);

    itens.forEach((key, value) async => _adicionarProduto(key));
  }

  Future<void> adicionarQuantidadeDoItem(String produtoId) async {
    if (estaNoCarrinho(produtoId)) {
      _itens[produtoId] += 1;
    } else {
      _itens[produtoId] = 1;
      _adicionarProduto(produtoId);
    }

    await _carrinhoRepository.atualizar(itens);
  }

  Future _adicionarProduto(String produtoId) async {
    final produto = await _produtoRepository.obter(produtoId);
    if (produto != null) _produtos.add(produto);
  }

  Future<void> diminuirQuantidadeDoItem(String produtoId) async {
    if (_itens[produtoId] <= 1) {
      removerItem(produtoId);
    } else {
      _itens[produtoId] -= 1;
      await _carrinhoRepository.atualizar(itens);
    }
  }

  Future<void> removerItem(String produtoId) async {
    _itens.remove(produtoId);
    _removerProduto(produtoId);

    await _carrinhoRepository.atualizar(itens);
  }

  Future _removerProduto(String produtoId) async {
    final produto = await _produtoRepository.obter(produtoId);
    if (produto != null) _produtos.remove(produto);
  }

  Future alternarSeEstaNoCarrinho(String produtoId) async {
    if (estaNoCarrinho(produtoId)) {
      removerItem(produtoId);
    } else {
      adicionarQuantidadeDoItem(produtoId);
    }
  }

  bool estaNoCarrinho(String produtoId) {
    return _itens.containsKey(produtoId);
  }

  int quantidadeDeItens() {
    var quantidade = 0;
    _itens.forEach((key, value) {
      quantidade += value as int;
    });
    return quantidade;
  }
}
