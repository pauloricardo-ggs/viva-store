import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:viva_store/components/home/botao_produto_oferta.dart';
import 'package:viva_store/controllers/auth_controller.dart';
import 'package:viva_store/controllers/carrinho_controller.dart';
import 'package:viva_store/controllers/favoritos_controller.dart';
import 'package:viva_store/controllers/produtos_controller.dart';
import 'package:viva_store/models/produto.dart';
import 'package:viva_store/pages/carrinho_page.dart';

class CatalogoPage extends StatefulWidget {
  final Function irParaTelaDeLogin;
  final String categoria;

  const CatalogoPage({
    Key? key,
    required this.irParaTelaDeLogin,
    required this.categoria,
  }) : super(key: key);

  @override
  State<CatalogoPage> createState() => _CatalogoPageState();
}

class _CatalogoPageState extends State<CatalogoPage> {
  final carrinhoController = Get.put(CarrinhoController());
  final favoritosController = Get.put(FavoritosController());
  final produtosController = Get.put(ProdutosController());
  final authController = Get.put(AuthController());

  final barraDePesquisaController = TextEditingController();

  int quantidadeOfertasExibindo = 10;
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
    var colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: buildBarraDePesquisa(),
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                if (authController.logado()) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CarrinhoPage()));
                  return;
                }
                widget.irParaTelaDeLogin();
              },
              icon: badges.Badge(
                badgeStyle: badges.BadgeStyle(badgeColor: authController.logado() ? Colors.black : Colors.transparent),
                badgeContent: Obx(() => Text('${carrinhoController.itens.length}', style: TextStyle(color: authController.logado() ? Colors.white : Colors.transparent))),
                child: Icon(
                  CupertinoIcons.cart_fill,
                  color: colorScheme.secondary,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildProdutos(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget buildBarraDePesquisa() {
    return SizedBox(
      height: 35,
      child: TextField(
        style: const TextStyle(color: Colors.black),
        controller: barraDePesquisaController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          prefixIcon: const Icon(CupertinoIcons.search),
          prefixIconColor: Colors.black45,
          fillColor: Theme.of(context).colorScheme.secondary,
          hintText: "Pesquisar em ${widget.categoria}",
          hintStyle: const TextStyle(color: Colors.black45),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
    );
  }

  Widget buildProdutos() {
    return Column(
      children: [
        const SizedBox(height: 12.0),
        StreamBuilder<List<Produto>>(
          stream: produtosController.obterPorCategoria(widget.categoria),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (!snapshot.hasData) return const CircularProgressIndicator();

            produtos = snapshot.data!;
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              itemCount: produtos.length >= quantidadeOfertasExibindo ? quantidadeOfertasExibindo : produtos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8.0),
              itemBuilder: (context, index) => SizedBox(
                height: 170,
                child: Obx(
                  () => BotaoProdutoOferta(
                    produto: produtos[index],
                    aoClicarNoCarrinho: () {
                      if (authController.logado()) return carrinhoController.alternarSeEstaNoCarrinho(produtos[index].id);
                      widget.irParaTelaDeLogin();
                    },
                    aoClicarNosFavoritos: () {
                      if (authController.logado()) return favoritosController.alternarSeEstaNoFavorito(produtos[index].id);

                      widget.irParaTelaDeLogin();
                    },
                    noCarrinho: carrinhoController.estaNoCarrinho(produtos[index].id),
                    nosFavoritos: favoritosController.estaNosFavoritos(produtos[index].id),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 3.0),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: ElevatedButton(
            onPressed: produtos.length <= quantidadeOfertasExibindo ? null : () => setState(() => quantidadeOfertasExibindo += 5),
            child: const Text("Ver mais"),
          ),
        ),
      ],
    );
  }
}

class Categoria {
  String nome;
  IconData icon;

  Categoria({
    required this.nome,
    required this.icon,
  });
}
