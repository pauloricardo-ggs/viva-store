import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:viva_store/controllers/carrinho_controller.dart';
import 'package:viva_store/models/produto.dart';

class CartProducts extends StatelessWidget {
  final CarrinhoController _carrinhoController = Get.put(CarrinhoController());

  CartProducts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.back),
        ),
      ),
      body: SizedBox(
        height: 600,
        child: ListView.builder(
          itemCount: _carrinhoController.itens.length,
          itemBuilder: (BuildContext context, int index) {
            return Obx(
              () => CartProductCard(
                carrinhoController: _carrinhoController,
                produtoId: _carrinhoController.itens.keys.toList()[index],
                produto: _carrinhoController.produtos[index],
                quantidade: _carrinhoController.itens.values.toList()[index],
              ),
            );
          },
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Text('pelo item: $produtoId'),
          Text('pelo produto ${produto.nome} - ${produto.id}'),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
