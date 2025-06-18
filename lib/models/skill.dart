// lib/models/skill.dart

import 'package:uuid/uuid.dart';
import './milestone.dart';

class Skill {
  String id;
  String name;
  double requiredValue;
  double spentValue;
  String unit;
  String category;
  List<Milestone> milestones;
  List<String> notes;

  // The fix is in this constructor.
  // We are making sure that the notes list is initialized as a mutable list.
  Skill({
    required this.id,
    required this.name,
    required this.requiredValue,
    this.spentValue = 0,
    required this.unit,
    this.category = 'أخرى',
    List<Milestone>? milestones,
    List<String>? notes,
  })  : this.milestones = milestones ?? [],
        this.notes = notes ?? [];

  double get progress {
    if (requiredValue <= 0) {
      return 0.0;
    }
    return (spentValue / requiredValue).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'requiredValue': requiredValue,
    'spentValue': spentValue,
    'unit': unit,
    'category': category,
    'milestones': milestones.map((m) => m.toJson()).toList(),
    'notes': notes,
  };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
    id: json['id'] ?? const Uuid().v4(),
    name: json['name'],
    requiredValue: (json['requiredValue'] as num).toDouble(),
    spentValue: (json['spentValue'] as num?)?.toDouble() ?? 0.0,
    unit: json['unit'] ?? 'ساعة',
    category: json['category'] ?? 'أخرى',
    milestones: (json['milestones'] as List<dynamic>?)
        ?.map((m) => Milestone.fromJson(m))
        .toList() ??
        [],
    notes: (json['notes'] as List<dynamic>?)
        ?.map((n) => n.toString())
        .toList() ??
        [],
  );
}