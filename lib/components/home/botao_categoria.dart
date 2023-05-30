import 'package:flutter/material.dart';
import 'package:viva_store/pages/catalogo_categoria.dart';

class BotaoCategoria extends StatefulWidget {
  final Color cor;
  final IconData? icone;
  final String nome;
  final Function irParaTelaDeLogin;

  const BotaoCategoria({
    Key? key,
    required this.cor,
    required this.icone,
    required this.nome,
    required this.irParaTelaDeLogin,
  }) : super(key: key);

  @override
  State<BotaoCategoria> createState() => _BotaoCategoriaState();
}

class _BotaoCategoriaState extends State<BotaoCategoria> {
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
            color: widget.cor,
          ),
          child: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CatalogoPage(categoria: widget.nome, irParaTelaDeLogin: widget.irParaTelaDeLogin)),
            ),
            icon: Icon(widget.icone),
            color: Colors.black,
            iconSize: 30,
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 65,
          child: Text(
            widget.nome,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}
