import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BotaoBanner extends StatelessWidget {
  final String imagem;

  const BotaoBanner({
    Key? key,
    required this.imagem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color borderColor = Get.isDarkMode ? Colors.white30 : Colors.black26;
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 10,
        margin: const EdgeInsets.symmetric(horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: AssetImage(imagem),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
