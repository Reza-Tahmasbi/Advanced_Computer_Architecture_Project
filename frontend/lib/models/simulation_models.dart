// lib/models/simulation_models.dart
class LogEntry {
  final int cycle;
  final String message;
  LogEntry({required this.cycle, required this.message});
}

class InstructionTiming {
  final int id;
  final String op;
  final String fullInstruction;
  final int issue;
  final int readOperands;
  final int execStart;
  final int writeback;
  final int latency;

  InstructionTiming({
    required this.id,
    required this.op,
    required this.fullInstruction,
    required this.issue,
    required this.readOperands,
    required this.execStart,
    required this.writeback,
    required this.latency,
  });
}

class RsState {
  final String name;
  final bool busy;
  final String? op;
  final String? qj;
  final String? qk;
  final int remaining;
  RsState({
    required this.name,
    required this.busy,
    this.op,
    this.qj,
    this.qk,
    this.remaining = 0,
  });
}

class RegisterTag {
  final String reg;
  final String? tag;
  RegisterTag({required this.reg, this.tag});
}