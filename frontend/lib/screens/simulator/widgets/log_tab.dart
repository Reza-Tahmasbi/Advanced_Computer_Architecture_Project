// lib/screens/simulator/widgets/log_tab.dart
import 'package:flutter/material.dart';
import '../../../models/simulation_models.dart';

class LogTab extends StatefulWidget {
  final List<LogEntry> logs;
  final int currentCycle;
  final ScrollController? scrollController;

  const LogTab({
    super.key,
    required this.logs,
    required this.currentCycle,
    this.scrollController,
  });

  @override
  State<LogTab> createState() => _LogTabState();
}

class _LogTabState extends State<LogTab> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LogTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to bottom when logs or currentCycle changes
    if (oldWidget.logs != widget.logs || oldWidget.currentCycle != widget.currentCycle) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.hasClients) {
        _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter logs up to current cycle
    final visibleLogs = widget.logs.where((log) => log.cycle <= widget.currentCycle).toList();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulation Log',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (visibleLogs.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No logs for this cycle',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _controller,
                itemCount: visibleLogs.length,
                itemBuilder: (_, idx) {
                  final entry = visibleLogs[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '[${entry.cycle}]',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            entry.message,
                            style: TextStyle(
                              fontSize: 13,
                              color: idx == visibleLogs.length - 1 ? Colors.black87 : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
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