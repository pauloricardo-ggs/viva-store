import 'package:flutter/material.dart';
import 'package:viva_store/components/blurred_container.dart';
import 'package:viva_store/components/popup/custom_rect_tween.dart';
import 'package:viva_store/components/popup/hero_dialog_route.dart';
import 'package:viva_store/dev_pack.dart';

class DetalhesCarrinhoPullUpCard extends StatelessWidget {
  final double valorTotal;
  final double precoProdutos;
  final double valorDescontos;
  final double? valorFrete;
  final tag = 'detalhes-carrinho';

  final devPack = const DevPack();

  const DetalhesCarrinhoPullUpCard({
    Key? key,
    required this.valorTotal,
    required this.precoProdutos,
    required this.valorDescontos,
    required this.valorFrete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final corPrimaria = Theme.of(context).colorScheme.primary;
    final corSecundaria = Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTap: () => expandir(context),
      onVerticalDragUpdate: (details) {
        if (details.delta.dy < 0) expandir(context);
      },
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Hero(
          tag: tag,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: ClipRRect(
            child: BlurredContainer(
              child: Material(
                color: corSecundaria.withOpacity(0.7),
                elevation: 4,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                child: SizedBox(
                  width: double.infinity,
                  child: SafeArea(
                    top: false,
                    right: false,
                    left: false,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 3,
                              width: 50,
                              decoration: BoxDecoration(color: corPrimaria.withOpacity(0.4), borderRadius: BorderRadius.circular(50)),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          Text(
                            'Total: ${devPack.formatarParaMoeda(valorTotal)}',
                            style: const TextStyle(fontSize: 25),
                          ),
                        ],
                      ),
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

  void expandir(BuildContext context) {
    Navigator.of(context).push(HeroDialogRoute(builder: (context) {
      return DetalhesCarrinhoExpandido(
        tag: tag,
        valorTotal: valorTotal,
        valorDescontos: valorDescontos,
        precoProdutos: precoProdutos,
        valorFrete: valorFrete,
      );
    }));
  }
}

class DetalhesCarrinhoExpandido extends StatelessWidget {
  final String tag;
  final double valorTotal;
  final double precoProdutos;
  final double valorDescontos;
  final double? valorFrete;

  final devPack = const DevPack();

  const DetalhesCarrinhoExpandido({
    Key? key,
    required this.tag,
    required this.valorTotal,
    required this.precoProdutos,
    required this.valorDescontos,
    required this.valorFrete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final corPrimaria = Theme.of(context).colorScheme.primary;
    final corSecundaria = Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 0) {
          Navigator.pop(context);
        }
      },
      onTap: () => Navigator.pop(context),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Hero(
          tag: tag,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin!, end: end!);
          },
          child: ClipRRect(
            child: BlurredContainer(
              child: Material(
                color: corSecundaria.withOpacity(0.7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: SizedBox(
                  width: double.infinity,
                  child: SafeArea(
                    top: false,
                    right: false,
                    left: false,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                height: 3,
                                width: 50,
                                decoration: BoxDecoration(color: corPrimaria.withOpacity(0.4), borderRadius: BorderRadius.circular(50)),
                              ),
                            ),
                            const SizedBox(height: 15.0),
                            Text(
                              'Total: ${devPack.formatarParaMoeda(valorTotal)}',
                              style: const TextStyle(fontSize: 25),
                            ),
                            const SizedBox(height: 15.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Text(
                                  devPack.formatarParaMoeda(precoProdutos),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Desconto',
                                  style: TextStyle(color: Colors.red, fontSize: 18),
                                ),
                                Text(
                                  devPack.formatarParaMoeda(valorDescontos),
                                  style: const TextStyle(color: Colors.red, fontSize: 18),
                                ),
                              ],
                            ),
                            valorFrete == null
                                ? const SizedBox.shrink()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Frete',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text(
                                        devPack.formatarParaMoeda(valorFrete!),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Cupom',
                                  style: TextStyle(color: Colors.red, fontSize: 18),
                                ),
                                Text(
                                  devPack.formatarParaMoeda(valorDescontos),
                                  style: const TextStyle(color: Colors.red, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
