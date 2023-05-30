import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:viva_store/components/tag_desconto.dart';
import 'package:viva_store/controllers/auth_controller.dart';
import 'package:viva_store/controllers/carrinho_controller.dart';
import 'package:viva_store/dev_pack.dart';
import 'package:viva_store/models/produto.dart';
import 'package:viva_store/pages/carrinho_page.dart';
import 'package:viva_store/pages/produto_detalhes_page.dart';

class ProdutoCard extends StatelessWidget {
  final Produto produto;
  final Function aoClicarNoCarrinho;
  final Function aoClicarNosFavoritos;
  final bool noCarrinho;
  final bool nosFavoritos;

  final _authController = Get.put(AuthController());
  final _carrinhoController = Get.put(CarrinhoController());

  final devPack = const DevPack();

  ProdutoCard({
    Key? key,
    required this.produto,
    required this.aoClicarNoCarrinho,
    required this.aoClicarNosFavoritos,
    required this.noCarrinho,
    required this.nosFavoritos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final corPrimaria = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProdutoDetalhesPage(produto: produto))),
      child: Stack(
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
                        buildBotoes(context, cor: corPrimaria, favoritado: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          produto.porcentagemDesconto != 0 ? buildTagDesconto(cor: corPrimaria) : const SizedBox.shrink(),
        ],
      ),
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
        produto.porcentagemDesconto != 0
            ? FittedBox(
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
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget buildBotoes(BuildContext context, {required Color cor, required bool favoritado}) {
    return Flexible(
      child: SizedBox(
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
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
                style: const ButtonStyle(padding: MaterialStatePropertyAll(EdgeInsets.zero)),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text("Comprar", style: TextStyle(fontSize: 16)),
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
              onPressed: () => aoClicarNosFavoritos(),
              icon: Icon(
                CupertinoIcons.heart_fill,
                size: 30,
                color: nosFavoritos ? Colors.red : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
