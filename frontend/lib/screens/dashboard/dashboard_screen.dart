// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:frontend/screens/scenario/create_scenario_screen.dart';
import 'package:frontend/screens/simulator/simulator_screen.dart';
import 'package:frontend/screens/compare/compare_screen.dart';
import '../../models/scenario.dart';
import '../../models/scenario_store.dart';
import '../../widgets/app_navigation_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScenarioStore _store = ScenarioStore();
  List<Map<String, dynamic>> _savedScenarios = [];
  Set<int> _selectedIds = {};

  final List<Scenario> predefinedScenarios = [
    Scenario(
      id: 1,
      name: "Basic Example",
      mode: "Scoreboard",
      description: "Introduction to RAW dependencies",
      icon: Icons.school,
    ),
    Scenario(
      id: 2,
      name: "Tomasulo Advantage",
      mode: "Tomasulo",
      description: "Out-of-order execution with CDB",
      icon: Icons.rocket_launch,
    ),
    Scenario(
      id: 3,
      name: "Hazard Heavy",
      mode: "Scoreboard",
      description: "Complex hazard scenarios",
      icon: Icons.warning_amber_rounded,
    ),
  ];

  Scenario? selectedScenario;

  @override
  void initState() {
    super.initState();
    _savedScenarios = _store.savedScenarios;
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    setState(() {
      _savedScenarios = _store.savedScenarios;
    });
  }

  // ---------- Helpers ----------
  void _addSavedScenario(Map<String, dynamic> data) {
    _store.addScenario(data);
  }

  void _updateSavedScenario(int id, Map<String, dynamic> newData) {
    _store.updateScenario(id, newData);
  }

  void _deleteSavedScenario(int id) {
    _store.deleteScenario(id);
    _selectedIds.remove(id);
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _onCompare() {
    if (_selectedIds.length != 2) return;
    final selectedData = _savedScenarios
        .where((item) => _selectedIds.contains(item['scenario'].id))
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompareScreen(
          scenarioData1: selectedData[0],
          scenarioData2: selectedData[1],
        ),
      ),
    );
  }

  // ---------- Export Scenario ----------
  Future<void> _exportScenario(Map<String, dynamic> data) async {
    final scenario = data['scenario'] as Scenario;
    final jsonStr = ScenarioStore().exportScenario(data);

    try {
      String? outputFile = await FilePicker.saveFile(
        dialogTitle: 'Save Scenario',
        fileName: '${scenario.name}.aca',
        type: FileType.custom,
        allowedExtensions: ['aca'], // ← FIXED: 'allowedExtensions', not 'extension'
      );
      if (outputFile != null) {
        await File(outputFile).writeAsString(jsonStr);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scenario exported to ${scenario.name}.aca')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompareEnabled = _selectedIds.length == 2;

    return Scaffold(
      appBar: const AppNavigationBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              "Welcome to ACA Lab",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Master dynamic instruction scheduling through interactive simulation",
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // ---------- Quick Tools ----------
            Text("Quick Tools", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildToolCard(
                  label: "New Scenario",
                  icon: Icons.add_rounded,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateScenarioScreen(),
                      ),
                    );
                    if (result != null) {
                      _addSavedScenario(result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Scenario '${result['scenario'].name}' saved!"),
                        ),
                      );
                      if (result['run'] == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SimulatorScreen(
                              scenarioData: result,
                            ),
                          ),
                        );
                      }
                    }
                  },
                  isPrimary: true,
                ),
                const SizedBox(width: 16),
                _buildToolCard(
                  label: "Compare",
                  icon: Icons.compare_arrows_rounded,
                  onTap: isCompareEnabled ? _onCompare : null,
                  isActive: isCompareEnabled,
                ),
                const SizedBox(width: 16),
                _buildToolCard(
                    label: "History", icon: Icons.history_rounded, onTap: () {}),
                const SizedBox(width: 16),
                _buildToolCard(
                    label: "Quiz", icon: Icons.quiz_rounded, onTap: () {}),
              ],
            ),
            const SizedBox(height: 40),

            // ---------- Saved Scenarios ----------
            Text("Saved Scenarios",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            if (_savedScenarios.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No scenarios saved yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Create one with the 'New Scenario' tool above",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._savedScenarios.map((data) => _buildSavedScenarioCard(data)),

            const SizedBox(height: 40),

            // ---------- Predefined Scenarios ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Predefined Scenarios",
                    style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list_rounded, size: 20),
                  label: const Text("Filter"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...predefinedScenarios.map((s) => _buildElegantCard(s)),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // ---------- Widget: Saved Scenario Card ----------
  Widget _buildSavedScenarioCard(Map<String, dynamic> data) {
    final scenario = data['scenario'] as Scenario;
    final instructions = data['instructions'] as String? ?? '';
    final config = data['config'] as Map<String, dynamic>? ?? {};
    final isSelected = _selectedIds.contains(scenario.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.blue.shade400 : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (_) => _toggleSelection(scenario.id),
            activeColor: const Color(0xFF0D47A1),
          ),
          const SizedBox(width: 8),
          // Scenario info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Mode: ${scenario.mode}  •  Instructions: ${instructions.split('\n').where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#')).length}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Row(
            children: [
              // Export
              IconButton(
                icon: const Icon(Icons.download, color: Colors.grey),
                tooltip: 'Export Scenario',
                onPressed: () => _exportScenario(data),
              ),
              // Edit
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black87),
                tooltip: 'Edit Scenario',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateScenarioScreen(
                        initialData: {
                          'scenario': scenario,
                          'instructions': instructions,
                          'config': config,
                        },
                      ),
                    ),
                  );
                  if (result != null) {
                    _updateSavedScenario(scenario.id, result);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Scenario '${result['scenario'].name}' updated!"),
                      ),
                    );
                  }
                },
              ),
              // Delete
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Delete Scenario',
                onPressed: () => _confirmDelete(context, scenario.id, scenario.name),
              ),
              // Run
              IconButton(
                icon: const Icon(Icons.play_arrow, color: Colors.green),
                tooltip: 'Run Simulation',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SimulatorScreen(
                        scenarioData: {
                          'scenario': scenario,
                          'instructions': instructions,
                          'config': config,
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Confirmation Dialog ----------
  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Scenario',
          style: TextStyle(color: Colors.black87),
        ),
        content: Text(
          'Are you sure you want to delete "$name"? This action cannot be undone.',
          style: const TextStyle(color: Colors.black87),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black87,
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSavedScenario(id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Scenario "$name" deleted.'),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade700,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ---------- Tool Card ----------
  Widget _buildToolCard({
    required String label,
    required IconData icon,
    VoidCallback? onTap,
    bool isPrimary = false,
    bool isActive = true,
  }) {
    final color = (isPrimary)
        ? Colors.black87
        : (isActive ? Colors.black87 : Colors.grey.shade400);
    final bgColor = isPrimary
        ? (Colors.white)
        : (isActive ? Colors.white : Colors.grey.shade100);

    return Expanded(
      child: MouseRegion(
        cursor: (onTap != null && isActive) ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: StatefulBuilder(
          builder: (context, setState) {
            bool _isHovered = false;
            return InkWell(
              onTap: (onTap != null && isActive) ? onTap : null,
              onHover: (hovered) {
                setState(() => _isHovered = hovered);
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? (_isHovered ? Colors.grey[800] : Colors.black87)
                      : bgColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isPrimary
                        ? Colors.transparent
                        : (isActive ? Colors.grey.shade200 : Colors.grey.shade300),
                    width: 1,
                  ),
                  boxShadow: isPrimary
                      ? null
                      : (isActive
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ]
                          : null),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 32,
                      color: isPrimary ? Colors.white : color,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isPrimary ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------- Elegant Card ----------
  Widget _buildElegantCard(Scenario scenario) {
    final bool selected = selectedScenario?.id == scenario.id;
    return GestureDetector(
      onTap: () => setState(() => selectedScenario = scenario),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.black87 : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scenario.mode == "Tomasulo"
                    ? const Color(0xFF6366F1).withOpacity(0.1)
                    : const Color(0xFF64748B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                scenario.icon,
                size: 32,
                color: scenario.mode == "Tomasulo"
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scenario.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    scenario.description,
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Mode • ${scenario.mode}",
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}