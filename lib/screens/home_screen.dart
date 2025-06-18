// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/app_provider.dart';
import '../models/skill.dart';
import '../models/milestone.dart';
import '../models/habit.dart';
import '../models/habit_record.dart';
import '../constants/motivational_quotes.dart';
import 'add_skill_screen.dart';
import 'add_habit_screen.dart';
import 'daily_log_screen.dart';
import 'skill_detail_screen.dart';
import 'settings_screen.dart';
import 'habit_detail_screen.dart'; // <-- إصلاح: إضافة الاستيراد المفقود

// ... HomeScreen Widget ...
// --- الكود الذي لم يتغير ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['الكل', 'القرآن', 'رياضة', 'Computer Science', 'لغات', 'أخرى'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإنجاز'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'سجل الإنجازات',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DailyLogScreen(skills: provider.skills)));
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('الإعدادات'),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.auto_awesome), text: 'المهارات'),
            Tab(icon: Icon(Icons.repeat_on_rounded), text: 'العادات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SkillsTab(categories: _categories),
          HabitsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddSkillScreen(categories: _categories.sublist(1)),
            ));
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddHabitScreen()));
          }
        },
        child: const Icon(Icons.add),
        tooltip: _tabController.index == 0 ? 'إضافة مهارة' : 'إضافة عادة',
      ),
    );
  }
}

// ... SkillsTab & MilestoneProgressBar Widgets ...
// --- الكود الذي لم يتغير ---
class SkillsTab extends StatelessWidget {
  final List<String> categories;
  const SkillsTab({Key? key, required this.categories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        List<Skill> skillsToDisplay = provider.skills;

        if (provider.selectedCategory != 'الكل') {
          skillsToDisplay = skillsToDisplay.where((s) => s.category == provider.selectedCategory).toList();
        }
        if (!provider.showCompletedSkills) {
          skillsToDisplay = skillsToDisplay.where((s) => s.progress < 1.0).toList();
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(getRandomQuote(), textAlign: TextAlign.center, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: provider.selectedCategory == category,
                      onSelected: (selected) {
                        if (selected) {
                          provider.setSelectedCategory(category);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: skillsToDisplay.isEmpty
                  ? const Center(child: Text('لا يوجد مهارات لعرضها.'))
                  : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: skillsToDisplay.length,
                itemBuilder: (context, index) {
                  final skill = skillsToDisplay[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => SkillDetailScreen(
                            skill: skill,
                          ),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(skill.name, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('المنجز: ${skill.spentValue.toStringAsFixed(1)} / ${skill.requiredValue.toStringAsFixed(1)} ${skill.unit}'),
                            const SizedBox(height: 8),
                            MilestoneProgressBar(skill: skill),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class MilestoneProgressBar extends StatelessWidget {
  final Skill skill;
  const MilestoneProgressBar({Key? key, required this.skill}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 8,
              child: LinearProgressIndicator(
                value: skill.progress,
                borderRadius: BorderRadius.circular(4),
                color: skill.progress == 1.0 ? Colors.green : Theme.of(context).primaryColor,
                backgroundColor: Colors.grey.shade300,
              ),
            ),
            if (skill.milestones.isNotEmpty)
              ...skill.milestones
                  .where((m) => m.value > 0 && m.value < skill.requiredValue)
                  .map((milestone) {
                final double percent = milestone.value / skill.requiredValue;
                final bool achieved = skill.spentValue >= milestone.value;
                return Positioned(
                  left: constraints.maxWidth * percent,
                  child: Tooltip(
                    message: "${milestone.description}\n(${milestone.value.toStringAsFixed(1)} ${skill.unit})",
                    child: Container(
                      width: 4,
                      height: 12,
                      decoration: BoxDecoration(
                        color: achieved ? Colors.green.shade700 : Colors.blueGrey.shade500,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Theme.of(context).cardColor, width: 0.5),
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        );
      },
    );
  }
}


// --- _HabitRow Widget (مكان الخطأ الثالث) ---
class _HabitRow extends StatelessWidget {
  final Habit habit;
  final List<DateTime> recentDays;
  const _HabitRow({required this.habit, required this.recentDays});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        // --- هذا هو الإصلاح ---
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => HabitDetailScreen(habit: habit),
          ));
        },
        // --- نهاية الإصلاح ---
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(child: Text(habit.name, style: Theme.of(context).textTheme.titleMedium)),
              Row(
                children: recentDays.map((day) {
                  return _HabitDayCell(habit: habit, day: day);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... HabitsTab & _HabitDayCell Widgets ...
// --- الكود الذي لم يتغير ---
class HabitsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final habits = provider.habits;
        final List<DateTime> recentDays = List.generate(5, (index) {
          return DateTime.now().subtract(Duration(days: index));
        }).reversed.toList();

        if (habits.isEmpty) {
          return const Center(child: Text('لا توجد عادات بعد. قم بإضافة عادة جديدة!'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 16.0),
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    Row(
                      children: recentDays.map((day) {
                        return Container(
                          width: 50,
                          child: Column(
                            children: [
                              Text(DateFormat('E', 'ar_SA').format(day), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(day.day.toString(), style: Theme.of(context).textTheme.bodyLarge),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  return _HabitRow(habit: habit, recentDays: recentDays);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HabitDayCell extends StatelessWidget {
  final Habit habit;
  final DateTime day;

  const _HabitDayCell({required this.habit, required this.day});

  void _handleTap(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final record = provider.getHabitRecordForDay(habit.id, day);

    if (habit.type == HabitType.binary) {
      if (record != null && record.value == BinaryState.done.toString()) {
        provider.removeHabitLog(habit.id, day);
      } else {
        provider.logHabit(HabitRecord(habitId: habit.id, date: day, value: BinaryState.done.toString()));
      }
    } else { // Counter
      final countController = TextEditingController(text: record?.value?.toString() ?? '0');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('تحديث عداد: ${habit.name}'),
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
                  provider.logHabit(HabitRecord(habitId: habit.id, date: day, value: count));
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

  void _handleLongPress(BuildContext context) {
    if (habit.type == HabitType.binary) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final record = provider.getHabitRecordForDay(habit.id, day);

      if (record != null && record.value == BinaryState.skipped.toString()) {
        provider.removeHabitLog(habit.id, day);
      } else {
        provider.logHabit(HabitRecord(habitId: habit.id, date: day, value: BinaryState.skipped.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final record = provider.getHabitRecordForDay(habit.id, day);

    Widget cellContent;
    if (habit.type == HabitType.binary) {
      IconData iconData = Icons.circle_outlined;
      Color iconColor = Colors.grey.shade400;
      if (record != null) {
        if (record.value == BinaryState.done.toString()) {
          iconData = Icons.check_circle;
          iconColor = Colors.green;
        } else if (record.value == BinaryState.skipped.toString()) {
          iconData = Icons.close;
          iconColor = Colors.red.shade400;
        }
      }
      cellContent = Icon(iconData, color: iconColor, size: 24);
    } else { // Counter
      cellContent = Text(
        record?.value?.toString() ?? "-",
        style: TextStyle(
          fontSize: 16,
          color: (record?.value ?? 0) > 0 ? Theme.of(context).colorScheme.primary : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return InkWell(
      onTap: () => _handleTap(context),
      onLongPress: () => _handleLongPress(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        child: cellContent,
      ),
    );
  }
}