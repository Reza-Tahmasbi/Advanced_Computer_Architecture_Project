// lib/models/scenario.dart
import 'package:flutter/material.dart';

class Scenario {
  final int id;
  final String name;
  final String mode;           // "Scoreboard" or "Tomasulo"
  final String description;
  final IconData icon;

  Scenario({
    required this.id,
    required this.name,
    required this.mode,
    required this.description,
    required this.icon,
  });
}