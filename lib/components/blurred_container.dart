import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredContainer extends StatelessWidget {
  const BlurredContainer({
    Key? key,
    this.blurriness = 8.0,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final double blurriness;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: blurriness,
        sigmaY: blurriness,
      ),
      child: child,
    );
  }
}
