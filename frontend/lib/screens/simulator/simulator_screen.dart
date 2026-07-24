// lib/screens/simulator/simulator_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/scenario.dart';
import '../../models/simulation_models.dart';
import '../../models/simulation_result.dart' as api;
import '../../models/scenario_store.dart'; // <-- ADD THIS
import '../../widgets/app_navigation_bar.dart';
import '../scenario/create_scenario_screen.dart';
import '../../bloc/simulation_bloc.dart';
import '../../services/simulation_service.dart';
import 'widgets/control_panel.dart';
import 'widgets/config_box.dart';
import 'widgets/gantt_chart.dart';
import 'widgets/reservation_stations_table.dart';
import 'widgets/register_tags_table.dart';
import 'widgets/instruction_distribution_chart.dart';
import 'widgets/performance_metrics.dart';
import 'widgets/log_tab.dart';
import 'widgets/timing_table.dart';
import 'widgets/hazards_table.dart';

class SimulatorScreen extends StatelessWidget {
  final Map<String, dynamic> scenarioData;

  const SimulatorScreen({super.key, required this.scenarioData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SimulationBloc(service: SimulationService()),
      child: SimulatorScreenContent(scenarioData: scenarioData),
    );
  }
}

class SimulatorScreenContent extends StatefulWidget {
  final Map<String, dynamic> scenarioData;

  const SimulatorScreenContent({super.key, required this.scenarioData});

  @override
  State<SimulatorScreenContent> createState() => _SimulatorScreenContentState();
}

class _SimulatorScreenContentState extends State<SimulatorScreenContent>
    with SingleTickerProviderStateMixin {
  late Scenario scenario;
  late String instructions;
  late Map<String, dynamic> config;
  late String mode;

  int currentCycle = 0;
  int maxCycle = 0;
  bool isPlaying = false;

  final TextEditingController _periodController = TextEditingController(text: '400');
  int _periodMs = 400;

  static const int _samplesPerCycle = 6;
  static const int _bufferSize = 80;
  final List<double> _waveData = List.filled(_bufferSize, 0.0);
  late AnimationController _shiftController;
  double _shiftFraction = 0.0;

  api.SimulationResult? _simulationResult;
  List<InstructionTiming> _instructions = [];
  List<LogEntry> _parsedLogs = [];
  List<api.Hazard> _hazards = [];

  List<api.CycleState> _cycleStates = [];
  List<RsState> _rsStates = [];
  List<RegisterTag> _registerTags = [];

  final ScrollController _logScrollController = ScrollController();

  static const Color _darkBlue = Color(0xFF0D47A1);
  static const Color _mediumBlue = Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();

    scenario = widget.scenarioData['scenario'];
    instructions = widget.scenarioData['instructions'];
    config = widget.scenarioData['config'];
    mode = scenario.mode;

    final lines = instructions
        .split('\n')
        .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#'));
    maxCycle = lines.length * 3 + 5;

    _shiftController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _periodMs),
    )..addListener(() {
        setState(() => _shiftFraction = _shiftController.value);
      });
    _shiftController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _addNextValue();
        _shiftController.reset();
        if (isPlaying) {
          _shiftController.duration = Duration(milliseconds: _periodMs);
          _shiftController.forward();
        }
      }
    });

    for (int i = 0; i < _bufferSize; i++) _waveData[i] = 0.0;
    _updateBufferForCycle(0);

    _runSimulation();
  }

  @override
  void dispose() {
    _shiftController.dispose();
    _periodController.dispose();
    _logScrollController.dispose();
    super.dispose();
  }

  void _runSimulation() {
    final lines = instructions
        .split('\n')
        .where((l) => l.trim().isNotEmpty && !l.trim().startsWith('#'))
        .toList();

    context.read<SimulationBloc>().add(
      RunSimulation(mode: mode, instructions: lines, config: config),
    );
  }

  void _appendValueRepeated(double value) {
    for (int i = 0; i < _samplesPerCycle; i++) {
      for (int j = 0; j < _bufferSize - 1; j++) {
        _waveData[j] = _waveData[j + 1];
      }
      _waveData[_bufferSize - 1] = value;
    }
  }

  void _updateBufferForCycle(int cycle) {
    int totalSamples = _bufferSize;
    for (int i = 0; i < totalSamples; i++) {
      int cycleIndex =
          cycle - (totalSamples ~/ _samplesPerCycle) + (i ~/ _samplesPerCycle);
      if (cycleIndex < 0) {
        _waveData[i] = 0.0;
      } else {
        _waveData[i] = (cycleIndex % 2 == 0) ? 0.0 : 1.0;
      }
    }
    _shiftFraction = 0.0;
    _shiftController.value = 0.0;
  }

  void _addNextValue() {
    if (currentCycle < maxCycle) {
      setState(() {
        currentCycle++;
        double newValue = (currentCycle % 2 == 0) ? 0.0 : 1.0;
        _appendValueRepeated(newValue);
        _updateStateForCycle(currentCycle);
      });
    } else {
      setState(() => isPlaying = false);
      _shiftController.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Simulation finished')),
      );
    }
  }

  void _goToCycle(int cycle) {
    if (cycle < 0 || cycle > maxCycle) return;
    setState(() {
      currentCycle = cycle;
      _updateBufferForCycle(cycle);
      _updateStateForCycle(cycle);
    });
  }

  void _togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        final text = _periodController.text.trim();
        final int? newPeriod = int.tryParse(text);
        if (newPeriod != null && newPeriod > 0) {
          _periodMs = newPeriod;
          _shiftController.duration = Duration(milliseconds: _periodMs);
        } else {
          _periodController.text = '400';
          _periodMs = 400;
          _shiftController.duration = const Duration(milliseconds: 400);
        }
        if (currentCycle >= maxCycle) {
          currentCycle = 0;
          _updateBufferForCycle(0);
          _updateStateForCycle(0);
        }
        _shiftController.forward(from: 0.0);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auto‑play started (${_periodMs}ms period)'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        _shiftController.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paused'), duration: Duration(seconds: 1)),
        );
      }
    });
  }

  // ========== FIXED: Edit Scenario ==========
  void _editScenario() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateScenarioScreen(
          initialData: {
            'scenario': scenario,
            'instructions': instructions,
            'config': config,
          },
        ),
      ),
    );

    if (result != null) {
      // 1. Update the scenario in the store (so dashboard sees changes)
      ScenarioStore().updateScenario(scenario.id, result);
      
      // 2. Replace current screen with new simulator using updated data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SimulatorScreen(
            scenarioData: result,
          ),
        ),
      );
    }
  }

  List<InstructionTiming> _convertApiTiming(
    List<api.ApiInstructionTiming> apiTiming,
  ) {
    return apiTiming.map((api) {
      int latency = 0;
      if (api.execStart != null && api.writeback != null) {
        latency = api.writeback! - api.execStart! + 1;
      } else if (api.execStart != null) {
        latency = 1;
      } else {
        latency = 2;
      }
      return InstructionTiming(
        id: api.id,
        op: api.op,
        fullInstruction: api.fullInstruction ?? api.op,
        issue: api.issue ?? 0,
        readOperands: api.readOperands ?? 0,
        execStart: api.execStart ?? 0,
        writeback: api.writeback ?? 0,
        latency: latency,
      );
    }).toList();
  }

  List<LogEntry> _parseLogs(List<String> rawLogs) {
    final entries = <LogEntry>[];
    int currentCycle = 0;
    for (var line in rawLogs) {
      final cycleMatch = RegExp(r'--- Cycle (\d+)').firstMatch(line);
      if (cycleMatch != null) {
        currentCycle = int.parse(cycleMatch.group(1)!);
        continue;
      }
      if (line.trim().isEmpty) continue;
      entries.add(LogEntry(cycle: currentCycle, message: line.trim()));
    }
    return entries;
  }

  void _updateStateForCycle(int cycle) {
    if (_cycleStates.isEmpty) return;

    api.CycleState? snapshot;
    for (var s in _cycleStates) {
      if (s.cycle <= cycle) {
        snapshot = s;
      } else {
        break;
      }
    }
    if (snapshot == null) return;

    if (mode == 'Tomasulo' || mode == 'Speculation') {
      final rsList = <RsState>[];
      snapshot.reservationStations.forEach((name, data) {
        final busy = data['busy'] as bool? ?? false;
        rsList.add(
          RsState(
            name: name,
            busy: busy,
            op: data['op'] as String?,
            qj: data['qj'] as String?,
            qk: data['qk'] as String?,
            remaining: data['remaining'] as int? ?? 0,
          ),
        );
      });
      final tags = snapshot.registerTags.entries.map((e) {
        return RegisterTag(reg: e.key, tag: e.value);
      }).toList();

      setState(() {
        _rsStates = rsList;
        _registerTags = tags;
      });
    } else {
      final tags = snapshot.registerResult.entries.map((e) {
        return RegisterTag(reg: e.key, tag: e.value);
      }).toList();
      setState(() {
        _registerTags = tags;
        _rsStates = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SimulationBloc, SimulationState>(
      listener: (context, state) {
        if (state is SimulationLoaded) {
          setState(() {
            _simulationResult = state.result;
            _instructions = _convertApiTiming(state.result.timingTable);
            maxCycle = state.result.totalCycles;
            _parsedLogs = _parseLogs(state.result.logs);
            _cycleStates = state.result.cycleStates;
            _hazards = state.result.hazards;
            _updateStateForCycle(0);
          });
        } else if (state is SimulationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<SimulationBloc, SimulationState>(
        builder: (context, state) {
          if (state is SimulationLoading) {
            return const Scaffold(
              appBar: AppNavigationBar(),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildMainUI();
        },
      ),
    );
  }

  Widget _buildMainUI() {
    Map<String, int> fuMap = {};
    if (config['functional_units'] is Map) {
      fuMap = Map<String, int>.from(config['functional_units']);
    }
    Map<String, int> latMap = {};
    if (config['latencies'] is Map) {
      latMap = Map<String, int>.from(config['latencies']);
    }
    Map<String, int>? rsMap;
    if (config.containsKey('tomasulo_rs') && config['tomasulo_rs'] is Map) {
      rsMap = Map<String, int>.from(config['tomasulo_rs']);
    }

    final bool isFinished = currentCycle >= maxCycle && maxCycle > 0;

    return Scaffold(
      appBar: const AppNavigationBar(),
      body: Column(
        children: [
          ControlPanel(
            currentCycle: currentCycle,
            maxCycle: maxCycle,
            isPlaying: isPlaying,
            isFinished: isFinished,
            onPlayToggle: _togglePlay,
            onStepBack: () => _goToCycle(currentCycle - 1),
            onStepForward: () => _goToCycle(currentCycle + 1),
            onSliderChanged: (value) {
              setState(() {
                currentCycle = value;
                _updateBufferForCycle(currentCycle);
                _updateStateForCycle(currentCycle);
              });
            },
            periodController: _periodController,
            waveData: _waveData,
            shiftFraction: _shiftFraction,
            highColor: _mediumBlue,
            lowColor: Colors.grey.shade300,
            backgroundColor: Colors.white,
            onEditScenario: _editScenario,
          ),
          ConfigBox(
            functionalUnits: fuMap,
            latencies: latMap,
            reservationStations: rsMap,
            mode: mode,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DefaultTabController(
                        length: 6,
                        child: Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: TabBar(
                                isScrollable: true,
                                labelColor: const Color(0xFF0D47A1),
                                unselectedLabelColor: Colors.grey,
                                indicatorColor: const Color(0xFF0D47A1),
                                indicatorSize: TabBarIndicatorSize.label,
                                tabs: const [
                                  Tab(text: 'Gantt'),
                                  Tab(text: 'Timing'),
                                  Tab(text: 'Distribution'),
                                  Tab(text: 'Metrics'),
                                  Tab(text: 'Hazards'),
                                  Tab(text: 'Log'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  GanttChart(
                                    instructions: _instructions.isNotEmpty
                                        ? _instructions
                                        : _getDummyInstructions(),
                                    maxCycle: maxCycle,
                                    currentCycle: currentCycle,
                                  ),
                                  TimingTable(
                                    instructions: _instructions.isNotEmpty
                                        ? _instructions
                                        : _getDummyInstructions(),
                                    currentCycle: currentCycle,
                                  ),
                                  InstructionDistributionChart(
                                    instructions: _instructions.isNotEmpty
                                        ? _instructions
                                        : _getDummyInstructions(),
                                  ),
                                  PerformanceMetrics(
                                    instructions: _instructions.isNotEmpty
                                        ? _instructions
                                        : _getDummyInstructions(),
                                    maxCycle: maxCycle,
                                    currentCycle: currentCycle,
                                  ),
                                  HazardsTable(
                                    hazards: _hazards,
                                    instructions: _instructions.isNotEmpty
                                        ? _instructions
                                        : _getDummyInstructions(),
                                  ),
                                  LogTab(
                                    logs: _parsedLogs.isNotEmpty
                                        ? _parsedLogs
                                        : [
                                            LogEntry(
                                              cycle: 0,
                                              message: 'No logs yet.',
                                            ),
                                          ],
                                    currentCycle: currentCycle,
                                    scrollController: _logScrollController,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        if (mode != 'Scoreboard')
                          Expanded(
                            child: ReservationStationsTable(
                              rsStates: _rsStates,
                            ),
                          ),
                        Expanded(
                          child: RegisterTagsTable(
                            registerTags: _registerTags,
                            mode: mode,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<InstructionTiming> _getDummyInstructions() {
    return [
      InstructionTiming(
        id: 1,
        op: 'LOAD',
        fullInstruction: 'LOAD R1 0(R2)',
        issue: 1,
        readOperands: 2,
        execStart: 2,
        writeback: 3,
        latency: 2,
      ),
      InstructionTiming(
        id: 2,
        op: 'MUL',
        fullInstruction: 'MUL R3 R1 R4',
        issue: 2,
        readOperands: 4,
        execStart: 4,
        writeback: 13,
        latency: 10,
      ),
      InstructionTiming(
        id: 3,
        op: 'ADD',
        fullInstruction: 'ADD R5 R3 R6',
        issue: 3,
        readOperands: 14,
        execStart: 14,
        writeback: 15,
        latency: 2,
      ),
      InstructionTiming(
        id: 4,
        op: 'SUB',
        fullInstruction: 'SUB R7 R8 R9',
        issue: 4,
        readOperands: 5,
        execStart: 5,
        writeback: 6,
        latency: 2,
      ),
      InstructionTiming(
        id: 5,
        op: 'ADD',
        fullInstruction: 'ADD R10 R7 R1',
        issue: 7,
        readOperands: 8,
        execStart: 8,
        writeback: 9,
        latency: 2,
      ),
      InstructionTiming(
        id: 6,
        op: 'STORE',
        fullInstruction: 'STORE R10 4(R2)',
        issue: 5,
        readOperands: 6,
        execStart: 6,
        writeback: 7,
        latency: 2,
      ),
    ];
  }
}