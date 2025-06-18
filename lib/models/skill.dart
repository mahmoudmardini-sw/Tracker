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

  Skill({
    required this.id,
    required this.name,
    required this.requiredValue,
    this.spentValue = 0,
    required this.unit,
    this.category = 'أخرى',
    this.milestones = const [],
    this.notes = const [],
  });

  double get progress => (requiredValue > 0) ? (spentValue / requiredValue).clamp(0, 1) : 0;

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
    id: json['id'] ?? Uuid().v4(),
    name: json['name'],
    requiredValue: json['requiredValue'],
    spentValue: json['spentValue'] ?? 0.0,
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