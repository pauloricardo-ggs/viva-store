import 'package:badges/badges.dart' as badges;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viva_store/components/blurred_container.dart';
import 'package:viva_store/components/page_view_indicators.dart';
import 'package:viva_store/controllers/auth_controller.dart';
import 'package:viva_store/controllers/carrinho_controller.dart';
import 'package:viva_store/controllers/favoritos_controller.dart';
import 'package:viva_store/dev_pack.dart';

import 'package:viva_store/models/produto.dart';
import 'package:viva_store/pages/carrinho_page.dart';

class ProdutoDetalhesPage extends StatelessWidget {
  final Produto produto;

  final devPack = const DevPack();

  final _authController = Get.put(AuthController());
  final _carrinhoController = Get.put(CarrinhoController());
  final _barraDePesquisaController = TextEditingController();
  final _favoritosController = Get.put(FavoritosController());

  ProdutoDetalhesPage({
    Key? key,
    required this.produto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: buildBarraDePesquisa(colorScheme.secondary),
        ),
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              onPressed: () {
                if (_authController.logado()) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CarrinhoPage()));
                  return;
                }
                //widget.irParaTelaDeLogin();
              },
              icon: badges.Badge(
                badgeStyle: badges.BadgeStyle(badgeColor: _authController.logado() ? Colors.black : Colors.transparent),
                badgeContent: Obx(() => Text('${_carrinhoController.itens.length}', style: TextStyle(color: _authController.logado() ? Colors.white : Colors.transparent))),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarrosselDeImagens(imagensUrl: produto.imagensUrl),
                  buildNome(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(produto.categoria, style: TextStyle(color: Colors.grey.shade600)),
                      Text('${produto.estoque} em estoque!', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  buildPrecos(cor: colorScheme.primary),
                  const Divider(thickness: 1, height: 30),
                  buildDescricao(),
                  const Divider(thickness: 1, height: 40),
                  buildInformacoesTecnicas(),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              child: BlurredContainer(
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(25),
                  color: colorScheme.secondary.withOpacity(0.3),
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_authController.logado()) {
                        if (!_carrinhoController.estaNoCarrinho(produto.id)) {
                          await _carrinhoController.alternarSeEstaNoCarrinho(produto.id);
                        }
                        if (context.mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => const CarrinhoPage()));
                        return;
                      }
                      devPack.notificaoErro(mensagem: 'Você precisa estar logado para comprar esse item');
                    },
                    style: const ButtonStyle(
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      )),
                    ),
                    child: const Text('COMPRAR'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDescricao() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Descrição', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(produto.descricao),
      ],
    );
  }

  Widget buildInformacoesTecnicas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informações Técnicas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('Dimensões (CxLxA): ${produto.comprimento} x ${produto.largura} x ${produto.altura} ${produto.escalaDimensao}'),
        Text('Peso: ${produto.peso} ${produto.escalaPeso}'),
      ],
    );
  }

  Widget buildBarraDePesquisa(Color cor) {
    return SizedBox(
      height: 35,
      child: TextField(
        style: const TextStyle(color: Colors.black),
        controller: _barraDePesquisaController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          prefixIcon: const Icon(CupertinoIcons.search),
          prefixIconColor: Colors.black45,
          fillColor: cor,
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

  Widget buildNome() {
    return Text(
      produto.nome,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 22),
    );
  }

  Widget buildPrecos({required Color cor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        produto.porcentagemDesconto != 0
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  devPack.formatarParaMoeda(produto.preco),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : const SizedBox.shrink(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                devPack.formatarParaMoeda(produto.precoComDesconto()),
                overflow: TextOverflow.visible,
                style: TextStyle(
                  color: cor,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
            ),
            buildBotoes(cor: cor),
          ],
        ),
      ],
    );
  }

  Widget buildBotoes({required Color cor}) {
    return Obx(
      () => Row(
        children: [
          IconButton(
            onPressed: () async {
              if (_authController.logado()) return await _carrinhoController.alternarSeEstaNoCarrinho(produto.id);
              devPack.notificaoErro(mensagem: 'Você precisa estar logado adicionar esse item ao seu carrinho');
            },
            icon: Icon(
              CupertinoIcons.cart_fill,
              size: 30,
              color: _carrinhoController.estaNoCarrinho(produto.id) ? cor : Colors.grey.shade500,
            ),
          ),
          IconButton(
            onPressed: () async {
              if (_authController.logado()) return await _favoritosController.alternarSeEstaNoFavorito(produto.id);
              devPack.notificaoErro(mensagem: 'Você precisa estar logado para favoritar esse item');
            },
            icon: Icon(
              CupertinoIcons.heart_fill,
              size: 30,
              color: _favoritosController.estaNosFavoritos(produto.id) ? Colors.red : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class CarrosselDeImagens extends StatefulWidget {
  const CarrosselDeImagens({Key? key, required this.imagensUrl}) : super(key: key);

  final List<String> imagensUrl;

  @override
  State<CarrosselDeImagens> createState() => _CarrosselDeImagensState();
}

class _CarrosselDeImagensState extends State<CarrosselDeImagens> {
  var _frontImage = 0;
  final CarouselController controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    var isDark = Theme.of(context).brightness == Brightness.dark;
    var secondary = Theme.of(context).colorScheme.secondary;
    var itemsCount = widget.imagensUrl.length;

    return Column(
      children: [
        CarouselSlider.builder(
            carouselController: controller,
            itemCount: itemsCount,
            options: CarouselOptions(
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              viewportFraction: 0.7,
              height: 250,
              onPageChanged: (index, reason) => setState(() => _frontImage = index),
            ),
            itemBuilder: (context, index, realIndex) => buildImagem(index, isDark, secondary)),
        PageViewIndicators(numberOfPages: itemsCount, selectedPage: _frontImage)
      ],
    );
  }

  Widget buildImagem(int index, bool isDark, Color secondary) {
    return Container(
      height: 250,
      width: 250,
      decoration: BoxDecoration(
        color: isDark ? secondary.withOpacity(0.2) : secondary.withOpacity(0.16),
        border: Border.all(color: secondary),
        borderRadius: BorderRadius.circular(15.0),
        image: DecorationImage(image: NetworkImage(widget.imagensUrl[index]), fit: BoxFit.fill),
      ),
    );
  }
}
