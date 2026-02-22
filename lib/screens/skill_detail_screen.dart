import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/skill.dart';
import '../models/daily_log.dart';
import '../providers/app_provider.dart';

class SkillDetailScreen extends StatefulWidget {
  final Skill skill;

  const SkillDetailScreen({
    Key? key,
    required this.skill,
  }) : super(key: key);

  @override
  _SkillDetailScreenState createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  final _noteController = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addNote() {
    if (_noteController.text.trim().isNotEmpty) {
      Provider.of<AppProvider>(context, listen: false)
          .addNoteToSkill(widget.skill.id, _noteController.text.trim());
      _noteController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _removeNoteAt(int index) {
    Provider.of<AppProvider>(context, listen: false)
        .removeNoteFromSkill(widget.skill.id, index);
  }

  void _showDeleteConfirmationDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteConfirmationTitle),
          content: Text(l10n.deleteSkillConfirmation(widget.skill.name)),
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
                    .removeSkill(widget.skill.id);
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // نافذة تسجيل إنجاز ليوم محدد من التقويم
  void _showAddProgressForDayDialog(BuildContext context, DateTime day, bool isAr) {
    final l10n = AppLocalizations.of(context)!;

    if (day.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr ? 'لا يمكن تسجيل إنجاز في المستقبل ⏳' : 'Cannot log a future date ⏳'),
            backgroundColor: Colors.orange,
          )
      );
      return;
    }

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isAr
              ? 'إنجاز يوم ${DateFormat('yyyy/MM/dd').format(day)}'
              : 'Log for ${DateFormat('yyyy/MM/dd').format(day)}'
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: isAr ? 'الكمية المضافة (${widget.skill.unit})' : 'Added Amount (${widget.skill.unit})',
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

                  // تحديث القيمة الكلية للمهارة
                  final skillToUpdate = provider.skills.firstWhere((s) => s.id == widget.skill.id);
                  skillToUpdate.spentValue += value;
                  provider.updateSkill(skillToUpdate);

                  // إضافة سجل يومي للتاريخ المختار
                  final log = DailyLog(
                    id: const Uuid().v4(),
                    skillId: skillToUpdate.id,
                    skillName: skillToUpdate.name,
                    value: value,
                    date: day,
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

  Widget _buildStatsCard(int current, int best, bool isAr) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                    const SizedBox(width: 4),
                    Text(isAr ? "الستريك الحالي" : "Current Streak", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('$current ${isAr ? "أيام" : "Days"}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ],
            ),
            Container(width: 1, height: 50, color: Colors.grey.shade300),
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                    const SizedBox(width: 4),
                    Text(isAr ? "أفضل ستريك" : "Best Streak", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('$best ${isAr ? "أيام" : "Days"}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
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
        final isAr = provider.appLocale.languageCode == 'ar';

        // التحقق من أن المهارة لم تحذف
        final skillExists = provider.skills.any((s) => s.id == widget.skill.id);
        if (!skillExists) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(isAr ? "تم حذف هذه المهارة." : "This skill has been deleted.")),
          );
        }

        final skill = provider.skills.firstWhere((s) => s.id == widget.skill.id);

        // --- خوارزمية الستريك للمهارات ---
        // جلب السجلات الخاصة بهذه المهارة فقط
        final skillLogs = provider.dailyLogs.where((l) => l.skillId == skill.id).toList();

        // استخراج الأيام التي تم فيها إنجاز كمية أكبر من صفر
        Set<DateTime> loggedDates = skillLogs
            .where((l) => l.value > 0)
            .map((l) => DateTime(l.date.year, l.date.month, l.date.day))
            .toSet();

        List<DateTime> sortedDates = loggedDates.toList()..sort((a, b) => b.compareTo(a));

        int currentStreak = 0;
        int bestStreak = 0;
        int tempStreak = 0;

        if (sortedDates.isNotEmpty) {
          tempStreak = 1;
          bestStreak = 1;
          for (int i = 0; i < sortedDates.length - 1; i++) {
            if (sortedDates[i].difference(sortedDates[i+1]).inDays == 1) {
              tempStreak++;
              if (tempStreak > bestStreak) bestStreak = tempStreak;
            } else {
              tempStreak = 1;
            }
          }
        }

        DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        DateTime yesterday = today.subtract(const Duration(days: 1));

        if (loggedDates.contains(today)) {
          currentStreak = 1;
          DateTime check = yesterday;
          while(loggedDates.contains(check)) {
            currentStreak++;
            check = check.subtract(const Duration(days: 1));
          }
        } else if (loggedDates.contains(yesterday)) {
          currentStreak = 1;
          DateTime check = yesterday.subtract(const Duration(days: 1));
          while(loggedDates.contains(check)) {
            currentStreak++;
            check = check.subtract(const Duration(days: 1));
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(skill.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.deleteSkillTooltip,
                onPressed: _showDeleteConfirmationDialog,
              )
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. بطاقة الستريك
              _buildStatsCard(currentStreak, bestStreak, isAr),
              const SizedBox(height: 24),

              // 2. التقويم التفاعلي للمهارة
              Text(isAr ? "سجل الإنجاز (التقويم)" : "Progress Log (Calendar)", style: Theme.of(context).textTheme.titleLarge),
              Card(
                margin: const EdgeInsets.only(top: 8, bottom: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TableCalendar(
                    locale: l10n.localeName,
                    firstDay: DateTime.utc(DateTime.now().year - 1, 1, 1),
                    lastDay: DateTime.now(),
                    focusedDay: _focusedDay,
                    headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                        _selectedDay = selectedDay;
                      });
                      // فتح نافذة لتسجيل الإنجاز في هذا اليوم
                      _showAddProgressForDayDialog(context, selectedDay, isAr);
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        DateTime dateOnly = DateTime(day.year, day.month, day.day);
                        if (loggedDates.contains(dateOnly)) {
                          return Container(
                            margin: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.green.shade700 : Colors.green.shade400,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                day.day.toString(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),

              // 3. الأهداف المرحلية (Milestones)
              _buildSectionTitle(isAr ? 'الأهداف المرحلية' : 'Milestones'),
              if (skill.milestones.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(isAr ? 'لم يتم تحديد أهداف مرحلية لهذه المهارة.' : 'No milestones set for this skill.'),
                )
              else
                ...skill.milestones.map((milestone) {
                  bool isAchieved = skill.spentValue >= milestone.value;
                  return ListTile(
                    leading: Icon(
                      isAchieved ? Icons.check_circle : Icons.flag_circle_outlined,
                      color: isAchieved ? Colors.green : Theme.of(context).colorScheme.secondary,
                    ),
                    title: Text(milestone.description),
                    trailing: Text('${milestone.value.toStringAsFixed(1)} ${skill.unit}'),
                  );
                }),

              const Divider(height: 32, thickness: 1),

              // 4. الملاحظات (Notes)
              _buildSectionTitle(isAr ? 'الملاحظات' : 'Notes'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: isAr ? 'أضف ملاحظة جديدة' : 'Add a new note',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.add_comment),
                      onPressed: _addNote,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (skill.notes.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(isAr ? 'لا توجد ملاحظات بعد.' : 'No notes yet.'),
                ))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: skill.notes.length,
                  itemBuilder: (context, index) {
                    final note = skill.notes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(note),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                          onPressed: () => _removeNoteAt(index),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold));
  }
}