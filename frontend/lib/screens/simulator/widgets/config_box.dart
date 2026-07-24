import 'package:flutter/material.dart';

class ConfigBox extends StatelessWidget {
  final Map<String, int> functionalUnits;
  final Map<String, int> latencies;
  final Map<String, int>? reservationStations;
  final String mode; // new

  const ConfigBox({
    super.key,
    required this.functionalUnits,
    required this.latencies,
    this.reservationStations,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    // Build functional unit chips
    final fuChips = functionalUnits.entries.map((entry) {
      final name = entry.key;
      final count = entry.value;
      final latency = latencies[name] ?? 0;
      return _buildChip(
        icon: Icons.settings,
        label: '$name ×$count',
        subtitle: '${latency}cyc',
        color: Colors.blue.shade50,
        borderColor: Colors.blue.shade200,
      );
    }).toList();

    // Build reservation station chips (if any)
    final rsChips = reservationStations?.entries.map((entry) {
      return _buildChip(
        icon: Icons.storage,
        label: '${entry.key} ×${entry.value}',
        subtitle: 'RS',
        color: Colors.purple.shade50,
        borderColor: Colors.purple.shade200,
      );
    }).toList() ?? [];

    // Mode chip – placed first
    final modeChip = _buildModeChip(mode);

    final allChips = [
      modeChip,
      ...fuChips,
      if (rsChips.isNotEmpty) ...rsChips,
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: allChips,
      ),
    );
  }

  Widget _buildModeChip(String mode) {
    Color color;
    Color borderColor;
    IconData icon;
    switch (mode) {
      case 'Scoreboard':
        color = Colors.blue.shade50;
        borderColor = Colors.blue.shade400;
        icon = Icons.account_tree;
        break;
      case 'Tomasulo':
        color = Colors.purple.shade50;
        borderColor = Colors.purple.shade400;
        icon = Icons.memory;
        break;
      case 'Speculation':
        color = Colors.orange.shade50;
        borderColor = Colors.orange.shade400;
        icon = Icons.auto_awesome;
        break;
      default:
        color = Colors.grey.shade50;
        borderColor = Colors.grey.shade400;
        icon = Icons.help;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: borderColor),
          const SizedBox(width: 6),
          Text(
            mode,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: borderColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: borderColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}