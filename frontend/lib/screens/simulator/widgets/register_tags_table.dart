// lib/screens/simulator/widgets/register_tags_table.dart
import 'package:flutter/material.dart';
import '../../../models/simulation_models.dart';

class RegisterTagsTable extends StatelessWidget {
  final List<RegisterTag> registerTags;
  final String? mode; // optional

  const RegisterTagsTable({
    super.key,
    required this.registerTags,
    this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final title = mode == 'Scoreboard' ? 'Register Results' : 'Register Tags';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.8,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: registerTags.length,
              itemBuilder: (_, i) {
                final reg = registerTags[i];
                return Container(
                  margin: const EdgeInsets.all(1),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: reg.tag != null ? Colors.blue.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: reg.tag != null ? Colors.blue.shade200 : Colors.grey.shade200,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${reg.reg}: ${reg.tag ?? 'ready'}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: reg.tag != null ? FontWeight.w600 : FontWeight.normal,
                        color: reg.tag != null ? const Color(0xFF0D47A1) : Colors.grey[700],
                      ),
                    ),
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