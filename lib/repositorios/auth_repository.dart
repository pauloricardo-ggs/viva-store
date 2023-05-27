import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final firebaseAuth = FirebaseAuth.instance;
  final firebaseFirestore = FirebaseFirestore.instance;

  final perfisCollection = 'perfilUsuarios';

  Future<void> logar(String email, String senha) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<UserCredential> cadastrarUsuario(String email, String senha) async {
    try {
      return await firebaseAuth.createUserWithEmailAndPassword(email: email, password: senha);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> cadastrarPerfilUsuario(String usuarioId, Map<String, dynamic> perfilUsuario) async {
    try {
      await firebaseFirestore.collection(perfisCollection).doc(usuarioId).set(perfilUsuario);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future sair() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  User? obterUsuarioLogado() {
    return firebaseAuth.currentUser;
  }
}
