// lib/screens/habit_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/habit.dart';
import '../models/habit_record.dart';
import '../providers/app_provider.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _handleDayTap(BuildContext context, DateTime day) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final record = provider.getHabitRecordForDay(widget.habit.id, day);

    if (day.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يمكن تسجيل إنجاز في المستقبل.'))
      );
      return;
    }

    if (widget.habit.type == HabitType.binary) {
      if (record != null && record.value == BinaryState.done.toString()) {
        provider.removeHabitLog(widget.habit.id, day);
      } else {
        provider.logHabit(HabitRecord(habitId: widget.habit.id, date: day, value: BinaryState.done.toString()));
      }
    } else {
      final countController = TextEditingController(text: record?.value?.toString() ?? '0');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('تحديث عداد: ${widget.habit.name}'),
          content: TextField(
            controller: countController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'العدد'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                final int? count = int.tryParse(countController.text);
                if (count != null && count >= 0) {
                  provider.logHabit(HabitRecord(habitId: widget.habit.id, date: day, value: count.toString()));
                }
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBarChart(BuildContext context, List<HabitRecord> records, HabitType type, bool isDarkMode) {
    final Map<int, double> monthlyData = {};
    for (var record in records) {
      double value = 0;
      if (type == HabitType.binary && record.value == BinaryState.done.toString()) {
        value = 1;
      } else if (type == HabitType.counter && record.value is String) {
        value = double.tryParse(record.value) ?? 0.0;
      }
      monthlyData.update(record.date.month, (v) => v + value, ifAbsent: () => value);
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: List.generate(12, (index) {
            int month = index + 1;
            return BarChartGroupData(
              x: month,
              barRods: [
                BarChartRodData(
                  toY: monthlyData[month] ?? 0,
                  color: isDarkMode ? Colors.deepPurple.shade300 : Theme.of(context).primaryColor,
                  width: 15,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                )
              ],
            );
          }),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final month = value.toInt();
                  final year = DateTime.now().year.toString().substring(2);
                  final text = '${month.toString().padLeft(2, '0')}.$year';
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(text, style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }

  Widget _buildStatsCard(int current, int best) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text('السلسلة الحالية', style: TextStyle(color: Colors.grey.shade600)),
                Text('$current أيام', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              children: [
                Text('أفضل سلسلة', style: TextStyle(color: Colors.grey.shade600)),
                Text('$best أيام', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final records = provider.habitRecords.where((r) => r.habitId == widget.habit.id).toList();
        records.sort((a, b) => a.date.compareTo(b.date));

        int currentStreak = 0;
        int bestStreak = 0;

        if (widget.habit.type == HabitType.binary) {
          int tempStreak = 0;
          if (records.isNotEmpty) {
            for (int i = 0; i < records.length; i++) {
              if (records[i].value == BinaryState.done.toString()) {
                tempStreak++;
                if (i < records.length - 1) {
                  final difference = records[i+1].date.difference(records[i].date).inDays;
                  if (difference > 1) {
                    if (tempStreak > bestStreak) bestStreak = tempStreak;
                    tempStreak = 0;
                  }
                }
              } else {
                if (tempStreak > bestStreak) bestStreak = tempStreak;
                tempStreak = 0;
              }
            }
          }
          if (tempStreak > bestStreak) bestStreak = tempStreak;

          DateTime checkDay = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
          if (records.any((r) => isSameDay(r.date, checkDay) && r.value == BinaryState.done.toString())) {
            currentStreak = 1;
            while(true) {
              checkDay = checkDay.subtract(const Duration(days: 1));
              if (records.any((r) => isSameDay(r.date, checkDay) && r.value == BinaryState.done.toString())) {
                currentStreak++;
              } else {
                break;
              }
            }
          }
        }

        return Scaffold(
          appBar: AppBar(title: Text(widget.habit.name)),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (widget.habit.type == HabitType.binary)
                _buildStatsCard(currentStreak, bestStreak),

              const SizedBox(height: 24),
              Text('السجل الشهري', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildBarChart(context, records, widget.habit.type, isDarkMode),
              const SizedBox(height: 24),

              Text('التقويم', style: Theme.of(context).textTheme.titleLarge),
              Card(
                margin: const EdgeInsets.only(top: 8),
                child: TableCalendar(
                  locale: 'ar_SA',
                  firstDay: DateTime.utc(DateTime.now().year - 1, DateTime.now().month),
                  lastDay: DateTime.utc(DateTime.now().year + 1, DateTime.now().month),
                  focusedDay: _focusedDay,
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                      _selectedDay = selectedDay;
                    });
                    _handleDayTap(context, selectedDay);
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      final record = provider.getHabitRecordForDay(widget.habit.id, day);
                      if (record != null) {
                        Color? decorationColor;
                        TextStyle textStyle = TextStyle(color: isDarkMode ? Colors.black87 : Colors.white);

                        if (record.value == BinaryState.done.toString()) {
                          decorationColor = isDarkMode ? Colors.green.shade300 : Colors.green;
                        } else if (record.value == BinaryState.skipped.toString()) {
                          decorationColor = isDarkMode ? Colors.red.shade300 : Colors.red;
                          textStyle = textStyle.copyWith(decoration: TextDecoration.lineThrough);
                        } else if (record.value is String && (double.tryParse(record.value) ?? 0) > 0) {
                          decorationColor = isDarkMode ? Colors.blue.shade300 : Colors.blue;
                        }

                        if (decorationColor != null) {
                          return Container(
                            margin: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: decorationColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(day.day.toString(), style: textStyle),
                            ),
                          );
                        }
                      }
                      return null;
                    },
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}