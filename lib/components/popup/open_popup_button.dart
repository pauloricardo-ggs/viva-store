import 'package:flutter/material.dart';
import 'package:viva_store/components/popup/custom_rect_tween.dart';
import 'package:viva_store/components/popup/hero_dialog_route.dart';

class OpenPopupButton extends StatelessWidget {
  final Widget popupCard;
  final Widget child;
  final String tag;

  const OpenPopupButton({
    super.key,
    required this.popupCard,
    required this.child,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return popupCard;
        }));
      },
      child: Hero(
        tag: tag,
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin!, end: end!);
        },
        child: child,
      ),
    );
  }
}
