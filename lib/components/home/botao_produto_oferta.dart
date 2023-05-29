import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viva_store/components/tag_desconto.dart';
import 'package:viva_store/dev_pack.dart';
import 'package:viva_store/models/produto.dart';

class BotaoProdutoOferta extends StatelessWidget {
  final Produto produto;
  final Function aoClicarNoCarrinho;
  final bool noCarrinho;

  final devPack = const DevPack();

  const BotaoProdutoOferta({
    Key? key,
    required this.produto,
    required this.aoClicarNoCarrinho,
    required this.noCarrinho,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final corPrimaria = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        Material(
          color: Get.isDarkMode ? const Color(0x18FFFFFF) : const Color(0xCEFFFFFF),
          borderRadius: BorderRadius.circular(8.0),
          elevation: 1,
          child: Row(
            children: [
              buildImagem(),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 15.0, bottom: 18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildNome(),
                      buildPrecos(cor: corPrimaria),
                      const SizedBox(height: 10.0),
                      buildBotoes(cor: corPrimaria, favoritado: true),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        buildTagDesconto(cor: corPrimaria),
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
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          color: Get.isDarkMode ? const Color(0x61FFFFFF) : const Color(0xFFFFFFFF),
          border: Border.all(color: Get.isDarkMode ? const Color(0xFF757575) : const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: SizedBox(
          width: 160,
          height: 160,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            devPack.formatarParaMoeda(produto.precoComDesconto()),
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            devPack.formatarParaMoeda(produto.preco),
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              decoration: TextDecoration.lineThrough,
              decorationThickness: 1.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget buildBotoes({required Color cor, required bool favoritado}) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: const ButtonStyle(padding: MaterialStatePropertyAll(EdgeInsets.zero)),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Comprar",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: () => aoClicarNoCarrinho(),
            icon: Icon(
              CupertinoIcons.cart_fill,
              size: 30,
              color: noCarrinho ? cor : Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: () => {},
            icon: Icon(
              CupertinoIcons.heart_fill,
              size: 30,
              color: favoritado ? Colors.red : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
