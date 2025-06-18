// lib/models/daily_log.dart

import 'package:uuid/uuid.dart';

class DailyLog {
  String id;
  String skillId;
  String skillName;
  double value;
  DateTime date;

  DailyLog({
    required this.id,
    required this.skillId,
    required this.skillName,
    required this.value,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'skillId': skillId,
    'skillName': skillName,
    'value': value,
    'date': date.toIso8601String(),
  };

  factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
    id: json['id'] ?? Uuid().v4(),
    skillId: json['skillId'],
    skillName: json['skillName'],
    value: json['value'],
    date: DateTime.parse(json['date']),
  );
}