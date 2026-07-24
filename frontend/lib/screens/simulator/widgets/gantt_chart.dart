// lib/screens/simulator/widgets/gantt_chart.dart
import 'package:flutter/material.dart';
import '../../../models/simulation_models.dart';

class GanttChart extends StatelessWidget {
  final List<InstructionTiming> instructions;
  final int maxCycle;
  final int currentCycle;

  const GanttChart({
    super.key,
    required this.instructions,
    required this.maxCycle,
    required this.currentCycle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Gantt Chart',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(width: 20),
                _legendItem('Issue', Colors.blue.shade300),
                const SizedBox(width: 8),
                _legendItem('Wait', Colors.grey.shade400),
                const SizedBox(width: 8),
                _legendItem('Execute', Colors.green.shade300),
                const SizedBox(width: 8),
                _legendItem('Writeback', Colors.orange.shade300),
              ],
            ),
            const SizedBox(height: 4),
            Expanded(
              child: CustomPaint(
                painter: GanttChartPainter(
                  instructions: instructions,
                  maxCycle: maxCycle,
                  currentCycle: currentCycle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: color.withAlpha(200)),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black87),
        ),
      ],
    );
  }
}

class GanttChartPainter extends CustomPainter {
  final List<InstructionTiming> instructions;
  final int maxCycle;
  final int currentCycle;

  GanttChartPainter({
    required this.instructions,
    required this.maxCycle,
    required this.currentCycle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (instructions.isEmpty) {
      _drawMessage(canvas, size, 'No data');
      return;
    }

    double effectiveWidth = size.width > 10 ? size.width : 500;
    double effectiveHeight = size.height > 10 ? size.height : 200;
    if (size.width <= 10 || size.height <= 10) {
      size = Size(effectiveWidth, effectiveHeight);
    }

    int maxDataCycle = instructions.map((e) => e.writeback).reduce((a, b) => a > b ? a : b);
    final int effectiveMaxCycle = maxCycle > maxDataCycle ? maxCycle : maxDataCycle;
    if (effectiveMaxCycle <= 0) {
      _drawMessage(canvas, size, 'Invalid cycle range');
      return;
    }

    const double paddingLeft = 62;
    const double paddingTop = 16;
    const double paddingBottom = 28;
    final double chartWidth = size.width - paddingLeft;
    final double chartHeight = size.height - paddingTop - paddingBottom;

    if (chartWidth < 10 || chartHeight < 10) {
      _drawMessage(canvas, size, 'Chart area too small');
      return;
    }

    final double rowHeight = chartHeight / instructions.length;
    final double colWidth = chartWidth / (effectiveMaxCycle + 1);
    if (colWidth < 0.5) {
      _drawMessage(canvas, size, 'Column width too small');
      return;
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.5;
    for (int i = 0; i <= effectiveMaxCycle; i += 2) {
      double x = paddingLeft + i * colWidth;
      canvas.drawLine(
        Offset(x, paddingTop),
        Offset(x, size.height - paddingBottom),
        gridPaint,
      );
    }

    // Bars
    for (int i = 0; i < instructions.length; i++) {
      final instr = instructions[i];
      final double y = paddingTop + i * rowHeight + 2;
      final double barHeight = rowHeight - 4;

      final int issue = instr.issue;
      final int execStart = instr.execStart;
      final int execEnd = execStart + instr.latency;
      final int writeback = instr.writeback;

      // ---- Issue bar (blue) ----
      if (issue < effectiveMaxCycle) {
        final int issueEnd = issue + 1; // Issue takes exactly 1 cycle
        final double x1 = paddingLeft + issue * colWidth;
        final double x2 = paddingLeft + issueEnd * colWidth;
        if (x2 > x1) {
          _drawBar(canvas,
            x1: x1,
            x2: x2,
            y: y,
            height: barHeight,
            color: Colors.blue.shade300,
          );
        }
      }

      // ---- Wait bar (grey) - if execStart > issue + 1 (wait in reservation station) ----
      if (execStart > issue + 1) {
        final double x1 = paddingLeft + (issue + 1) * colWidth;
        final double x2 = paddingLeft + execStart * colWidth;
        if (x2 > x1) {
          _drawBar(canvas,
            x1: x1,
            x2: x2,
            y: y,
            height: barHeight,
            color: Colors.grey.shade400,
          );
        }
      }

      // ---- Execute bar (green) ----
      if (execStart < execEnd && execEnd <= effectiveMaxCycle) {
        final double x1 = paddingLeft + execStart * colWidth;
        final double x2 = paddingLeft + execEnd * colWidth;
        if (x2 > x1) {
          _drawBar(canvas,
            x1: x1,
            x2: x2,
            y: y,
            height: barHeight,
            color: Colors.green.shade300,
          );
        }
      }

      // ---- Writeback bar (orange) ----
      if (writeback <= effectiveMaxCycle && writeback > execStart) {
        final double x1 = paddingLeft + writeback * colWidth;
        final double x2 = paddingLeft + (writeback + 1) * colWidth;
        if (x2 > x1) {
          _drawBar(canvas,
            x1: x1,
            x2: x2,
            y: y,
            height: barHeight,
            color: Colors.orange.shade300,
          );
        }
      }

      // Instruction label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: instr.fullInstruction.isNotEmpty ? instr.fullInstruction : 'I${instr.id} ${instr.op}',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(4, y + (barHeight - labelPainter.height) / 2),
      );
    }

    // X-axis labels
    final cycleTextStyle = const TextStyle(fontSize: 9, color: Colors.black54);
    for (int c = 0; c <= effectiveMaxCycle; c += 2) {
      final label = TextPainter(
        text: TextSpan(text: '$c', style: cycleTextStyle),
        textDirection: TextDirection.ltr,
      );
      label.layout();
      final double xPos = paddingLeft + c * colWidth - label.width / 2;
      if (xPos >= paddingLeft && xPos + label.width <= size.width) {
        label.paint(
          canvas,
          Offset(xPos, size.height - paddingBottom + 4),
        );
      }
    }

    // Current cycle indicator
    final currentX = paddingLeft + currentCycle * colWidth;
    if (currentX >= paddingLeft && currentX <= size.width - 2) {
      final linePaint = Paint()
        ..color = Colors.red.shade700.withOpacity(0.9)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(currentX, 0),
        Offset(currentX, size.height),
        linePaint,
      );

      final path = Path();
      path.moveTo(currentX, 6);
      path.lineTo(currentX - 6, 14);
      path.lineTo(currentX + 6, 14);
      path.close();
      canvas.drawPath(path, Paint()..color = Colors.red.shade700);
    }
  }

  void _drawBar(Canvas canvas, {
    required double x1,
    required double x2,
    required double y,
    required double height,
    required Color color,
  }) {
    if (x2 <= x1) return;
    final rect = Rect.fromLTWH(x1, y, x2 - x1, height);
    canvas.drawRect(rect, Paint()..color = color);
    canvas.drawRect(
      rect,
      Paint()
        ..color = color.withAlpha(200)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  void _drawMessage(Canvas canvas, Size size, String msg) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: msg,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant GanttChartPainter oldDelegate) {
    return oldDelegate.instructions != instructions ||
        oldDelegate.maxCycle != maxCycle ||
        oldDelegate.currentCycle != currentCycle;
  }
}