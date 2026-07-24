// lib/screens/simulator/widgets/hazards_table.dart
import 'package:flutter/material.dart';
import '../../../models/simulation_result.dart';
import '../../../models/simulation_models.dart';

class HazardsTable extends StatelessWidget {
  final List<Hazard> hazards;
  final List<InstructionTiming> instructions;

  const HazardsTable({
    super.key,
    required this.hazards,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Hazard Table
          Expanded(
            flex: 2,
            child: _buildHazardTable(),
          ),
          const SizedBox(width: 16),
          // Right: Instruction Program
          Expanded(
            flex: 1,
            child: _buildInstructionProgram(),
          ),
        ],
      ),
    );
  }

  Widget _buildHazardTable() {
    if (hazards.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'No hazards detected.',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'All dependencies were resolved efficiently.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detected Hazards',
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
                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Instruction', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Depends On', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Register', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Cycle', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: hazards.map((hazard) {
                Color getColorForType(String type) {
                  switch (type) {
                    case 'RAW':
                      return Colors.orange.shade700;
                    case 'WAW':
                      return Colors.red.shade700;
                    case 'WAR':
                      return Colors.purple.shade700;
                    default:
                      return Colors.grey;
                  }
                }
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        hazard.type,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: getColorForType(hazard.type),
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        hazard.fullInstruction.isNotEmpty ? hazard.fullInstruction : hazard.instruction,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(
                      Text(
                        hazard.fullDependsOn.isNotEmpty ? hazard.fullDependsOn : hazard.dependsOn,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    DataCell(Text(hazard.register)),
                    DataCell(Text(hazard.cycle.toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionProgram() {
    if (instructions.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.code, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No instructions loaded.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instruction Program',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: instructions.length,
              itemBuilder: (context, index) {
                final instr = instructions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    'I${instr.id}: ${instr.fullInstruction}',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}