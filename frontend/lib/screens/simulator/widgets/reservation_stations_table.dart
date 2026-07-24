// lib/screens/simulator/widgets/reservation_stations_table.dart
import 'package:flutter/material.dart';
import '../../../models/simulation_models.dart';

class ReservationStationsTable extends StatelessWidget {
  final List<RsState> rsStates;

  const ReservationStationsTable({super.key, required this.rsStates});

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Reservation Stations',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              itemCount: rsStates.length,
              itemBuilder: (_, i) {
                final rs = rsStates[i];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade100),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52,
                        child: Text(
                          rs.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Icon(
                        rs.busy ? Icons.circle : Icons.circle_outlined,
                        color: rs.busy ? Colors.green : Colors.grey,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rs.busy
                              ? 'op:${rs.op ?? ''}  qj:${rs.qj ?? '-'}  qk:${rs.qk ?? '-'}  rem:${rs.remaining}'
                              : 'free',
                          style: const TextStyle(
                            fontSize: 12, // was 11
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
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