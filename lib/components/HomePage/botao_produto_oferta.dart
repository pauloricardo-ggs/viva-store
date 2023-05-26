import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:viva_store/models/produto.dart';

class BotaoProdutoOferta extends StatelessWidget {
  final Produto produto;

  const BotaoProdutoOferta({
    Key? key,
    required this.produto,
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
              buildImagem(imagem: produto.imagensUrl[0]),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 15.0, bottom: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildNome(nome: produto.nome),
                      ),
                      buildPrecos(cor: corPrimaria, preco: produto.preco, desconto: produto.porcentagemDesconto),
                      const SizedBox(height: 10.0),
                      buildBotoes(cor: corPrimaria, noCarrinho: true, favoritado: true),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        buildTagDesconto(desconto: produto.porcentagemDesconto, cor: corPrimaria),
      ],
    );
  }

  Widget buildTagDesconto({required int desconto, required Color cor}) {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: 20,
        width: 58,
        child: CustomPaint(
          painter: PriceTagPaint(color: cor),
          child: Center(
            child: Text(
              "-$desconto%   ",
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

  Widget buildImagem({required String imagem}) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            color: Get.isDarkMode ? const Color(0x61FFFFFF) : const Color(0xFFFFFFFF),
            border: Border.all(color: Get.isDarkMode ? const Color(0xFF757575) : const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image(
              image: NetworkImage(
                imagem,
                scale: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNome({required String nome}) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        nome,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget buildPrecos({required Color cor, required double preco, required int desconto}) {
    var formatter = NumberFormat.currency(decimalDigits: 2, symbol: 'R\$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            formatter.format(preco - (preco * desconto / 100)),
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
            formatter.format(preco),
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

  Widget buildBotoes({required Color cor, required bool noCarrinho, required bool favoritado}) {
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
          Icon(CupertinoIcons.cart_fill, size: 30, color: noCarrinho ? cor : Colors.grey.shade500),
          const SizedBox(width: 8.0),
          Icon(CupertinoIcons.heart_fill, size: 30, color: favoritado ? Colors.red : Colors.grey.shade500),
        ],
      ),
    );
  }
}

class PriceTagPaint extends CustomPainter {
  const PriceTagPaint({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    Path path = Path();

    path
      ..moveTo(0, 0)
      ..lineTo(size.width * .87, 0)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width * .87, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    //* Circle
    canvas.drawCircle(
      Offset(size.width * .87, size.height * .5),
      size.height * .15,
      paint..color = Get.isDarkMode ? const Color(0xFF666666) : const Color(0xFFFFFFFF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
