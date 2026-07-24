import 'package:flutter/material.dart';

class CpuClockCompact extends StatelessWidget {
  final List<double> data;
  final double shiftFraction;
  final Color highColor;
  final Color lowColor;
  final Color backgroundColor;
  final double width;
  final double height;
  final int currentCycle; // for the LOW/HIGH label

  const CpuClockCompact({
    super.key,
    required this.data,
    required this.shiftFraction,
    required this.highColor,
    required this.lowColor,
    required this.backgroundColor,
    this.width = 260,
    this.height = 70,
    required this.currentCycle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CustomPaint(
              painter: _CpuClockPainter(
                data: data,
                shiftFraction: shiftFraction,
                highColor: highColor,
                lowColor: lowColor,
                backgroundColor: backgroundColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'CPU Clock',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
            const SizedBox(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: currentCycle % 2 == 0 ? Colors.grey[200] : highColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                currentCycle % 2 == 0 ? 'LOW' : 'HIGH',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: currentCycle % 2 == 0 ? Colors.grey[600] : const Color(0xFF0D47A1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CpuClockPainter extends CustomPainter {
  final List<double> data;
  final double shiftFraction;
  final Color highColor;
  final Color lowColor;
  final Color backgroundColor;

  const _CpuClockPainter({
    required this.data,
    required this.shiftFraction,
    required this.highColor,
    required this.lowColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    final paint = Paint()
      ..color = highColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double stepX = size.width / (data.length - 1);
    final double shiftOffset = shiftFraction * stepX;
    final double midY = size.height / 2;
    const double margin = 8.0;
    final double amplitude = size.height / 2 - margin;

    Path path = Path();
    double lastY = midY;
    for (int i = 0; i < data.length; i++) {
      double x = i * stepX - shiftOffset;
      if (x < -stepX) x = -stepX;
      double y = data[i] == 1.0 ? midY - amplitude : midY + amplitude;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, lastY);
        path.lineTo(x, y);
      }
      lastY = y;
    }
    canvas.drawPath(path, paint);

    final midPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), midPaint);
  }

  @override
  bool shouldRepaint(covariant _CpuClockPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.shiftFraction != shiftFraction;
  }
}