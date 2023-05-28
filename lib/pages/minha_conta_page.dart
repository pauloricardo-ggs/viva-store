import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viva_store/controllers/auth_controller.dart';
import 'package:viva_store/pages/cadastrar_produto_page.dart';

class MinhaContaPage extends StatefulWidget {
  const MinhaContaPage({Key? key}) : super(key: key);

  @override
  State<MinhaContaPage> createState() => _MinhaContaPageState();
}

class _MinhaContaPageState extends State<MinhaContaPage> {
  final _authController = Get.put(AuthController());

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
            const SizedBox(height: 100),
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

  Widget buidBotaoBase(BuildContext context, {required String texto, required IconData icone, required Function onPressed, Color? cor, bool bordaNoTopo = false}) {
    var theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        border: Border(
          top: bordaNoTopo ? BorderSide(color: theme.colorScheme.onBackground.withOpacity(0.3), width: 0.4) : BorderSide.none,
          bottom: BorderSide(color: theme.colorScheme.onBackground.withOpacity(0.5), width: 0.4),
        ),
      ),
      child: ElevatedButton(
        onPressed: () => onPressed(),
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.transparent),
          elevation: MaterialStatePropertyAll(0),
          fixedSize: MaterialStatePropertyAll(Size(double.infinity, 48)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(child: Icon(icone, color: cor ?? theme.colorScheme.onBackground)),
            const SizedBox(width: 5),
            Text(texto, style: TextStyle(color: cor ?? theme.colorScheme.onBackground, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void deslogar() async {
    _authController.sair();
  }
}
