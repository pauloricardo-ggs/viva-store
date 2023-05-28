// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:viva_store/components/blurred_container.dart';
import 'package:viva_store/components/popup/custom_rect_tween.dart';
import 'package:viva_store/components/popup/open_popup_button.dart';
import 'package:viva_store/components/tag_desconto.dart';
import 'package:viva_store/controllers/carrinho_controller.dart';
import 'package:viva_store/models/produto.dart';

class CartProducts extends StatefulWidget {
  const CartProducts({Key? key}) : super(key: key);

  @override
  State<CartProducts> createState() => _CartProductsState();
}

class _CartProductsState extends State<CartProducts> {
  final CarrinhoController _carrinhoController = Get.put(CarrinhoController());

  bool aMostra = false;

  @override
  Widget build(BuildContext context) {
    final corSecundaria = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.back),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(CupertinoIcons.trash_fill),
          ),
        ],
      ),
      body: Stack(
        children: [
          Obx(
            () => ListView.separated(
              itemCount: _carrinhoController.itens.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (BuildContext context, int index) {
                final produtoId = _carrinhoController.itens.keys.toList()[index];
                final quantidade = _carrinhoController.itens.values.toList()[index];
                final produto = _carrinhoController.produtos.firstWhere((produto) => produto.id == produtoId);
                return CartProductCard(
                  carrinhoController: _carrinhoController,
                  produtoId: produtoId,
                  produto: produto,
                  quantidade: quantidade,
                );
              },
            ),
          ),
          buildDetalhesCarrinho(cor: corSecundaria, tag: 'detalhes-carrinho'),
        ],
      ),
    );
  }

  Widget buildDetalhesCarrinho({required String tag, required Color cor}) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: OpenPopupButton(
        popupCard: buildDetalhesCarrinhoExpandido(tag: tag, cor: cor),
        tag: tag,
        child: ClipRRect(
          child: BlurredContainer(
            child: Material(
              color: cor.withOpacity(0.7),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: SafeArea(
                top: false,
                right: false,
                left: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 6.0, left: 7.0, right: 14.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Valor Total',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDetalhesCarrinhoExpandido({required String tag, required Color cor}) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Hero(
        tag: tag,
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin!, end: end!);
        },
        child: ClipRRect(
          child: BlurredContainer(
            child: Material(
              color: cor.withOpacity(0.7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: SafeArea(
                top: false,
                right: false,
                left: false,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            backgroundImage: const NetworkImage('https://img.freepik.com/fotos-gratis/terra-e-galaxia-elementos-desta-imagem-fornecidos-pela-nasa_335224-750.jpg'),
                            backgroundColor: cor,
                            radius: 60,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          child: Center(
                            child: Text(
                              'algummdmasd sad ',
                              style: TextStyle(fontSize: 28, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Divider(color: Colors.white.withOpacity(0.9), height: 20, thickness: 0.5),
                        const Text('Cpf:', style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text('_morador.cpf', style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        Divider(color: Colors.white.withOpacity(0.9), height: 20, thickness: 0.5),
                        const Text('Email:', style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text('_morador.email', style: TextStyle(color: Colors.white)),
                        Divider(color: Colors.white.withOpacity(0.9), height: 20, thickness: 0.5),
                        const Text('Telefone:', style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text('_morador.telefone', style: TextStyle(color: Colors.white)),
                        Divider(color: Colors.white.withOpacity(0.9), height: 20, thickness: 0.5),
                        const Text('Data de nascimento:', style: TextStyle(color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text('_morador.dataNascimento', style: TextStyle(color: Colors.white)),
                        Divider(color: Colors.white.withOpacity(0.9), height: 20, thickness: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CartProductCard extends StatelessWidget {
  final CarrinhoController carrinhoController;
  final String produtoId;
  final Produto produto;
  final int quantidade;

  const CartProductCard({
    Key? key,
    required this.carrinhoController,
    required this.produtoId,
    required this.produto,
    required this.quantidade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final corPrimaria = Theme.of(context).colorScheme.primary;
    const altura = 150.0;
    return Stack(
      children: [
        Material(
          color: Get.isDarkMode ? const Color(0x18FFFFFF) : const Color(0xCEFFFFFF),
          borderRadius: BorderRadius.circular(8.0),
          elevation: 1,
          child: Container(
            padding: const EdgeInsets.all(5.0),
            height: altura,
            child: Row(
              children: [
                buildImagem(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildNome(),
                    buildPrecos(cor: corPrimaria),
                    buildBotoes(cor: corPrimaria, favoritado: false),
                  ],
                ),
              ],
            ),
          ),
        ),
        produto.porcentagemDesconto != 0 ? buildTagDesconto(cor: corPrimaria) : const SizedBox.shrink(),
      ],
    );
  }

  Widget buildTagDesconto({required Color cor}) {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: 20,
        width: 58,
        child: CustomPaint(
          painter: TagDesconto(color: cor),
          child: Center(
            child: Text(
              "-${produto.porcentagemDesconto}%   ",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImagem() {
    return Container(
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0x61FFFFFF) : const Color(0xFFFFFFFF),
        border: Border.all(color: Get.isDarkMode ? const Color(0xFF757575) : const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          produto.imagensUrl[0],
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildNome() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        produto.nome,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget buildPrecos({required Color cor}) {
    var formatter = NumberFormat.currency(decimalDigits: 2, symbol: 'R\$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formatter.format(produto.preco - (produto.preco * produto.porcentagemDesconto / 100)),
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        produto.porcentagemDesconto != 0
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatter.format(produto.preco),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget buildBotoes({required Color cor, required bool favoritado}) {
    return Row(
      children: [
        IconButton(
          onPressed: () => carrinhoController.diminuirQuantidadeDoItem(produtoId),
          icon: const Icon(CupertinoIcons.minus, size: 20),
        ),
        Text('$quantidade', style: const TextStyle(fontSize: 20)),
        IconButton(
          onPressed: () => carrinhoController.adicionarQuantidadeDoItem(produtoId),
          icon: const Icon(CupertinoIcons.plus, size: 20),
        ),
      ],
    );
  }
}
