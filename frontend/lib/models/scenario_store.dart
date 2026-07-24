// lib/models/scenario_store.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scenario.dart';

class ScenarioStore extends ChangeNotifier {
  static final ScenarioStore _instance = ScenarioStore._internal();
  factory ScenarioStore() => _instance;
  ScenarioStore._internal();

  List<Map<String, dynamic>> _savedScenarios = [];
  static const String _key = 'saved_scenarios';
  bool _initialized = false;

  List<Map<String, dynamic>> get savedScenarios => _savedScenarios;

  // ---- Initialization ----
  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString(_key);
    if (jsonData != null) {
      try {
        final List<dynamic> data = jsonDecode(jsonData);
        _savedScenarios = data.map((item) {
          // Convert scenario map back to Scenario object
          final scenarioMap = item['scenario'] as Map<String, dynamic>;
          return {
            'scenario': Scenario(
              id: scenarioMap['id'],
              name: scenarioMap['name'],
              mode: scenarioMap['mode'],
              description: scenarioMap['description'] ?? 'Custom scenario',
              icon: Icons.code,
            ),
            'instructions': item['instructions'] ?? '',
            'config': item['config'] ?? {},
          };
        }).toList();
      } catch (e) {
        _savedScenarios = [];
      }
    }
    _initialized = true;
    notifyListeners();
  }

  // ---- CRUD Operations ----
  void addScenario(Map<String, dynamic> data) {
    _savedScenarios.add(data);
    _save();
    notifyListeners();
  }

  void updateScenario(int id, Map<String, dynamic> newData) {
    final index = _savedScenarios.indexWhere(
        (item) => item['scenario'].id == id);
    if (index != -1) {
      _savedScenarios[index] = newData;
      _save();
      notifyListeners();
    }
  }

  void deleteScenario(int id) {
    _savedScenarios.removeWhere((item) => item['scenario'].id == id);
    _save();
    notifyListeners();
  }

  void clear() {
    _savedScenarios.clear();
    _save();
    notifyListeners();
  }

  // ---- Persistence ----
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert to JSON-serializable format (Scenario -> map)
    final List<Map<String, dynamic>> serializable = _savedScenarios.map((item) {
      final scenario = item['scenario'] as Scenario;
      return {
        'scenario': {
          'id': scenario.id,
          'name': scenario.name,
          'mode': scenario.mode,
          'description': scenario.description,
        },
        'instructions': item['instructions'] ?? '',
        'config': item['config'] ?? {},
      };
    }).toList();

    final String jsonData = jsonEncode(serializable);
    await prefs.setString(_key, jsonData);
  }

  // ---- Export / Import ----
  String exportScenario(Map<String, dynamic> data) {
    final scenario = data['scenario'] as Scenario;
    return jsonEncode({
      'name': scenario.name,
      'mode': scenario.mode,
      'instructions': data['instructions'] ?? '',
      'config': data['config'] ?? {},
    });
  }

  void importScenarioFromJson(String jsonStr) {
    final json = jsonDecode(jsonStr);
    final newScenario = Scenario(
      id: DateTime.now().millisecondsSinceEpoch,
      name: json['name'],
      mode: json['mode'],
      description: "Imported scenario",
      icon: Icons.import_export,
    );
    final data = {
      'scenario': newScenario,
      'instructions': json['instructions'],
      'config': json['config'],
    };
    addScenario(data);
  }
}