import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Modelo de cada entrada de barra:
/// - [label]: nome da instituição
/// - [value]: valor numérico
/// - [color]: cor da barra
class BarChartEntry {
  final String label;
  final double value;
  final Color color;

  BarChartEntry(this.label, this.value, this.color);
}

class BarChartPainter extends CustomPainter {
  final List<BarChartEntry> data;
  final double topMargin;
  final double bottomMargin;

  BarChartPainter(
    this.data, {
    this.topMargin = 32.0,
    this.bottomMargin = 48.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final barCount    = data.length;
    final slotWidth   = size.width / barCount;
    final barWidth    = slotWidth * 0.6;
    final usableHeight = size.height - topMargin - bottomMargin;
    final maxValue    = data.map((e) => e.value).fold<double>(0, max);
    if (maxValue <= 0) return;

    final formatter = NumberFormat.simpleCurrency(locale: 'pt_BR');

    for (var i = 0; i < barCount; i++) {
      final entry = data[i];
      final xCenter   = slotWidth * i + slotWidth / 2;
      final barHeight = (entry.value / maxValue) * usableHeight;
      final barTop    = topMargin + (usableHeight - barHeight);
      final barLeft   = xCenter - barWidth / 2;

      // Desenha a barra
      paint.color = entry.color;
      canvas.drawRect(
        Rect.fromLTWH(barLeft, barTop, barWidth, barHeight),
        paint,
      );

      // --- valor acima da barra ---
      final valTp = TextPainter(
        text: TextSpan(
          text: formatter.format(entry.value),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      valTp.paint(
        canvas,
        Offset(xCenter - valTp.width / 2, barTop - valTp.height - 4),
      );

      // --- label abaixo da barra ---
      final labelTp = TextPainter(
        text: TextSpan(
          text: entry.label,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      )..layout(minWidth: barWidth, maxWidth: slotWidth);
      labelTp.paint(
        canvas,
        Offset(xCenter - labelTp.width / 2, size.height - bottomMargin + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter old) =>
      old.data != data ||
      old.topMargin != topMargin ||
      old.bottomMargin != bottomMargin;
}
