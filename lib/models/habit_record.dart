class HabitRecord {
  String habitId;
  DateTime date;
  dynamic value;

  HabitRecord({required this.habitId, required this.date, this.value});

  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'date': date.toIso8601String(),
      'value': value,
    };
  }

  factory HabitRecord.fromJson(Map<String, dynamic> json) {
    return HabitRecord(
      habitId: json['habitId'],
      date: DateTime.parse(json['date']),
      value: json['value'],
    );
  }
}