import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:viva_store/components/Auth/login_component.dart';
import 'package:viva_store/components/Auth/signup_component.dart';
import 'package:viva_store/pages/account_page.dart';

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
        if (snapshot.hasData) return const AccountPage();
        return entrar ? LoginComponent(aoClicarCadastrar: toggle) : SignupComponent(aoClicarEntrar: toggle);
      },
    );
  }

  void toggle() => setState(() => entrar = !entrar);
}
