import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/skill.dart';
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

  @override
  Widget build(BuildContext context) {
    // نستخدم Consumer ليستمع للتغييرات ويعيد بناء الواجهة عند إضافة/حذف ملاحظة
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // نبحث عن أحدث نسخة من المهارة من الـ Provider
        final skill = provider.skills.firstWhere((s) => s.id == widget.skill.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(skill.name),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // قسم الأهداف المرحلية (لم يتغير)
              _buildSectionTitle('الأهداف المرحلية'),
              if (skill.milestones.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('لم يتم تحديد أهداف مرحلية لهذه المهارة.'),
                )
              else
                ...skill.milestones.map((milestone) {
                  bool isAchieved = skill.spentValue >= milestone.value;
                  return ListTile(/* ... */);
                }),

              const Divider(height: 32, thickness: 1),

              // قسم الملاحظات
              _buildSectionTitle('الملاحظات'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(
                          labelText: 'أضف ملاحظة جديدة',
                          border: OutlineInputBorder(),
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
                const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('لا توجد ملاحظات بعد.'),
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