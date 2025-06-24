import 'package:uuid/uuid.dart';

enum BinaryState { done, skipped }

enum HabitType { binary, counter }

class Habit {
  String id;
  String name;
  HabitType type;
  String category; // <-- تمت إضافة خاصية التصنيف هنا

  Habit({
    required this.id,
    required this.name,
    required this.type,
    this.category = 'General', // <-- قيمة افتراضية لضمان عدم حدوث أخطاء مع العادات القديمة
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.toString(),
    'category': category, // <-- إضافة الصنف هنا ليتم حفظه
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'] ?? const Uuid().v4(),
    name: json['name'],
    type: HabitType.values.firstWhere(
          (e) => e.toString() == json['type'],
      orElse: () => HabitType.binary,
    ),
    category: json['category'] ?? 'General', // <-- إضافة الصنف هنا ليتم تحميله
  );
}