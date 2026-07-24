// lib/screens/compare/compare_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/scenario.dart';
import '../../models/simulation_models.dart';

class CompareScreen extends StatelessWidget {
  final Map<String, dynamic> scenarioData1;
  final Map<String, dynamic> scenarioData2;

  const CompareScreen({
    super.key,
    required this.scenarioData1,
    required this.scenarioData2,
  });

  @override
  Widget build(BuildContext context) {
    final s1 = scenarioData1['scenario'] as Scenario;
    final s2 = scenarioData2['scenario'] as Scenario;
    final instr1 = scenarioData1['instructions'] as String? ?? '';
    final instr2 = scenarioData2['instructions'] as String? ?? '';
    final config1 = scenarioData1['config'] as Map<String, dynamic>? ?? {};
    final config2 = scenarioData2['config'] as Map<String, dynamic>? ?? {};

    // SAFE CASTING: convert Map<String, dynamic> to Map<String, int>
    final fuMap1 = _safeCastMap(config1['functional_units']);
    final fuMap2 = _safeCastMap(config2['functional_units']);
    final latMap1 = _safeCastMap(config1['latencies']);
    final latMap2 = _safeCastMap(config2['latencies']);

    final totalFU1 = fuMap1.values.fold(0, (a, b) => a + b);
    final totalFU2 = fuMap2.values.fold(0, (a, b) => a + b);

    final avgLatency1 = latMap1.isNotEmpty
        ? latMap1.values.fold(0, (a, b) => a + b) / latMap1.length
        : 0.0;
    final avgLatency2 = latMap2.isNotEmpty
        ? latMap2.values.fold(0, (a, b) => a + b) / latMap2.length
        : 0.0;

    final count1 = _countInstructions(instr1);
    final count2 = _countInstructions(instr2);

    final dist1 = _instructionDistribution(instr1);
    final dist2 = _instructionDistribution(instr2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Scenarios'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scenario Comparison',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Comparing "${s1.name}" vs "${s2.name}"',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Overview Cards
            Row(
              children: [
                _overviewCard(s1, count1, totalFU1, avgLatency1),
                const SizedBox(width: 16),
                _overviewCard(s2, count2, totalFU2, avgLatency2),
              ],
            ),
            const SizedBox(height: 32),

            // Distribution Charts
            const Text(
              'Instruction Distribution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _distributionChart(dist1, s1.name)),
                const SizedBox(width: 16),
                Expanded(child: _distributionChart(dist2, s2.name)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Safe type casting ----------
  Map<String, int> _safeCastMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, int>) return value;
    if (value is Map<String, dynamic>) {
      // Convert dynamic to int safely
      final result = <String, int>{};
      value.forEach((key, val) {
        if (val is int) {
          result[key] = val;
        } else if (val is String) {
          result[key] = int.tryParse(val) ?? 0;
        } else if (val is num) {
          result[key] = val.toInt();
        }
      });
      return result;
    }
    return {};
  }

  Widget _overviewCard(Scenario scenario, int count, int totalFU, double avgLatency) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scenario.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _infoRow('Mode', scenario.mode),
            _infoRow('Instructions', count.toString()),
            _infoRow('Functional Units', totalFU.toString()),
            _infoRow('Avg Latency', avgLatency.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  int _countInstructions(String code) {
    return code.split('\n')
        .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#')).length;
  }

  Map<String, int> _instructionDistribution(String code) {
    final lines = code.split('\n')
        .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#'));
    final counts = <String, int>{};
    for (final line in lines) {
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        final op = parts[0].toUpperCase();
        counts[op] = (counts[op] ?? 0) + 1;
      }
    }
    return counts;
  }

  Widget _distributionChart(Map<String, int> dist, String title) {
    final total = dist.values.fold(0, (a, b) => a + b);
    final entries = dist.entries.toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: entries.map((e) {
                  return PieChartSectionData(
                    value: e.value.toDouble(),
                    title: (e.value / total * 100).toStringAsFixed(0) + '%',
                    color: _getColor(e.key),
                    radius: 60,
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 0,
              ),
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(String op) {
    switch (op) {
      case 'LOAD': return Colors.blue.shade500;
      case 'STORE': return Colors.orange.shade500;
      case 'MUL': return Colors.purple.shade500;
      case 'DIV': return Colors.red.shade500;
      case 'ADD': return Colors.green.shade500;
      case 'SUB': return Colors.teal.shade500;
      case 'AND': return Colors.indigo.shade500;
      case 'OR': return Colors.pink.shade500;
      case 'XOR': return Colors.cyan.shade500;
      default: return Colors.grey.shade500;
    }
  }
}