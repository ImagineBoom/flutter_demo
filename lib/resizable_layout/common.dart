import 'dart:ui';

import 'package:flutter/material.dart';

extension InvertColorRGB on Color {
  // 互补色: Complementary color
  Color complementary() {
    final r = 255 - this.red;
    final g = 255 - this.green;
    final b = 255 - this.blue;

    return Color.fromARGB((this.opacity * 255).round(), r, g, b);
  }

  // 对比色: Contrasting color
  Color contrast() {
    final int r = ((this.red+255*150/360)%255).round();
    final int g = ((this.green+255*150/360)%255).round();
    final int b = ((this.blue+255*150/360)%255).round();

    return Color.fromARGB((this.opacity * 255).round(), r, g, b);
  }
}
