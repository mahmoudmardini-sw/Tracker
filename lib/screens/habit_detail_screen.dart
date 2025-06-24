// lib/screens/habit_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
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

  void _showDeleteConfirmationDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteConfirmationTitle),
          content: Text(l10n.deleteHabitConfirmation(widget.habit.name)),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<AppProvider>(context, listen: false)
                    .removeHabit(widget.habit.id);
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleDayTap(BuildContext context, DateTime day) {
    final l10n = AppLocalizations.of(context)!;
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
          title: Text(l10n.updateCounterFor(widget.habit.name)),
          content: TextField(
            controller: countController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.theCount),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                final int? count = int.tryParse(countController.text);
                if (count != null && count >= 0) {
                  provider.logHabit(HabitRecord(habitId: widget.habit.id, date: day, value: count.toString()));
                }
                Navigator.pop(context);
              },
              child: Text(l10n.save),
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
      } else if (type == HabitType.counter && record.value is num) {
        value = (record.value as num).toDouble();
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
                  color: isDarkMode ? Colors.teal.shade300 : Theme.of(context).primaryColor,
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
                reservedSize: 48, // <-- هذا هو السطر الذي تم تعديله لإصلاح الخطأ
                getTitlesWidget: (double value, TitleMeta meta) {
                  final month = value.toInt();
                  final year = DateTime.now().year.toString().substring(2);
                  final text = Column(
                    children: [
                      Text(month.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 12)),
                      Text(year, style: const TextStyle(fontSize: 10)),
                    ],
                  );
                  return Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: text,
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
    // This should also be localized if you want to support multiple languages fully
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text("Current Streak", style: TextStyle(color: Colors.grey.shade600)),
                Text('$current days', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              children: [
                Text("Best Streak", style: TextStyle(color: Colors.grey.shade600)),
                Text('$best days', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final habitExists = provider.habits.any((h) => h.id == widget.habit.id);
        if (!habitExists) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text("This habit has been deleted.")),
          );
        }

        final records = provider.habitRecords.where((r) => r.habitId == widget.habit.id).toList();
        records.sort((a, b) => a.date.compareTo(b.date));

        int currentStreak = 0;
        int bestStreak = 0;

        if (widget.habit.type == HabitType.binary) {
          int tempStreak = 0;
          final doneRecords = records.where((r) => r.value == BinaryState.done.toString()).toList();
          if (doneRecords.isNotEmpty) {
            for (int i = 0; i < doneRecords.length; i++) {
              tempStreak++;
              if (i < doneRecords.length - 1) {
                final difference = doneRecords[i+1].date.difference(doneRecords[i].date).inDays;
                if (difference > 1) {
                  if (tempStreak > bestStreak) bestStreak = tempStreak;
                  tempStreak = 0;
                }
              }
            }
            if (tempStreak > bestStreak) bestStreak = tempStreak;

            DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
            DateTime yesterday = today.subtract(const Duration(days: 1));
            bool todayDone = doneRecords.any((r) => isSameDay(r.date, today));

            if(todayDone || doneRecords.any((r) => isSameDay(r.date, yesterday))) {
              currentStreak = 0;
              DateTime checkDay = todayDone ? today : yesterday;
              while(doneRecords.any((r) => isSameDay(r.date, checkDay))) {
                currentStreak++;
                checkDay = checkDay.subtract(const Duration(days: 1));
              }
            }
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.habit.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.deleteHabitTooltip,
                onPressed: _showDeleteConfirmationDialog,
              )
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (widget.habit.type == HabitType.binary)
                _buildStatsCard(currentStreak, bestStreak),

              const SizedBox(height: 24),
              Text("Monthly Log", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildBarChart(context, records, widget.habit.type, isDarkMode),
              const SizedBox(height: 24),

              Text("Calendar", style: Theme.of(context).textTheme.titleLarge),
              Card(
                margin: const EdgeInsets.only(top: 8),
                child: TableCalendar(
                  locale: l10n.localeName,
                  firstDay: DateTime.utc(DateTime.now().year - 1, 1, 1),
                  lastDay: DateTime.utc(DateTime.now().year + 1, 12, 31),
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
                        TextStyle textStyle = TextStyle(
                          color: isDarkMode ? Colors.black87 : Colors.white,
                          fontWeight: FontWeight.bold,
                        );

                        if (record.value == BinaryState.done.toString()) {
                          decorationColor = isDarkMode ? Colors.green.shade300 : Colors.green;
                        } else if (record.value == BinaryState.skipped.toString()) {
                          decorationColor = isDarkMode ? Colors.red.shade300 : Colors.red;
                          textStyle = textStyle.copyWith(decoration: TextDecoration.lineThrough);
                        } else {
                          final count = num.tryParse(record.value.toString());
                          if(count != null && count > 0) {
                            decorationColor = isDarkMode ? Colors.blue.shade300 : Colors.blue;
                            return Container(
                              margin: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                color: decorationColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  record.value.toString(),
                                  style: textStyle.copyWith(fontSize: 12),
                                ),
                              ),
                            );
                          }
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