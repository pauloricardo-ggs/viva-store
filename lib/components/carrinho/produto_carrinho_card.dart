import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viva_store/components/tag_desconto.dart';
import 'package:viva_store/controllers/carrinho_controller.dart';
import 'package:viva_store/dev_pack.dart';
import 'package:viva_store/models/produto.dart';

class ProdutoCarrinhoCard extends StatelessWidget {
  final CarrinhoController carrinhoController;
  final Produto produto;
  final int quantidade;

  final devPack = const DevPack();

  const ProdutoCarrinhoCard({
    Key? key,
    required this.carrinhoController,
    required this.produto,
    required this.quantidade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final corPrimaria = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        Badge(
          backgroundColor: Colors.transparent,
          largeSize: 40,
          offset: const Offset(10, -15),
          label: GestureDetector(
            onTap: () => carrinhoController.removerItem(produto.id),
            child: const SizedBox(
              height: 40,
              width: 40,
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                color: Colors.red,
              ),
            ),
          ),
          child: Material(
            color: Get.isDarkMode ? const Color(0x18FFFFFF) : const Color(0xCEFFFFFF),
            borderRadius: BorderRadius.circular(8.0),
            elevation: 1,
            child: SizedBox(
              height: 100,
              child: Row(
                children: [
                  buildImagem(),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildNome(),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildPrecos(cor: corPrimaria),
                                buildBotoes(cor: corPrimaria, favoritado: true),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
        height: 17,
        width: 40,
        child: CustomPaint(
          painter: TagDesconto(color: cor),
          child: Center(
            child: Text(
              "-${produto.porcentagemDesconto}%   ",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImagem() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
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
      ),
    );
  }

  Widget buildNome() {
    return Text(
      produto.nome,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget buildPrecos({required Color cor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 15),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            devPack.formatarParaMoeda(produto.precoComDesconto()),
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        produto.porcentagemDesconto != 0
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  devPack.formatarParaMoeda(produto.preco),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget buildBotoes({required Color cor, required bool favoritado}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => carrinhoController.diminuirQuantidadeDoItem(produto.id),
          icon: const Icon(CupertinoIcons.minus, size: 20),
        ),
        Text('$quantidade', style: const TextStyle(fontSize: 20)),
        IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => carrinhoController.adicionarQuantidadeDoItem(produto.id),
          icon: const Icon(CupertinoIcons.plus, size: 20),
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}
