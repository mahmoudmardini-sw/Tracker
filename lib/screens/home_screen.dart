// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../l10n/app_localizations.dart';

import '../providers/app_provider.dart';
import '../models/skill.dart';
import '../models/milestone.dart';
import '../models/daily_log.dart';
import '../models/habit.dart';
import '../models/habit_record.dart';
import '../constants/motivational_quotes.dart';
import 'add_skill_screen.dart';
import 'add_habit_screen.dart';
import 'daily_log_screen.dart';
import 'skill_detail_screen.dart';
import 'settings_screen.dart';
import 'habit_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['الكل', 'القرآن', 'رياضة', 'Computer Science', 'لغات', 'أخرى'];

  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<AppProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: l10n.filter,
              onPressed: () {
                setState(() {
                  _isFilterVisible = !_isFilterVisible;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: _tabController.index == 0 ? l10n.addSkill : l10n.addHabit,
            onPressed: () {
              if (_tabController.index == 0) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddSkillScreen(categories: _categories.sublist(1)),
                ));
              } else {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddHabitScreen()));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: l10n.achievementsLog,
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
              PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(l10n.settings),
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.auto_awesome), text: l10n.skillsTab),
            Tab(icon: const Icon(Icons.repeat_on_rounded), text: l10n.habitsTab),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SkillsTab(
            categories: _categories,
            isFilterVisible: _isFilterVisible,
          ),
          const HabitsTab(),
        ],
      ),
    );
  }
}

class SkillsTab extends StatelessWidget {
  final List<String> categories;
  final bool isFilterVisible;

  const SkillsTab({
    super.key,
    required this.categories,
    required this.isFilterVisible,
  });

  void _showAddProgressDialog(BuildContext context, Skill skill) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.addProgressTo(skill.name)),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
              decoration: InputDecoration(
                labelText: l10n.addedAmount(skill.unit),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return l10n.pleaseEnterValue;
                if (double.tryParse(value) == null) return l10n.pleaseEnterNumber;
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final value = double.parse(controller.text);
                  final provider = Provider.of<AppProvider>(context, listen: false);

                  skill.spentValue += value;
                  provider.updateSkill(skill);

                  final log = DailyLog(
                    id: const Uuid().v4(),
                    skillId: skill.id,
                    skillName: skill.name,
                    value: value,
                    date: DateTime.now(),
                  );
                  provider.addDailyLog(log);

                  Navigator.pop(context);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final originalCategories = categories;
    final localizedCategories = [l10n.all, ...originalCategories.sublist(1)];

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
              child: Text(getRandomQuote(context), textAlign: TextAlign.center, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600])),
            ),
            Visibility(
              visible: isFilterVisible,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: localizedCategories.map((category) {
                    final originalCategoryValue = (category == l10n.all) ? 'الكل' : category;
                    final isSelected = provider.selectedCategory == originalCategoryValue;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            provider.setSelectedCategory(originalCategoryValue);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: skillsToDisplay.isEmpty
                  ? Center(child: Text(l10n.noSkillsMessage))
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
                          builder: (context) => SkillDetailScreen(skill: skill),
                        ));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(skill.name, style: Theme.of(context).textTheme.titleLarge)),
                                IconButton(
                                  icon: const Icon(Icons.add_task),
                                  tooltip: l10n.addProgress,
                                  onPressed: () => _showAddProgressDialog(context, skill),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(l10n.completed(skill.spentValue.toStringAsFixed(1), skill.requiredValue.toStringAsFixed(1), skill.unit)),
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
  const MilestoneProgressBar({super.key, required this.skill});
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
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: skill.progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: skill.progress == 1.0 ? Colors.green : Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
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
              }),
          ],
        );
      },
    );
  }
}

class HabitsTab extends StatelessWidget {
  const HabitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final habits = provider.habits;
        final List<DateTime> recentDays = List.generate(5, (index) {
          return DateTime.now().subtract(Duration(days: index));
        }).reversed.toList();

        if (habits.isEmpty) {
          return Center(child: Text(l10n.noHabitsMessage));
        }

        final locale = Localizations.localeOf(context).languageCode;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 16.0),
                child: Row(
                  children: [
                    const Expanded(child: SizedBox.shrink()),
                    Row(
                      children: recentDays.map((day) {
                        return SizedBox(
                          width: 50,
                          child: Column(
                            children: [
                              Text(DateFormat('E', locale).format(day), style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => HabitDetailScreen(habit: habit),
          ));
        },
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

class _HabitDayCell extends StatelessWidget {
  final Habit habit;
  final DateTime day;

  const _HabitDayCell({required this.habit, required this.day});

  void _handleTap(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<AppProvider>(context, listen: false);
    final record = provider.getHabitRecordForDay(habit.id, day);

    if (habit.type == HabitType.binary) {
      if (record != null && record.value == BinaryState.done.toString()) {
        provider.removeHabitLog(habit.id, day);
      } else {
        provider.logHabit(HabitRecord(habitId: habit.id, date: day, value: BinaryState.done.toString()));
      }
    } else {
      final countController = TextEditingController(text: record?.value?.toString() ?? '0');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.updateCounterFor(habit.name)),
          content: TextField(
            controller: countController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.theCount), // *** التصحيح هنا ***
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                final int? count = int.tryParse(countController.text);
                if (count != null && count >= 0) {
                  provider.logHabit(HabitRecord(habitId: habit.id, date: day, value: count.toString()));
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
    } else {
      final valueStr = record?.value?.toString() ?? "-";
      final isDone = (int.tryParse(valueStr) ?? 0) > 0;
      cellContent = Text(
        valueStr,
        style: TextStyle(
          fontSize: 16,
          color: isDone ? Theme.of(context).colorScheme.primary : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return InkWell(
      onTap: () => _handleTap(context),
      onLongPress: () => _handleLongPress(context),
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 50,
        height: 50,
        child: Center(child: cellContent),
      ),
    );
  }
}