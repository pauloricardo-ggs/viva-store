import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:viva_store/components/custom_snack_bar.dart';
import 'package:viva_store/repositorios/auth_repository.dart';

class AuthController extends GetxController {
  final _authRepository = Get.put(AuthRepository());

  final snackBar = const CustomSnackBar();
  User? _usuario;
  User? get usuario => _usuario;

  AuthController() {
    _atualizarUsuarioLogado();
  }

  Future<void> logar({required String email, required String senha}) async {
    try {
      await _authRepository.logar(email, senha);
      _atualizarUsuarioLogado();
    } on FirebaseAuthException catch (e) {
      snackBar.erro(mensagem: e.code);
    }
  }

  Future<void> cadastrar({required String email, required String senha, required String nome, required String cpf, required String dataNascimento, required String telefone}) async {
    try {
      var credential = await _authRepository.cadastrarUsuario(email, senha);

      final json = {
        'nomeCompleto': nome,
        'cpf': cpf,
        'dataNascimento': dataNascimento,
        'telefone': telefone,
      };

      await _authRepository.cadastrarPerfilUsuario(credential.user!.uid, json);

      _usuario = credential.user;
      snackBar.sucesso(mensagem: 'Usuário cadastrado com sucesso!');
      _atualizarUsuarioLogado();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        snackBar.erro(mensagem: 'Já existe uma conta com o email informado');
      } else {
        snackBar.erro(mensagem: e.code);
      }
    }
  }

  Future<void> sair() async {
    try {
      await _authRepository.sair();
      _atualizarUsuarioLogado();
    } on FirebaseAuthException catch (e) {
      snackBar.erro(mensagem: e.code);
    }
  }

  _atualizarUsuarioLogado() {
    _usuario = _authRepository.obterUsuarioLogado();
  }

  bool logado() {
    return usuario != null;
  }
}
