import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:viva_store/controllers/auth_controller.dart';

class LoginComponent extends StatefulWidget {
  const LoginComponent({
    Key? key,
    required this.aoClicarCadastrar,
  }) : super(key: key);

  final Function aoClicarCadastrar;

  @override
  State<LoginComponent> createState() => _LoginComponentState();
}

class _LoginComponentState extends State<LoginComponent> {
  final _authController = Get.put(AuthController());

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _carregando = false;
  bool _erro = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildLogo(context),
            const SizedBox(height: 40.0),
            buildEmail(),
            const SizedBox(height: 10.0),
            buildSenha(),
            buildBotaoEsqueciSenha(),
            const SizedBox(height: 15),
            buildBotaoEntrar(),
            const SizedBox(height: 5),
            buildMensagemErro(),
            const SizedBox(height: 10),
            buildBotaoCriarConta(),
          ],
        ),
      ),
    );
  }

  Future logar() async {
    setState(() {
      _carregando = true;
      _erro = false;
    });
    try {
      await _authController.logar(email: _emailController.text, senha: _senhaController.text);
    } catch (e) {
      setState(() {
        _carregando = false;
        _erro = true;
      });
    }
  }

  Widget buildLogo(BuildContext context) {
    return Center(
      child: Text(
        'Viva Store',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 55,
        ),
      ),
    );
  }

  Widget buildBotaoEsqueciSenha() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => {},
        style: const ButtonStyle(padding: MaterialStatePropertyAll(EdgeInsets.zero)),
        child: const Text('Esqueci a senha', style: TextStyle(color: Colors.blue)),
      ),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      controller: _emailController,
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(CupertinoIcons.mail),
      ),
      inputFormatters: [LengthLimitingTextInputFormatter(60)],
      onSaved: (value) => _emailController.value = _emailController.value.copyWith(text: value),
    );
  }

  Widget buildSenha() {
    return TextFormField(
      controller: _senhaController,
      obscureText: true,
      autocorrect: false,
      decoration: const InputDecoration(labelText: 'Senha', prefixIcon: Icon(Icons.key)),
      inputFormatters: [LengthLimitingTextInputFormatter(20)],
      onSaved: (value) => _senhaController.value = _senhaController.value.copyWith(text: value),
    );
  }

  Widget buildBotaoEntrar() {
    return _carregando
        ? Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
            child: const Center(
              child: SizedBox(
                width: 30,
                height: 30,
                child: Center(child: CircularProgressIndicator(strokeWidth: 4)),
              ),
            ),
          )
        : ElevatedButton(
            onPressed: logar,
            style: const ButtonStyle(
              fixedSize: MaterialStatePropertyAll(Size(double.infinity, 59)),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
            child: const Text('Entrar', style: TextStyle(fontSize: 20)),
          );
  }

  Widget buildMensagemErro() {
    return Text(
      "Usuário ou senha inválidos",
      style: TextStyle(color: _erro ? Colors.red : Colors.transparent),
      textAlign: TextAlign.center,
    );
  }

  Widget buildBotaoCriarConta() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          'Não tem uma conta?',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.end,
        ),
        TextButton(
          onPressed: () => widget.aoClicarCadastrar(),
          style: const ButtonStyle(
            alignment: Alignment.centerLeft,
            padding: MaterialStatePropertyAll(EdgeInsets.zero),
          ),
          child: const Text(' Cadastre-se agora', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
