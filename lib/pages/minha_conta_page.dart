import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:viva_store/pages/product/cadastrar_produto_page.dart';

class MinhaContaPage extends StatefulWidget {
  const MinhaContaPage({Key? key}) : super(key: key);

  @override
  State<MinhaContaPage> createState() => _MinhaContaPageState();
}

class _MinhaContaPageState extends State<MinhaContaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Conta')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildBotaoCadastrarNovoProduto(context),
            buildBotaoPlaceHolder(context),
            const SizedBox(height: 10),
            buildBotaoSair(context),
          ],
        ),
      ),
    );
  }

  Widget buildBotaoCadastrarNovoProduto(BuildContext context) {
    return buidBotaoBase(
      context,
      texto: 'Cadastrar novo produto',
      icone: Icons.add_shopping_cart,
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastrarProdutoPage())),
    );
  }

  Widget buildBotaoPlaceHolder(BuildContext context) {
    return buidBotaoBase(
      context,
      texto: 'Placeholder',
      icone: CupertinoIcons.placemark_fill,
      onPressed: () => {},
    );
  }

  Widget buildBotaoSair(BuildContext context) {
    return buidBotaoBase(
      context,
      texto: 'Sair',
      cor: Colors.red.shade600,
      icone: Icons.logout,
      bordaNoTopo: true,
      onPressed: () => deslogar(),
    );
  }

  Widget buidBotaoBase(BuildContext context, {required String texto, required IconData icone, required Function onPressed, Color cor = Colors.black, bool bordaNoTopo = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          top: bordaNoTopo ? const BorderSide(color: Colors.grey, width: 0.4) : BorderSide.none,
          bottom: const BorderSide(color: Colors.grey, width: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(child: Icon(icone, color: cor)),
          TextButton(
            style: const ButtonStyle(alignment: Alignment.centerLeft),
            onPressed: () => onPressed(),
            child: Text(
              texto,
              style: TextStyle(color: cor, fontSize: 15),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  void deslogar() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.code),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }
}
