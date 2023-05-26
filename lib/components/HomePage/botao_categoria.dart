import 'package:flutter/material.dart';

class BotaoCategoria extends StatelessWidget {
  final Color cor;
  final IconData? icone;
  final String nome;

  const BotaoCategoria({
    Key? key,
    required this.icone,
    required this.cor,
    required this.nome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: cor,
          ),
          child: IconButton(
            onPressed: () => {},
            icon: Icon(icone),
            color: Colors.black,
            iconSize: 30,
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 65,
          child: Text(
            nome,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}
