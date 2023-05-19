import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:viva_store/pages/my_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _error = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Viva Store",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 55,
                ),
              ),
              const SizedBox(height: 40.0),
              LoginTextField(hintText: "Email", controller: _emailController),
              const SizedBox(height: 10.0),
              LoginTextField(hintText: "Senha", controller: _passwordController, obscureText: true),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LinkButton(text: "Recuperar senha"),
                  LinkButton(text: "Novo cadastro"),
                ],
              ),
              const SizedBox(height: 15),
              LoginButton(isLoading: _isLoading, onPressed: logar),
              const SizedBox(height: 10),
              Text(
                "Usuário ou senha inválidos",
                style: TextStyle(color: _error ? Colors.red : Colors.transparent),
              )
            ],
          ),
        ),
      ),
    );
  }

  void logar() async {
    setState(() {
      _isLoading = true;
      _error = false;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (context.mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyHomePage()));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = true;
      });
    }
  }
}

class LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const LoginButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
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
            onPressed: onPressed,
            style: const ButtonStyle(
              fixedSize: MaterialStatePropertyAll(Size(100, 50)),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 16.0),
            ),
          );
  }
}

class LinkButton extends StatelessWidget {
  final String text;

  const LinkButton({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => {},
      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.transparent), elevation: MaterialStatePropertyAll(0), padding: MaterialStatePropertyAll(EdgeInsets.zero)),
      child: Text(
        text,
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }
}

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const LoginTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withOpacity(0.06),
        hintText: hintText,
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(15.0)),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}
