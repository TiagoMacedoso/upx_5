import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BarChartEntry {
  final String label;
  final double value;
  final Color color;
  BarChartEntry(this.label, this.value, this.color);
}

/// Um gráfico de barras “card” rolável horizontalmente.
class HorizontalBarChart extends StatelessWidget {
  final List<BarChartEntry> data;
  final double height;
  final double cardWidth;
  final double maxBarHeight; // altura máxima para a barra dentro do card

  const HorizontalBarChart({
    Key? key,
    required this.data,
    this.height = 200,
    this.cardWidth = 80,
    this.maxBarHeight = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(child: Text('Sem dados')),
      );
    }

    final maxValue = data.map((e) => e.value).reduce((a, b) => b > a ? b : a);
    final formatter = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final e = data[i];
          final barH = maxValue == 0
              ? 0.0
              : (e.value / maxValue) * maxBarHeight;
          return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // valor
                  Text(
                    formatter.format(e.value),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // barra colorida
                  Container(
                    width: cardWidth * 0.6,
                    height: barH,
                    decoration: BoxDecoration(
                      color: e.color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // rótulo
                  Flexible(
                    child: Text(
                      e.label,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
