// lib/models/simulation_result.dart
class Hazard {
  final String type;
  final String instruction;
  final String fullInstruction;
  final String dependsOn;
  final String fullDependsOn;
  final String register;
  final int cycle;

  Hazard({
    required this.type,
    required this.instruction,
    required this.fullInstruction,
    required this.dependsOn,
    required this.fullDependsOn,
    required this.register,
    required this.cycle,
  });

  factory Hazard.fromJson(Map<String, dynamic> json) {
    return Hazard(
      type: json['type'] ?? '',
      instruction: json['instruction'] ?? '',
      fullInstruction: json['full_instruction'] ?? json['instruction'] ?? '',
      dependsOn: json['depends_on'] ?? '',
      fullDependsOn: json['full_depends_on'] ?? json['depends_on'] ?? '',
      register: json['register'] ?? '',
      cycle: json['cycle'] ?? 0,
    );
  }
}

class ApiInstructionTiming {
  final int id;
  final String op;
  final String fullInstruction;
  final int? issue;
  final int? readOperands;
  final int? execStart;
  final int? writeback;

  ApiInstructionTiming({
    required this.id,
    required this.op,
    required this.fullInstruction,
    this.issue,
    this.readOperands,
    this.execStart,
    this.writeback,
  });

  factory ApiInstructionTiming.fromJson(Map<String, dynamic> json) {
    return ApiInstructionTiming(
      id: json['id'] ?? 0,
      op: json['op'] ?? '',
      fullInstruction: json['full_instruction'] ?? json['op'] ?? '',
      issue: json['issue'],
      readOperands: json['read_operands'],
      execStart: json['exec_start'],
      writeback: json['writeback'],
    );
  }
}

class CycleState {
  final int cycle;
  final Map<String, String> instructions;
  final Map<String, bool> functionalUnits;
  final Map<String, String?> registerResult;
  final Map<String, Map<String, dynamic>> reservationStations;
  final Map<String, String?> registerTags;

  CycleState({
    required this.cycle,
    this.instructions = const {},
    this.functionalUnits = const {},
    this.registerResult = const {},
    this.reservationStations = const {},
    this.registerTags = const {},
  });

  factory CycleState.fromJson(Map<String, dynamic> json) {
    return CycleState(
      cycle: json['cycle'] ?? 0,
      instructions: (json['instructions'] ?? {}).cast<String, String>(),
      functionalUnits: (json['functional_units'] ?? {}).cast<String, bool>(),
      registerResult: (json['register_result'] ?? {}).cast<String, String?>(),
      reservationStations: (json['reservation_stations'] ?? {}).cast<String, Map<String, dynamic>>(),
      registerTags: (json['register_tags'] ?? {}).cast<String, String?>(),
    );
  }
}

class SimulationResult {
  final int totalCycles;
  final List<ApiInstructionTiming> timingTable;
  final List<String> logs;
  final List<CycleState> cycleStates;
  final List<Hazard> hazards;

  SimulationResult({
    required this.totalCycles,
    required this.timingTable,
    required this.logs,
    required this.cycleStates,
    required this.hazards,
  });

  factory SimulationResult.fromJson(Map<String, dynamic> json) {
    return SimulationResult(
      totalCycles: json['total_cycles'] ?? 0,
      timingTable: (json['timing_table'] as List? ?? [])
          .map((e) => ApiInstructionTiming.fromJson(e))
          .toList(),
      logs: List<String>.from(json['logs'] ?? []),
      cycleStates: (json['cycle_states'] as List? ?? [])
          .map((e) => CycleState.fromJson(e))
          .toList(),
      hazards: (json['hazards'] as List? ?? [])
          .map((e) => Hazard.fromJson(e))
          .toList(),
    );
  }
}