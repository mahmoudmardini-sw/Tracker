// lib/screens/daily_log_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'dart:collection';

import '../models/daily_log.dart';
import '../models/skill.dart';
import '../models/habit.dart';
import '../models/habit_record.dart';
import '../providers/app_provider.dart';

class DailyLogScreen extends StatefulWidget {
  final List<Skill> skills;
  const DailyLogScreen({Key? key, required this.skills}) : super(key: key);

  @override
  _DailyLogScreenState createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  late final ValueNotifier<List<dynamic>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final LinkedHashMap<DateTime, List<dynamic>> _eventsByDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    final provider = Provider.of<AppProvider>(context, listen: false);

    _eventsByDay = LinkedHashMap<DateTime, List<dynamic>>(
      equals: isSameDay,
      hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
    );

    for (var log in provider.dailyLogs) {
      final day = DateTime.utc(log.date.year, log.date.month, log.date.day);
      _eventsByDay.putIfAbsent(day, () => []).add(log);
    }
    for (var record in provider.habitRecords) {
      final day = DateTime.utc(record.date.year, record.date.month, record.date.day);
      _eventsByDay.putIfAbsent(day, () => []).add(record);
    }

    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _eventsByDay[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  String _getHabitStatus(HabitRecord record) {
    if (record.value is String) {
      if (record.value == BinaryState.done.toString()) return "تم الإنجاز";
      if (record.value == BinaryState.skipped.toString()) return "تم التخطي";
    }
    if (record.value is int) return "العدد: ${record.value}";
    return "غير مسجل";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السجل اليومي الموحد')),
      body: Column(
        children: [
          TableCalendar<dynamic>(
            locale: 'ar_SA',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _selectedEvents.value = _getEventsForDay(selectedDay);
              }
            },
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          ),
          const Divider(height: 1),
          Expanded(
            child: ValueListenableBuilder<List<dynamic>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
                if (events.isEmpty) {
                  return const Center(child: Text('لا توجد سجلات لهذا اليوم.'));
                }

                events.sort((a, b) {
                  DateTime dateA = a is DailyLog ? a.date : a.date;
                  DateTime dateB = b is DailyLog ? b.date : b.date;
                  return dateB.compareTo(dateA);
                });

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    if (event is DailyLog) {
                      final skillUnit = widget.skills.firstWhere((s) => s.id == event.skillId, orElse: () => Skill(id:'', name:'', requiredValue:0, unit: '')).unit;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.auto_awesome, color: Colors.amber),
                          title: Text(event.skillName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("إنجاز: ${event.value.toStringAsFixed(1)} $skillUnit"),
                          trailing: Text(DateFormat.jm('ar_SA').format(event.date)),
                        ),
                      );
                    } else if (event is HabitRecord) {
                      final provider = Provider.of<AppProvider>(context, listen:false);
                      final habit = provider.habits.firstWhere((h) => h.id == event.habitId, orElse: () => Habit(id:'', name: 'عادة محذوفة', type: HabitType.binary));
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.repeat_on_rounded, color: Colors.blue.shade300),
                          title: Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(_getHabitStatus(event)),
                          trailing: Text(DateFormat.jm('ar_SA').format(event.date)),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}