// lib/screens/habit_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../models/habit.dart';
import '../models/habit_record.dart'; // <-- إصلاح: إضافة الاستيراد المفقود
import '../providers/app_provider.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;
  const HabitDetailScreen({Key? key, required this.habit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // نستخدم Consumer لضمان تحديث الواجهة عند تغيير البيانات
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final records = provider.habitRecords.where((r) => r.habitId == habit.id).toList();
        records.sort((a, b) => a.date.compareTo(b.date));

        // --- حساب الإحصائيات ---
        int currentStreak = 0;
        int bestStreak = 0;

        if (habit.type == HabitType.binary) {
          int tempStreak = 0;
          // حساب أفضل سلسلة
          if (records.isNotEmpty) {
            for (int i = 0; i < records.length; i++) {
              if (records[i].value == BinaryState.done.toString()) {
                tempStreak++;
                // تحقق من اليوم التالي
                if (i < records.length - 1) {
                  final difference = records[i+1].date.difference(records[i].date).inDays;
                  if (difference > 1) { // إذا كان الفرق أكثر من يوم، انقطعت السلسلة
                    if (tempStreak > bestStreak) bestStreak = tempStreak;
                    tempStreak = 0;
                  }
                }
              } else { // إذا لم تكن "done" انقطعت السلسلة
                if (tempStreak > bestStreak) bestStreak = tempStreak;
                tempStreak = 0;
              }
            }
          }
          if (tempStreak > bestStreak) bestStreak = tempStreak;

          // حساب السلسلة الحالية
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
        // --- نهاية حساب الإحصائيات ---

        return Scaffold(
          appBar: AppBar(title: Text(habit.name)),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (habit.type == HabitType.binary)
                _buildStatsCard(currentStreak, bestStreak),

              const SizedBox(height: 24),
              Text('السجل الشهري', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _buildBarChart(context, records, habit.type),
              const SizedBox(height: 24),

              Text('التقويم', style: Theme.of(context).textTheme.titleLarge),
              Card(
                margin: const EdgeInsets.only(top: 8),
                child: TableCalendar(
                  locale: 'ar_SA',
                  firstDay: records.isNotEmpty ? records.first.date : DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      // --- إصلاح: طريقة آمنة للبحث عن السجل ---
                      HabitRecord? record;
                      try {
                        record = records.firstWhere((r) => isSameDay(r.date, day));
                      } catch (e) {
                        record = null;
                      }
                      // --- نهاية الإصلاح ---

                      if (record != null) {
                        if (record.value == BinaryState.done.toString()) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.green.shade300, shape: BoxShape.circle),
                            child: Center(child: Text(day.day.toString(), style: const TextStyle(color: Colors.white))),
                          );
                        } else if (record.value == BinaryState.skipped.toString()) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.red.shade200, shape: BoxShape.circle),
                            child: Center(child: Text(day.day.toString(), style: const TextStyle(color: Colors.white, decoration: TextDecoration.lineThrough))),
                          );
                        } else if (record.value is int && record.value > 0) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.blue.shade200, shape: BoxShape.circle),
                            child: Center(child: Text(day.day.toString(), style: const TextStyle(color: Colors.white))),
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

  Widget _buildBarChart(BuildContext context, List<HabitRecord> records, HabitType type) {
    final Map<int, double> monthlyData = {};
    for (var record in records) {
      double value = 0;
      if (type == HabitType.binary && record.value == BinaryState.done.toString()) {
        value = 1;
      } else if (type == HabitType.counter && record.value is int) {
        value = (record.value as int).toDouble();
      }
      monthlyData.update(record.date.month, (v) => v + value, ifAbsent: () => value);
    }

    return Container(
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
                  color: Theme.of(context).primaryColor,
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
                getTitlesWidget: (value, meta) {
                  String text = '';
                  try {
                    text = DateFormat('MMM', 'ar_SA').format(DateTime(0, value.toInt()));
                  } catch (e) { text = '';}
                  return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: const TextStyle(fontSize: 12)));
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}