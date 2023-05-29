import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:viva_store/components/carrinho/detalhes_carrinho_pullup_card.dart';
import 'package:viva_store/components/carrinho/produto_carrinho_card.dart';
import 'package:viva_store/controllers/carrinho_controller.dart';
import 'package:viva_store/dev_pack.dart';

class CarrinhoPage extends StatefulWidget {
  const CarrinhoPage({Key? key}) : super(key: key);

  @override
  State<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  final _carrinhoController = Get.put(CarrinhoController());
  final _cepController = TextEditingController();
  final devPack = const DevPack();

  bool detalhesExpandido = false;
  double? frete;
  String? prazoEntrega;

  @override
  Widget build(BuildContext context) {
    final corPrimaria = Theme.of(context).colorScheme.primary;

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
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0),
            child: Column(
              children: [
                buildFrete(corPrimaria),
                const SizedBox(height: 15),
                buildProdutos(),
              ],
            ),
          ),
          Obx(
            () => DetalhesCarrinhoPullUpCard(
              valorTotal: calcularValorTotal(),
              precoProdutos: calcularPrecoProdutos(),
              valorDescontos: calcularDescontoProdutos(),
              valorFrete: frete,
            ),
          )
        ],
      ),
    );
  }

  Widget buildFrete(Color corPrimaria) {
    final mask = MaskTextInputFormatter(mask: '#####-###', filter: {'#': RegExp(r'[0-9]')});

    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 120,
            child: TextFormField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              inputFormatters: [mask],
              decoration: InputDecoration(
                label: const Text('CEP'),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: corPrimaria),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: ElevatedButton(
              style: const ButtonStyle(
                  shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                ),
              )),
              onPressed: () {
                FocusScope.of(context).unfocus();
                calcularValorFrete();
                obterPrazoEntrega();
              },
              child: const Text('OK', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 15),
          frete == null
              ? const SizedBox.shrink()
              : Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Frete: ${devPack.formatarParaMoeda(frete!)}'),
                      Text('$prazoEntrega'),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget buildProdutos() {
    return Expanded(
      child: Obx(
        () => ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _carrinhoController.itens.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) {
            final produtoId = _carrinhoController.itens.keys.toList()[index];
            final quantidade = _carrinhoController.itens.values.toList()[index];
            final produto = _carrinhoController.produtos.firstWhere((produto) => produto.id == produtoId);
            return ProdutoCarrinhoCard(
              carrinhoController: _carrinhoController,
              produto: produto,
              quantidade: quantidade,
            );
          },
        ),
      ),
    );
  }

  double calcularPrecoProdutos() {
    double precoProdutos = 0.0;
    _carrinhoController.itens.forEach((produtoId, quantidade) {
      final produto = _carrinhoController.produtos.firstWhere((produto) => produto.id == produtoId);
      precoProdutos += (produto.preco * quantidade);
    });
    return devPack.formatarParaDuasCasas(precoProdutos);
  }

  double calcularDescontoProdutos() {
    double desconto = 0.0;
    _carrinhoController.itens.forEach((produtoId, quantidade) {
      final produto = _carrinhoController.produtos.firstWhere((produto) => produto.id == produtoId);
      desconto += (produto.valorDesconto() * quantidade);
    });
    return devPack.formatarParaDuasCasas(desconto);
  }

  double calcularValorTotal() {
    double total = 0.0;
    total = calcularPrecoProdutos() - calcularDescontoProdutos() + (frete ?? 0);
    return devPack.formatarParaDuasCasas(total);
  }

  void calcularValorFrete() {
    setState(() => frete = _cepController.text.isEmpty ? null : 10);
  }

  void obterPrazoEntrega() {
    setState(() => prazoEntrega = _cepController.text.isEmpty ? null : 'De 5 a 10 dias úteis');
  }
}
