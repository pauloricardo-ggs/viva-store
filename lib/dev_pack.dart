import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DevPack {
  const DevPack();

  final duracaoBase = const Duration(seconds: 3);

  void notificaoErro({String titulo = 'Oops!', required String mensagem, Duration? duracao}) {
    Get.snackbar(
      titulo,
      '',
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      duration: duracao ?? duracaoBase,
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 0),
      messageText: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 3),
          Text(
            mensagem,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 10),
          AnimatedLinearProgressIndicator(duration: duracao ?? duracaoBase),
        ],
      ),
    );
  }

  void notificaoSucesso({String titulo = 'Oba!', required String mensagem, Duration? duracao}) {
    Get.snackbar(
      titulo,
      '',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: duracao ?? duracaoBase,
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 0),
      messageText: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 3),
          Text(
            mensagem,
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 10),
          AnimatedLinearProgressIndicator(duration: duracao ?? duracaoBase),
        ],
      ),
    );
  }

  String formatarParaMoeda(double valor) {
    var formatter = NumberFormat.currency(decimalDigits: 2, symbol: 'R\$');
    return formatter.format(valor).replaceAll('.', ':').replaceAll(',', '.').replaceAll(':', ',');
  }

  double formatarParaDuasCasas(double valor) {
    double valorArredondado = valor.floorToDouble();
    String valorString = valorArredondado.toStringAsFixed(2);
    double valorFormatado = double.parse(valorString);

    return valorFormatado;
  }
}

class AnimatedLinearProgressIndicator extends StatefulWidget {
  final Duration duration;

  const AnimatedLinearProgressIndicator({super.key, required this.duration});

  @override
  State<AnimatedLinearProgressIndicator> createState() => _AnimatedLinearProgressIndicatorState();
}

class _AnimatedLinearProgressIndicatorState extends State<AnimatedLinearProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black.withOpacity(0.3)),
          backgroundColor: Colors.transparent,
          value: _animation.value,
        );
      },
    );
  }
}
