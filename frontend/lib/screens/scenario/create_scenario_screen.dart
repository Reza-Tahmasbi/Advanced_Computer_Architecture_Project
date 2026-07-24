// lib/screens/scenario/create_scenario_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../models/scenario.dart';
import '../../widgets/app_navigation_bar.dart';

class CreateScenarioScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const CreateScenarioScreen({super.key, this.initialData});

  @override
  State<CreateScenarioScreen> createState() => _CreateScenarioScreenState();
}

class _CreateScenarioScreenState extends State<CreateScenarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  final ScrollController _textScrollController = ScrollController();
  final ScrollController _lineScrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  String scenarioName = "My Custom Scenario";
  String selectedMode = "Scoreboard";
  String instructions = """LOAD R1 0(R2)
MUL R3 R1 R4
ADD R5 R3 R6
SUB R7 R8 R9
ADD R10 R7 R1
STORE R10 4(R2)""";

  Map<String, int> fuCount = {"ALU": 2, "MULT": 1, "LOAD_STORE": 1};
  Map<String, int> fuLatency = {"ALU": 2, "MULT": 10, "LOAD_STORE": 2};

  int tomasuloRS_ALU = 3;
  int tomasuloRS_MULT = 2;
  int tomasuloRS_LS = 2;

  double _codeHeight = 180.0;
  int? _editingScenarioId;

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      final data = widget.initialData!;
      final scenario = data['scenario'] as Scenario;
      _editingScenarioId = scenario.id;
      scenarioName = scenario.name;
      selectedMode = scenario.mode;
      instructions = data['instructions'] ?? '';
      _codeController.text = instructions;

      final config = data['config'] ?? {};
      if (config['functional_units'] != null) {
        fuCount = Map<String, int>.from(config['functional_units']);
      }
      if (config['latencies'] != null) {
        fuLatency = Map<String, int>.from(config['latencies']);
      }
      if (config['tomasulo_rs'] != null) {
        final rs = config['tomasulo_rs'];
        tomasuloRS_ALU = rs['ALU'] ?? 3;
        tomasuloRS_MULT = rs['MULT'] ?? 2;
        tomasuloRS_LS = rs['LOAD_STORE'] ?? 2;
      }
    } else {
      _codeController.text = instructions;
    }

    _textScrollController.addListener(_syncScroll);
    _lineScrollController.addListener(_syncScrollReverse);
  }

  void _syncScroll() {
    if (_lineScrollController.offset != _textScrollController.offset) {
      _lineScrollController.jumpTo(_textScrollController.offset);
    }
  }

  void _syncScrollReverse() {
    if (_textScrollController.offset != _lineScrollController.offset) {
      _textScrollController.jumpTo(_lineScrollController.offset);
    }
  }

  @override
  void dispose() {
    _textScrollController.removeListener(_syncScroll);
    _lineScrollController.removeListener(_syncScrollReverse);
    _textScrollController.dispose();
    _lineScrollController.dispose();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavigationBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back to Dashboard"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),

              // Scenario Name
              const Text("Scenario Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: scenarioName,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onChanged: (value) => scenarioName = value,
              ),
              const SizedBox(height: 28),

              // Mode Selection
              const Text("Scheduling Mode", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _modeOption("Scoreboard", "Centralized", Icons.account_tree),
                  const SizedBox(width: 12),
                  _modeOption("Tomasulo", "Distributed + CDB", Icons.memory),
                  const SizedBox(width: 12),
                  _modeOption("Speculation", "Out‑of‑order + Branch", Icons.auto_awesome),
                ],
              ),
              const SizedBox(height: 28),

              // Configuration Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          "Configuration",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Functional Units", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              _buildCompactFUCard("ALU", fuCount["ALU"]!, fuLatency["ALU"]!),
                              const SizedBox(height: 8),
                              _buildCompactFUCard("MULT", fuCount["MULT"]!, fuLatency["MULT"]!),
                              const SizedBox(height: 8),
                              _buildCompactFUCard("LOAD_STORE", fuCount["LOAD_STORE"]!, fuLatency["LOAD_STORE"]!),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        if (selectedMode == "Tomasulo" || selectedMode == "Speculation")
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Reservation Stations", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 8),
                                _buildCompactRS("ALU", tomasuloRS_ALU, (v) => setState(() => tomasuloRS_ALU = v)),
                                const SizedBox(height: 8),
                                _buildCompactRS("MULT", tomasuloRS_MULT, (v) => setState(() => tomasuloRS_MULT = v)),
                                const SizedBox(height: 8),
                                _buildCompactRS("LOAD/STORE", tomasuloRS_LS, (v) => setState(() => tomasuloRS_LS = v)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Assembly Program
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Assembly Program", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload File"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: _uploadFile,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: _codeHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: GestureDetector(
                  onTap: () => _focusNode.requestFocus(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEFEFEF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: AbsorbPointer(
                          absorbing: true,
                          child: SingleChildScrollView(
                            controller: _lineScrollController,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: _buildLineNumbers(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          scrollController: _textScrollController,
                          focusNode: _focusNode,
                          maxLines: null,
                          expands: true,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(14),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Color(0xFFF5F5F5),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Drag handle
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _codeHeight = (_codeHeight + details.delta.dy).clamp(80.0, 500.0);
                  });
                },
                child: Container(
                  height: 16,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.drag_handle,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Save & Save & Run buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _saveScenario(run: false),
                      child: const Text("Save", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: Colors.black54),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _saveScenario(run: true),
                      child: const Text("Save & Run", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Line numbers ----
  List<Widget> _buildLineNumbers() {
    final lines = _codeController.text.split('\n');
    return List.generate(
      lines.length,
      (index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        child: Text(
          '${index + 1}',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF888888),
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  // ---- Mode option ----
  Widget _modeOption(String mode, String subtitle, IconData icon) {
    final bool isSelected = selectedMode == mode;
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => selectedMode = mode),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black87 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Icon(icon, size: 36, color: isSelected ? Colors.white : Colors.black87),
                const SizedBox(height: 8),
                Text(mode, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                Text(subtitle, style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- FU card ----
  Widget _buildCompactFUCard(String name, int count, int latency) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.settings, color: Colors.grey[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text("Latency: $latency", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          // Count controls
          Row(
            children: [
              _smallButton(Icons.remove, () => _updateFU(name, -1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("$count", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),
              _smallButton(Icons.add, () => _updateFU(name, 1)),
            ],
          ),
          const SizedBox(width: 12),
          // Latency controls (NEW)
          Row(
            children: [
              _smallButton(Icons.remove, () => _updateLatency(name, -1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  "$latency",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.blue),
                ),
              ),
              _smallButton(Icons.add, () => _updateLatency(name, 1)),
            ],
          ),
        ],
      ),
    );
  }

  // ---- RS card ----
  Widget _buildCompactRS(String name, int count, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.memory, color: Colors.grey[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$name Stations",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Row(
            children: [
              _smallButton(Icons.remove, () => onChanged(count - 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text("$count", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),
              _smallButton(Icons.add, () => onChanged(count + 1)),
            ],
          ),
        ],
      ),
    );
  }

  // ---- small +/- ----
  Widget _smallButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  // ---- update FU count ----
  void _updateFU(String fu, int delta) {
    setState(() {
      fuCount[fu] = (fuCount[fu]! + delta).clamp(1, 10);
    });
  }

  // ---- update FU latency (NEW) ----
  void _updateLatency(String fu, int delta) {
    setState(() {
      fuLatency[fu] = (fuLatency[fu]! + delta).clamp(1, 50);
    });
  }

  // ---- upload file ----
  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );
      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.single.path;
        if (filePath != null) {
          String content = await File(filePath).readAsString();
          setState(() {
            _codeController.text = content;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Loaded: ${result.files.single.name}")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error loading file")),
      );
    }
  }

  // ---- validate instructions ----
  List<String> _validateInstructions(String code) {
    final lines = code.split('\n');
    final errors = <String>[];
    final validOps = {'LOAD', 'MUL', 'ADD', 'SUB', 'STORE', 'DIV', 'AND', 'OR', 'XOR'};

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#')) continue;

      final parts = line.split(RegExp(r'\s+'));
      if (parts.isEmpty) continue;

      final op = parts[0].toUpperCase();
      if (!validOps.contains(op)) {
        errors.add('Line ${i+1}: Unknown opcode "$op"');
        continue;
      }

      if (parts.length < 2) {
        errors.add('Line ${i+1}: Missing operands');
        continue;
      }

      if (op == 'LOAD' || op == 'STORE') {
        if (parts.length != 3) {
          errors.add('Line ${i+1}: $op expects 2 operands (dest, src)');
          continue;
        }
        if (!RegExp(r'^R\d+$').hasMatch(parts[1])) {
          errors.add('Line ${i+1}: Invalid destination register "${parts[1]}"');
        }
        if (!RegExp(r'^-?\d+\(R\d+\)$').hasMatch(parts[2])) {
          errors.add('Line ${i+1}: Invalid memory operand "${parts[2]}" (expected offset(Rbase))');
        }
      } else if (['MUL', 'ADD', 'SUB', 'DIV', 'AND', 'OR', 'XOR'].contains(op)) {
        if (parts.length != 4) {
          errors.add('Line ${i+1}: $op expects 3 register operands');
          continue;
        }
        for (int j = 1; j <= 3; j++) {
          if (!RegExp(r'^R\d+$').hasMatch(parts[j])) {
            errors.add('Line ${i+1}: Invalid register "${parts[j]}"');
          }
        }
      }
    }
    return errors;
  }

  // ---- SAVE SCENARIO ----
  void _saveScenario({bool run = false}) {
    if (_formKey.currentState!.validate() && scenarioName.isNotEmpty) {
      final errors = _validateInstructions(_codeController.text);
      if (errors.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Assembly Syntax Errors',
              style: TextStyle(color: Colors.black87),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: errors.length,
                itemBuilder: (_, idx) => ListTile(
                  leading: const Icon(Icons.error, color: Colors.red),
                  title: Text(errors[idx]),
                ),
              ),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.black87),
                child: const Text('Fix Errors'),
              ),
            ],
          ),
        );
        return;
      }

      final scenarioId = _editingScenarioId ?? DateTime.now().millisecondsSinceEpoch;
      final newScenario = Scenario(
        id: scenarioId,
        name: scenarioName,
        mode: selectedMode,
        description: "Custom scenario",
        icon: Icons.code,
      );

      final resultData = {
        'scenario': newScenario,
        'instructions': _codeController.text,
        'config': {
          'functional_units': fuCount,
          'latencies': fuLatency,
          if (selectedMode == "Tomasulo" || selectedMode == "Speculation")
            'tomasulo_rs': {
              "ALU": tomasuloRS_ALU,
              "MULT": tomasuloRS_MULT,
              "LOAD_STORE": tomasuloRS_LS,
            },
        },
        'run': run,
      };

      Navigator.pop(context, resultData);
    }
  }
}