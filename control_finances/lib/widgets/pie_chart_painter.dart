// lib/widgets/pie_chart_painter.dart

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class PieChartSection {
  final double value;
  final Color color;
  final String label;

  PieChartSection(this.value, this.color, this.label);
}

class PieChartPainter extends CustomPainter {
  final List<PieChartSection> sections;
  final TextStyle percentageStyle;

  PieChartPainter(
    this.sections, {
    this.percentageStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sections.isEmpty) return;

    final total = sections.map((s) => s.value).fold<double>(0, (a, b) => a + b);
    if (total == 0) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    double startAngle = -pi / 2;

    for (var sec in sections) {
      final sweepAngle = (sec.value / total) * 2 * pi;
      paint.color = sec.color;

      // desenha a fatia
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // --- desenha a porcentagem ---
      final midAngle = startAngle + sweepAngle / 2;
      final textRadius = radius * 0.6;
      final textOffset = Offset(
        center.dx + cos(midAngle) * textRadius,
        center.dy + sin(midAngle) * textRadius,
      );

      final percent = ((sec.value / total) * 100).round();
      final tp = TextPainter(
        text: TextSpan(text: '$percent%', style: percentageStyle),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        textOffset - Offset(tp.width / 2, tp.height / 2),
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter old) {
    // repaint se o conteúdo das fatias mudou
    return !listEquals(old.sections, sections) ||
        old.percentageStyle != percentageStyle;
  }
}
