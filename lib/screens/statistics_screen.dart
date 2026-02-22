import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../providers/app_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key}); // لاحظ هنا: أزلنا الحاجة لتمرير skills

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isAr = provider.appLocale.languageCode == 'ar';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 1. حساب ملخص البيانات
    final totalSkills = provider.skills.length;
    final completedSkills = provider.skills.where((s) => s.progress >= 1.0).length;
    final inProgressSkills = provider.skills.where((s) => s.progress > 0 && s.progress < 1.0).length;
    final notStartedSkills = provider.skills.where((s) => s.progress == 0).length;
    final totalHabits = provider.habits.length;
    final totalLogs = provider.dailyLogs.length + provider.habitRecords.length;

    // 2. تجهيز بيانات آخر 7 أيام للرسم البياني الشريطي
    final List<DateTime> last7Days = List.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });

    List<BarChartGroupData> barGroups = [];
    double maxY = 0;

    for (int i = 0; i < last7Days.length; i++) {
      final day = last7Days[i];
      // حساب عدد العادات المنجزة في هذا اليوم
      int completedHabitsCount = provider.habitRecords.where((record) {
        if (!isSameDay(record.date, day)) return false;
        if (record.value == 'BinaryState.done') return true;
        final count = int.tryParse(record.value.toString());
        return count != null && count > 0;
      }).length;

      if (completedHabitsCount > maxY) maxY = completedHabitsCount.toDouble();

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: completedHabitsCount.toDouble(),
              color: isDarkMode ? Colors.tealAccent : Colors.teal,
              width: 16,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'الإحصائيات والأداء' : 'Statistics & Performance'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // القسم الأول: بطاقات الملخص
          Text(
            isAr ? 'نظرة عامة' : 'Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSummaryCard(
                  context,
                  title: isAr ? 'إجمالي المهارات' : 'Total Skills',
                  value: totalSkills.toString(),
                  icon: Icons.auto_awesome,
                  color: Colors.blue
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                  context,
                  title: isAr ? 'إجمالي العادات' : 'Total Habits',
                  value: totalHabits.toString(),
                  icon: Icons.repeat_on_rounded,
                  color: Colors.orange
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                  context,
                  title: isAr ? 'سجلات الإنجاز' : 'Total Logs',
                  value: totalLogs.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green
              ),
            ],
          ),
          const SizedBox(height: 32),

          // القسم الثاني: أداء العادات في آخر 7 أيام (Bar Chart)
          Text(
            isAr ? 'أداء العادات (آخر 7 أيام)' : 'Habits Performance (Last 7 Days)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY < 5 ? 5 : maxY + 1, // تحديد أعلى نقطة في الرسم
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final date = last7Days[value.toInt()];
                        final locale = isAr ? 'ar' : 'en';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('E', locale).format(date),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // القسم الثالث: حالة المهارات (Pie Chart)
          if (totalSkills > 0) ...[
            Text(
              isAr ? 'حالة المهارات' : 'Skills Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                  sections: [
                    if (completedSkills > 0)
                      PieChartSectionData(
                        color: Colors.green,
                        value: completedSkills.toDouble(),
                        title: '${((completedSkills / totalSkills) * 100).toStringAsFixed(0)}%',
                        radius: 60,
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    if (inProgressSkills > 0)
                      PieChartSectionData(
                        color: Colors.blue,
                        value: inProgressSkills.toDouble(),
                        title: '${((inProgressSkills / totalSkills) * 100).toStringAsFixed(0)}%',
                        radius: 60,
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    if (notStartedSkills > 0)
                      PieChartSectionData(
                        color: Colors.grey,
                        value: notStartedSkills.toDouble(),
                        title: '${((notStartedSkills / totalSkills) * 100).toStringAsFixed(0)}%',
                        radius: 60,
                        titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // مفتاح الألوان (Legend)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(color: Colors.green, text: isAr ? 'مكتملة' : 'Completed'),
                const SizedBox(width: 16),
                _buildLegendItem(color: Colors.blue, text: isAr ? 'قيد الإنجاز' : 'In Progress'),
                const SizedBox(width: 16),
                _buildLegendItem(color: Colors.grey, text: isAr ? 'لم تبدأ' : 'Not Started'),
              ],
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(isAr ? 'لا توجد مهارات مضافة بعد.' : 'No skills added yet.'),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ودجت فرعية لرسم بطاقات الملخص
  Widget _buildSummaryCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDarkMode ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ودجت فرعية لمفتاح ألوان الدائرة
  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}