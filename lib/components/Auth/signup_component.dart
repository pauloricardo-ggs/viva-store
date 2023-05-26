import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:validadores/Validador.dart';

class SignupComponent extends StatefulWidget {
  const SignupComponent({
    Key? key,
    required this.aoClicarEntrar,
  }) : super(key: key);

  final Function aoClicarEntrar;

  @override
  State<SignupComponent> createState() => _SignupComponentState();
}

class _SignupComponentState extends State<SignupComponent> {
  final _formKey = GlobalKey<FormState>();
  final _senhaKey = GlobalKey<FlutterPwValidatorState>();

  final _colchetes = RegExp(r"\p{P}", unicode: true);

  bool _senhaValida = false;
  bool _carregando = false;

  final _nomeCompletoController = TextEditingController();
  final _cpfController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmacaoSenhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 20.0),
            buildNomeCompleto(),
            const SizedBox(height: 20.0),
            Row(
              children: [
                buildCpf(),
                const SizedBox(width: 20.0),
                buildDataNascimento(),
              ],
            ),
            const SizedBox(height: 20.0),
            buildTelefone(),
            const SizedBox(height: 20.0),
            buildEmail(),
            const SizedBox(height: 20.0),
            buildSenha(),
            const SizedBox(height: 20.0),
            buildConfirmacaoSenha(),
            const SizedBox(height: 20.0),
            buildBotaoCadastrar(),
            buildBotaoEntrar(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget buildNomeCompleto() {
    return TextFormField(
      minLines: 1,
      maxLines: 5,
      autocorrect: false,
      controller: _nomeCompletoController,
      decoration: const InputDecoration(label: Text("Nome completo")),
      inputFormatters: [LengthLimitingTextInputFormatter(80)],
      validator: (value) {
        if (value!.removeAllWhitespace.length < 5) return 'O nome deve ter no entre 5 e 80 caracteres';
        return null;
      },
      onSaved: (value) => _nomeCompletoController.value = _nomeCompletoController.value.copyWith(text: value),
    );
  }

  Widget buildCpf() {
    final mask = MaskTextInputFormatter(mask: '###.###.###-##', filter: {'#': RegExp(r'[0-9]')});
    return Expanded(
      child: TextFormField(
        autocorrect: false,
        controller: _cpfController,
        decoration: const InputDecoration(label: Text("CPF")),
        keyboardType: TextInputType.number,
        inputFormatters: [mask],
        validator: (value) {
          return Validador().add(Validar.CPF, msg: 'Cpf inválido').valido(value, clearNoNumber: true)?.replaceAll(_colchetes, '');
        },
        onSaved: (value) => _cpfController.value = _cpfController.value.copyWith(text: value),
      ),
    );
  }

  Widget buildDataNascimento() {
    final mask = MaskTextInputFormatter(mask: '##/##/####', filter: {'#': RegExp(r'[0-9]')});
    return Expanded(
      child: TextFormField(
        autocorrect: false,
        controller: _dataNascimentoController,
        decoration: const InputDecoration(label: Text("Data de nascimento")),
        keyboardType: TextInputType.number,
        inputFormatters: [mask],
        validator: (value) {
          try {
            DateFormat('dd/MM/yyyy').parseStrict(value!);
            return null;
          } catch (e) {
            return 'Data inválida';
          }
        },
        onSaved: (value) => _dataNascimentoController.value = _dataNascimentoController.value.copyWith(text: value),
      ),
    );
  }

  Widget buildTelefone() {
    final mask = MaskTextInputFormatter(mask: '(##) #####-####', filter: {'#': RegExp(r'[0-9]')});
    return TextFormField(
      autocorrect: false,
      controller: _telefoneController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(label: Text("Telefone celular")),
      inputFormatters: [mask],
      validator: (value) {
        return Validador().minLength(11, msg: 'Telefone inválido').maxLength(11, msg: 'Telefone inválido').valido(value, clearNoNumber: true)?.replaceAll(_colchetes, '');
      },
      onSaved: (value) => _telefoneController.value = _telefoneController.value.copyWith(text: value),
    );
  }

  Widget buildEmail() {
    return TextFormField(
      autocorrect: false,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(label: Text("Email")),
      inputFormatters: [LengthLimitingTextInputFormatter(60)],
      validator: (value) {
        if (value != null && RegExp('^[a-z0-9.]+@[a-z0-9]+.[a-z]+.([a-z]+)?').hasMatch(value)) {
          return null;
        }
        return 'Email inválido';
      },
      onSaved: (value) => _emailController.value = _emailController.value.copyWith(text: value),
    );
  }

  Widget buildSenha() {
    return Column(
      children: [
        TextFormField(
          autocorrect: false,
          controller: _senhaController,
          obscureText: true,
          decoration: const InputDecoration(
            label: Text("Senha"),
            errorStyle: TextStyle(height: 0),
          ),
          inputFormatters: [LengthLimitingTextInputFormatter(20)],
          validator: (value) {
            return _senhaValida ? null : '';
          },
          onSaved: (value) => _senhaController.value = _senhaController.value.copyWith(text: value),
        ),
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: FlutterPwValidator(
            key: _senhaKey,
            successColor: Theme.of(context).colorScheme.primary,
            failureColor: Colors.red.shade600,
            controller: _senhaController,
            minLength: 6,
            uppercaseCharCount: 1,
            lowercaseCharCount: 1,
            numericCharCount: 1,
            specialCharCount: 1,
            width: 300,
            spacer: 10,
            onSuccess: () => setState(() => _senhaValida = true),
            onFail: () => setState(() => _senhaValida = false),
          ),
        ),
      ],
    );
  }

  Widget buildConfirmacaoSenha() {
    return TextFormField(
      autocorrect: false,
      controller: _confirmacaoSenhaController,
      obscureText: true,
      decoration: const InputDecoration(label: Text("Confirmação de senha")),
      inputFormatters: [LengthLimitingTextInputFormatter(20)],
      validator: (value) => _confirmacaoSenhaController.text == _senhaController.text ? null : 'As senhas não coincidem',
      onSaved: (value) => _confirmacaoSenhaController.value = _confirmacaoSenhaController.value.copyWith(text: value),
    );
  }

  Widget buildBotaoCadastrar() {
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
            style: const ButtonStyle(
              fixedSize: MaterialStatePropertyAll(Size(double.infinity, 59)),
            ),
            onPressed: () {
              final valido = _formKey.currentState!.validate();
              if (valido) {
                cadastrar();
              }
            },
            child: const Text('Cadastrar', style: TextStyle(fontSize: 20)),
          );
  }

  Widget buildBotaoEntrar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        const Text(
          'Já tem uma conta?',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.end,
        ),
        TextButton(
          onPressed: () => widget.aoClicarEntrar(),
          style: const ButtonStyle(
            alignment: Alignment.centerLeft,
            padding: MaterialStatePropertyAll(EdgeInsets.zero),
          ),
          child: const Text(' Entrar', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Future cadastrar() async {
    setState(() => _carregando = true);
    try {
      var credenciais = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text, password: _senhaController.text);
      scaffoldMessenger('Usuário cadastrado com sucesso!', cor: Colors.green);
      final docProduct = FirebaseFirestore.instance.collection('perfilUsuarios').doc(credenciais.user!.uid);
      final json = {
        'nomeCompleto': _nomeCompletoController.value.text,
        'cpf': _cpfController.value.text,
        'dataNascimento': _dataNascimentoController.value.text,
        'telefone': _telefoneController.value.text,
      };
      await docProduct.set(json);
    } on FirebaseAuthException catch (e) {
      var mensagemErro = '';
      setState(() => _carregando = false);
      if (e.code == 'email-already-in-use') {
        mensagemErro = 'Já existe uma conta com o email informado';
      } else {
        mensagemErro = e.code;
      }

      scaffoldMessenger(mensagemErro, cor: Colors.red.shade600);
    }
  }

  void scaffoldMessenger(String mensagem, {required Color cor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
      ),
    );
  }
}
