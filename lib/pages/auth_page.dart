import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:viva_store/pages/login_page.dart';
import 'package:viva_store/pages/minha_conta_page.dart';
import 'package:viva_store/pages/singup_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool entrar = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
        if (snapshot.hasData) return const MinhaContaPage();
        return entrar ? LoginPage(aoClicarCadastrar: toggle) : SignupPage(aoClicarEntrar: toggle);
      },
    );
  }

  void toggle() => setState(() => entrar = !entrar);
}
