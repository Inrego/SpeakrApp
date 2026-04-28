import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

class MonoEyebrow extends StatelessWidget {
  const MonoEyebrow(
    this.text, {
    super.key,
    this.color = SpeakrColors.muted,
    this.size = 11,
  });

  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: SpeakrText.mono(size: size, color: color, letterSpacing: 1.5),
    );
  }
}
