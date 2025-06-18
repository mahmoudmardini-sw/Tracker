import 'package:uuid/uuid.dart';

// enum لحالة العادة الثنائية: تمت، تم تخطيها
enum BinaryState { done, skipped }

enum HabitType { binary, counter }

class Habit {
  String id;
  String name;
  HabitType type;

  Habit({required this.id, required this.name, required this.type});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.toString(),
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'] ?? Uuid().v4(),
    name: json['name'],
    type: HabitType.values.firstWhere(
          (e) => e.toString() == json['type'],
      orElse: () => HabitType.binary,
    ),
  );
}