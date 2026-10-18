import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Entrada genérica para los gráficos (una porción del pastel o una barra).
class ChartEntry {
  final String label;
  final double value;
  final Color color;

  const ChartEntry({
    required this.label,
    required this.value,
    required this.color,
  });
}

/// Gráfico de pastel tipo dona, dibujado sin dependencias externas.
class DonutChart extends StatelessWidget {
  final List<ChartEntry> entries;
  final double size;
  final Color textColor;
  final String centerLabel;

  const DonutChart({
    super.key,
    required this.entries,
    this.size = 180,
    this.textColor = const Color(0xFF193A22),
    this.centerLabel = 'reservas',
  });

  @override
  Widget build(BuildContext context) {
    final visible = entries.where((e) => e.value > 0).toList();
    final total = visible.fold<double>(0, (sum, e) => sum + e.value);

    if (total <= 0) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: Text('Sin datos para graficar', textAlign: TextAlign.center),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(
          entries: visible,
          total: total,
          textColor: textColor,
          centerLabel: centerLabel,
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<ChartEntry> entries;
  final double total;
  final Color textColor;
  final String centerLabel;

  _DonutPainter({
    required this.entries,
    required this.total,
    required this.textColor,
    required this.centerLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.2;
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: radius,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    var start = -math.pi / 2;
    for (final entry in entries) {
      final sweep = (entry.value / total) * 2 * math.pi;
      paint.color = entry.color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }

    final painter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: total.toStringAsFixed(0),
            style: TextStyle(
              fontSize: size.width * 0.17,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          TextSpan(
            text: '\n$centerLabel',
            style: TextStyle(
              fontSize: size.width * 0.075,
              color: textColor.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    painter.paint(
      canvas,
      Offset(
        (size.width - painter.width) / 2,
        (size.height - painter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.total != total ||
        oldDelegate.entries != entries ||
        oldDelegate.textColor != textColor;
  }
}

/// Gráfico de barras horizontales construido con widgets (sin dependencias).
class HorizontalBarChart extends StatelessWidget {
  final List<ChartEntry> entries;
  final double barHeight;
  final Color trackColor;

  const HorizontalBarChart({
    super.key,
    required this.entries,
    this.barHeight = 12,
    this.trackColor = const Color(0xFFE8EDEA),
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Sin datos para graficar')),
      );
    }

    final maxValue = entries.fold<double>(
      0,
      (max, entry) => math.max(max, entry.value),
    );

    return Column(
      children: [
        for (final entry in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF193A22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.value.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: entry.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(barHeight / 2),
                  child: LinearProgressIndicator(
                    value: maxValue > 0 ? (entry.value / maxValue) : 0,
                    minHeight: barHeight,
                    backgroundColor: trackColor,
                    color: entry.color,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
