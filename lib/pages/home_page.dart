import 'package:badges/badges.dart' as badges;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:viva_store/components/home/botao_banner.dart';
import 'package:viva_store/components/home/botao_categoria.dart';
import 'package:viva_store/components/home/botao_produto_oferta.dart';
import 'package:viva_store/components/page_view_indicators.dart';
import 'package:viva_store/controllers/auth_controller.dart';
import 'package:viva_store/controllers/carrinho_controller.dart';
import 'package:viva_store/controllers/categorias_controller.dart';
import 'package:viva_store/controllers/favoritos_controller.dart';
import 'package:viva_store/models/categoria.dart';
import 'package:viva_store/models/produto.dart';
import 'package:viva_store/pages/carrinho_page.dart';

class HomePage extends StatefulWidget {
  final Function irParaTelaDeLogin;

  const HomePage({
    Key? key,
    required this.irParaTelaDeLogin,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> banners = [
    "images/home_page/banners/oferta_decoracao.png",
    "images/home_page/banners/oferta_roupa.jpg",
    "images/home_page/banners/oferta_banheiro.jpg",
  ];

  final authController = Get.put(AuthController());
  final carrinhoController = Get.put(CarrinhoController());
  final favoritosController = Get.put(FavoritosController());
  final categoriasController = Get.put(CategoriasController());

  final barraDePesquisaController = TextEditingController();

  int bannerAtual = 0;
  int quantidadeOfertasExibindo = 5;
  List<Produto> produtos = [];
  List<Categoria> categorias = [];

  @override
  void initState() {
    categorias = categoriasController.listar();
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
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: buildBarraDePesquisa(),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () => Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark),
            icon: Icon(
              Get.isDarkMode ? CupertinoIcons.sun_min_fill : CupertinoIcons.moon_fill,
              color: colorScheme.secondary,
            ),
          ),
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
            buildCategorias(),
            const SizedBox(height: 10),
            buildBanners(),
            PageViewIndicators(numberOfPages: banners.length, selectedPage: bannerAtual),
            buildProdutosEmOferta(),
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
          hintText: "Pesquisar",
          hintStyle: const TextStyle(color: Colors.black45),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
    );
  }

  Widget buildCategorias() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        separatorBuilder: (context, index) => const SizedBox(width: 8.0),
        itemBuilder: (context, i) => Center(
          child: BotaoCategoria(
            nome: categorias[i].nome,
            icone: categorias[i].icone,
            cor: Theme.of(context).colorScheme.secondary,
            irParaTelaDeLogin: widget.irParaTelaDeLogin,
          ),
        ),
      ),
    );
  }

  Widget buildBanners() {
    return CarouselSlider.builder(
      itemCount: banners.length,
      itemBuilder: (context, index, realIndex) => BotaoBanner(imagem: banners[index]),
      options: CarouselOptions(
        height: 200,
        onPageChanged: (index, reason) => setState(() => bannerAtual = index),
        enlargeCenterPage: true,
        enlargeFactor: 0.2,
        autoPlayAnimationDuration: const Duration(milliseconds: 1500),
        autoPlay: true,
        pauseAutoPlayOnManualNavigate: true,
        pauseAutoPlayOnTouch: true,
        autoPlayInterval: const Duration(seconds: 10),
      ),
    );
  }

  Widget buildProdutosEmOferta() {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: const Text(
            "Ofertas",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        StreamBuilder<List<Produto>>(
          stream: obterProdutos(),
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

  Stream<List<Produto>> obterProdutos() {
    return FirebaseFirestore.instance
        .collection('produtos')
        .where('porcentagemDesconto', isNotEqualTo: 0)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Produto.fromMap(doc.data())).toList());
  }
}
