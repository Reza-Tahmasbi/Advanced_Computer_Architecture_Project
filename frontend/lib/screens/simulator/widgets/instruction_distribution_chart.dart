import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/simulation_models.dart';

class InstructionDistributionChart extends StatelessWidget {
  final List<InstructionTiming> instructions;

  const InstructionDistributionChart({
    super.key,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    final distribution = _countInstructions(instructions);
    if (distribution.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            'No instruction data available',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    final total = distribution.values.reduce((a, b) => a + b);
    final entries = distribution.entries.toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instruction Type Distribution',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sections: entries.map((entry) {
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: '${(entry.value / total * 100).toStringAsFixed(0)}%',
                          color: _getColorForInstruction(entry.key),
                          radius: 140,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          showTitle: true,
                          borderSide: const BorderSide(color: Colors.white, width: 0),
                        );
                      }).toList(),
                      sectionsSpace: 4,
                      centerSpaceRadius: 0,
                      startDegreeOffset: -90,
                      borderData: FlBorderData(show: false),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                        enabled: true,
                      ),
                    ),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entries.map((entry) {
                        final percentage = (entry.value / total * 100);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _getColorForInstruction(entry.key),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${entry.key}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _countInstructions(List<InstructionTiming> instructions) {
    final counts = <String, int>{};
    for (final instr in instructions) {
      counts[instr.op] = (counts[instr.op] ?? 0) + 1;
    }
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  Color _getColorForInstruction(String op) {
    switch (op) {
      case 'LOAD': return Colors.blue.shade600;
      case 'STORE': return Colors.orange.shade600;
      case 'MUL': return Colors.purple.shade600;
      case 'DIV': return Colors.red.shade600;
      case 'ADD': return Colors.green.shade600;
      case 'SUB': return Colors.teal.shade600;
      case 'AND': return Colors.indigo.shade600;
      case 'OR': return Colors.pink.shade600;
      case 'XOR': return Colors.cyan.shade600;
      default: return Colors.grey.shade600;
    }
  }
}