import 'package:flutter/material.dart';
import '../../../models/simulation_models.dart';

class PerformanceMetrics extends StatelessWidget {
  final List<InstructionTiming> instructions;
  final int maxCycle;
  final int currentCycle;

  const PerformanceMetrics({
    super.key,
    required this.instructions,
    required this.maxCycle,
    required this.currentCycle,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = _computeMetrics();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 2.5,
              children: metrics.entries.map((entry) {
                return _MetricCard(
                  label: entry.key,
                  value: entry.value,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _computeMetrics() {
    if (instructions.isEmpty) {
      return {
        'Total Instructions': '0',
        'Unique Ops': '0',
        'Max Cycle': '0',
        'Avg Latency': '0',
        'Issue Rate': '0.0',
        'Current Progress': '0%',
      };
    }

    final total = instructions.length;
    final uniqueOps = instructions.map((e) => e.op).toSet().length;
    final avgLatency = instructions.map((e) => e.latency).reduce((a, b) => a + b) / total;
    final maxC = instructions.map((e) => e.writeback).reduce((a, b) => a > b ? a : b);
    final issueRate = total / (maxCycle + 1);
    final progress = maxCycle > 0 ? (currentCycle / maxCycle * 100) : 0;

    return {
      'Total Instructions': total.toString(),
      'Unique Ops': uniqueOps.toString(),
      'Max Cycle': maxC.toString(),
      'Avg Latency': avgLatency.toStringAsFixed(1),
      'Issue Rate': issueRate.toStringAsFixed(2),
      'Current Progress': '${progress.toStringAsFixed(0)}%',
    };
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const _MetricCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}