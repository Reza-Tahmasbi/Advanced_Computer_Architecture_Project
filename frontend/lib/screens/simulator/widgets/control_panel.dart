import 'package:flutter/material.dart';

class ControlPanel extends StatelessWidget {
  final int currentCycle;
  final int maxCycle;
  final bool isPlaying;
  final bool isFinished; // NEW
  final VoidCallback onPlayToggle;
  final VoidCallback onStepBack;
  final VoidCallback onStepForward;
  final ValueChanged<int> onSliderChanged;
  final TextEditingController periodController;
  final List<double> waveData;
  final double shiftFraction;
  final Color highColor;
  final Color lowColor;
  final Color backgroundColor;
  final VoidCallback? onEditScenario;

  const ControlPanel({
    super.key,
    required this.currentCycle,
    required this.maxCycle,
    required this.isPlaying,
    required this.isFinished,
    required this.onPlayToggle,
    required this.onStepBack,
    required this.onStepForward,
    required this.onSliderChanged,
    required this.periodController,
    required this.waveData,
    required this.shiftFraction,
    required this.highColor,
    required this.lowColor,
    required this.backgroundColor,
    this.onEditScenario,
  });

  @override
  Widget build(BuildContext context) {
    // Determine status and color
    String statusText;
    Color statusColor;
    if (isFinished) {
      statusText = 'Finished';
      statusColor = Colors.blue.shade700;
    } else if (isPlaying) {
      statusText = 'Running';
      statusColor = Colors.green.shade700;
    } else {
      statusText = 'Paused';
      statusColor = Colors.black87;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          // Edit button
          if (onEditScenario != null)
            IconButton(
              iconSize: 28,
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Scenario',
              onPressed: onEditScenario,
            ),
          // Step buttons
          IconButton(
            iconSize: 28,
            icon: const Icon(Icons.skip_previous),
            onPressed: onStepBack,
          ),
          IconButton(
            iconSize: 40,
            icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
            onPressed: onPlayToggle,
          ),
          IconButton(
            iconSize: 28,
            icon: const Icon(Icons.skip_next),
            onPressed: onStepForward,
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$currentCycle / $maxCycle',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          // Period input
          Container(
            width: 50,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextFormField(
              controller: periodController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
                suffixText: 'ms',
                suffixStyle: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          // ----- STATUS INDICATOR -----
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Slider
          Expanded(
            child: Column(
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF1565C0),
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: const Color(0xFF0D47A1),
                    overlayColor: const Color(0xFF0D47A1).withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: currentCycle.toDouble(),
                    min: 0,
                    max: maxCycle.toDouble(),
                    divisions: maxCycle > 0 ? maxCycle : 1,
                    label: currentCycle.toString(),
                    onChanged: (value) => onSliderChanged(value.toInt()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // CPU Clock
          _CpuClockCompact(
            data: waveData,
            shiftFraction: shiftFraction,
            highColor: highColor,
            lowColor: lowColor,
            backgroundColor: backgroundColor,
            currentCycle: currentCycle,
          ),
        ],
      ),
    );
  }
}

// ----- The rest (_CpuClockCompact and _CpuClockPainter) remains unchanged -----
class _CpuClockCompact extends StatelessWidget {
  final List<double> data;
  final double shiftFraction;
  final Color highColor;
  final Color lowColor;
  final Color backgroundColor;
  final int currentCycle;

  const _CpuClockCompact({
    required this.data,
    required this.shiftFraction,
    required this.highColor,
    required this.lowColor,
    required this.backgroundColor,
    required this.currentCycle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 260,
          height: 70,
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
                color: currentCycle % 2 == 0
                    ? Colors.grey[200]
                    : highColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                currentCycle % 2 == 0 ? 'LOW' : 'HIGH',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: currentCycle % 2 == 0
                      ? Colors.grey[600]
                      : const Color(0xFF0D47A1),
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
