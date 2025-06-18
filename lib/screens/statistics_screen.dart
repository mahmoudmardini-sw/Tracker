// lib/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/skill.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Skill> skills;
  const StatisticsScreen({Key? key, required this.skills}) : super(key: key);

  static const List<Color> pieColors = [
    Colors.blue, Colors.green, Colors.red, Colors.orange, Colors.purple, Colors.teal, Colors.indigo, Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    final totalRequiredValue = skills.fold(0.0, (sum, skill) => sum + skill.requiredValue);

    List<PieChartSectionData> getSections(double total) {
      if (total == 0) return [];
      int colorIndex = 0;
      return skills.map((skill) {
        final double percentage = (skill.requiredValue / total) * 100;
        final color = pieColors[colorIndex % pieColors.length];
        colorIndex++;
        return PieChartSectionData(
          color: color,
          value: skill.requiredValue,
          title: '${skill.name}\n${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        );
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات المهارات'),
      ),
      body: skills.isEmpty
          ? Center(
        child: Text(
          '!أضف بعض المهارات لعرض الإحصائيات',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: PieChart(
                PieChartData(
                  sections: getSections(totalRequiredValue),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              ':توزيع الجهد حسب المهارة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              children: skills.asMap().entries.map((entry) {
                int idx = entry.key;
                Skill skill = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            skill.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Text(
                          '${skill.requiredValue.toStringAsFixed(1)} ${skill.unit}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: pieColors[idx % pieColors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}