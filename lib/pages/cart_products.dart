import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:viva_store/controllers/carrinho_controller.dart';

class CartProducts extends StatelessWidget {
  final CarrinhoController controller = Get.put(CarrinhoController());

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
          itemCount: controller.itens.length,
          itemBuilder: (BuildContext context, int index) {
            return CartProductCard(
              controller: controller,
              produtoId: controller.itens.keys.toList()[index],
              quantidade: controller.itens.values.toList()[index],
            );
          },
        ),
      ),
    );
  }
}

class CartProductCard extends StatelessWidget {
  final CarrinhoController controller;
  final String produtoId;
  final int quantidade;

  const CartProductCard({
    Key? key,
    required this.controller,
    required this.produtoId,
    required this.quantidade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(produtoId);
  }
}
