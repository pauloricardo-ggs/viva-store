import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:validadores/Validador.dart';
import 'package:viva_store/components/blurred_container.dart';
import 'package:viva_store/controllers/auth_controller.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({
    Key? key,
    required this.aoClicarEntrar,
  }) : super(key: key);

  final Function aoClicarEntrar;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _authController = Get.put(AuthController());

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
  void dispose() {
    _nomeCompletoController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmacaoSenhaController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
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
        ),
        _carregando
            ? const Stack(
                children: [
                  ModalBarrier(dismissible: false),
                  BlurredContainer(blurriness: 4, child: Center(child: SizedBox(width: 60, height: 60, child: CircularProgressIndicator()))),
                ],
              )
            : const SizedBox(),
      ],
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
    return ElevatedButton(
      style: const ButtonStyle(
        fixedSize: MaterialStatePropertyAll(Size(double.infinity, 59)),
      ),
      onPressed: _carregando
          ? null
          : () {
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
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _carregando = true);
    await _authController.cadastrar(
        email: _emailController.text,
        senha: _senhaController.text,
        nome: _nomeCompletoController.text,
        cpf: _cpfController.text,
        dataNascimento: _dataNascimentoController.text,
        telefone: _telefoneController.text);
    if (mounted) setState(() => _carregando = false);
  }
}
