// lib/services/simulation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/simulation_result.dart' as api;

class SimulationService {
  static const String baseUrl = 'http://localhost:8000';

  Map<String, dynamic> _prepareConfig(Map<String, dynamic> frontendConfig) {
    final fuMap = <String, dynamic>{};
    final latMap = <String, dynamic>{};

    if (frontendConfig['functional_units'] is Map) {
      fuMap.addAll(frontendConfig['functional_units'] as Map<String, dynamic>);
    }
    if (frontendConfig['latencies'] is Map) {
      latMap.addAll(frontendConfig['latencies'] as Map<String, dynamic>);
    }

    final Map<String, dynamic> backendConfig = {
      'registers': ['R0', 'R1', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7', 'R8', 'R9', 'R10'],
      'functional_units': {},
    };

    fuMap.forEach((key, value) {
      int count = 1;
      if (value is int) {
        count = value;
      } else if (value is String) {
        count = int.tryParse(value) ?? 1;
      } else if (value is num) {
        count = value.toInt();
      }

      int latency = 2;
      if (latMap.containsKey(key)) {
        final latValue = latMap[key];
        if (latValue is int) {
          latency = latValue;
        } else if (latValue is String) {
          latency = int.tryParse(latValue) ?? 2;
        } else if (latValue is num) {
          latency = latValue.toInt();
        }
      }

      backendConfig['functional_units'][key] = {
        'count': count,
        'latency': latency,
      };
    });

    return backendConfig;
  }

  Future<api.SimulationResult> runSimulation({
    required String mode,
    required List<String> instructions,
    required Map<String, dynamic> config,
  }) async {
    final backendConfig = _prepareConfig(config);

    final response = await http.post(
      Uri.parse('$baseUrl/run_simulation'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mode': mode,
        'instructions': instructions,
        'config': backendConfig,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return api.SimulationResult.fromJson(data);
    } else {
      throw Exception('Failed to run simulation: ${response.body}');
    }
  }
}