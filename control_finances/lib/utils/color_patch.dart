// lib/utils/color_patch.dart
import 'package:flutter/material.dart';

extension ColorPatch on Color {
  double get a => alpha   / 255.0;
  double get r => red     / 255.0;
  double get g => green   / 255.0;
  double get b => blue    / 255.0;

  Color withValues({
    double? alpha, double? red, double? green, double? blue,
  }) {
    return Color.fromARGB(
      ((alpha ?? this.a)   * 255).round(),
      ((red   ?? this.r)   * 255).round(),
      ((green ?? this.g)   * 255).round(),
      ((blue  ?? this.b)   * 255).round(),
    );
  }
}
