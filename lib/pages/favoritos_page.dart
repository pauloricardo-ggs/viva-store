import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viva_store/components/produto_card.dart';
import 'package:viva_store/controllers/auth_controller.dart';
import 'package:viva_store/controllers/carrinho_controller.dart';
import 'package:viva_store/controllers/favoritos_controller.dart';
import 'package:viva_store/models/produto.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final int currentPage = 1;

  final favoritosController = Get.put(FavoritosController());
  final carrinhoController = Get.put(CarrinhoController());
  final authController = Get.put(AuthController());
  List<Produto> produtos = [];

  @override
  void initState() {
    if (authController.logado()) {
      carrinhoController.obterCarrinho();
      favoritosController.obterFavoritos();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoritos"),
      ),
      body: StreamBuilder<List<Produto>>(
        stream: obterProdutos(favoritosController.produtosId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) return const CircularProgressIndicator();

          produtos = snapshot.data!;
          return ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(10.0),
            itemCount: produtos.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8.0),
            itemBuilder: (context, index) => SizedBox(
              height: 170,
              child: Obx(
                () => ProdutoCard(
                  produto: produtos[index],
                  aoClicarNoCarrinho: () => carrinhoController.alternarSeEstaNoCarrinho(produtos[index].id),
                  aoClicarNosFavoritos: () => favoritosController.alternarSeEstaNoFavorito(produtos[index].id),
                  noCarrinho: carrinhoController.estaNoCarrinho(produtos[index].id),
                  nosFavoritos: favoritosController.estaNosFavoritos(produtos[index].id),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Stream<List<Produto>> obterProdutos(List<String> produtosId) {
    return FirebaseFirestore.instance
        .collection('produtos')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Produto.fromMap(doc.data())).where((produto) => produtosId.contains(produto.id)).toList());
  }
}
