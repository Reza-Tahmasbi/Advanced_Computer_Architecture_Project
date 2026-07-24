// lib/screens/simulator/widgets/timing_table.dart
import 'package:flutter/material.dart';
import '../../../models/simulation_models.dart';

class TimingTable extends StatelessWidget {
  final List<InstructionTiming> instructions;
  final int currentCycle;

  const TimingTable({
    super.key,
    required this.instructions,
    required this.currentCycle,
  });

  @override
  Widget build(BuildContext context) {
    final visibleInstructions = instructions
        .where((instr) => instr.issue <= currentCycle)
        .toList();

    if (visibleInstructions.isEmpty) {
      return const Center(
        child: Text(
          'No instructions have been issued yet.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instruction Timing Table',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                  (states) => Colors.grey.shade100,
                ),
                columns: const [
                  DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Instruction', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Issue', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('RO', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('EX', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('WB', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: visibleInstructions.map<DataRow>((instr) {
                  final bool issued = instr.issue <= currentCycle;
                  final bool ro = instr.readOperands > 0 && instr.readOperands <= currentCycle;
                  final bool ex = instr.execStart > 0 && instr.execStart <= currentCycle;
                  final bool wb = instr.writeback > 0 && instr.writeback <= currentCycle;

                  Color getColorForStage(bool stageDone) {
                    return stageDone ? Colors.green.shade700 : Colors.grey.shade400;
                  }

                  return DataRow(
                    cells: [
                      DataCell(Text('I${instr.id}')),
                      DataCell(
                        Text(
                          instr.fullInstruction,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Text(
                          instr.issue > 0 ? instr.issue.toString() : '-',
                          style: TextStyle(
                            fontWeight: issued ? FontWeight.bold : FontWeight.normal,
                            color: getColorForStage(issued),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          instr.readOperands > 0 ? instr.readOperands.toString() : '-',
                          style: TextStyle(
                            fontWeight: ro ? FontWeight.bold : FontWeight.normal,
                            color: getColorForStage(ro),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          instr.execStart > 0 ? instr.execStart.toString() : '-',
                          style: TextStyle(
                            fontWeight: ex ? FontWeight.bold : FontWeight.normal,
                            color: getColorForStage(ex),
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          instr.writeback > 0 ? instr.writeback.toString() : '-',
                          style: TextStyle(
                            fontWeight: wb ? FontWeight.bold : FontWeight.normal,
                            color: getColorForStage(wb),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}