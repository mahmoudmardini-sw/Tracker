import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/skill.dart';
import '../models/milestone.dart';
import '../providers/app_provider.dart';

class AddSkillScreen extends StatefulWidget {
  const AddSkillScreen({Key? key}) : super(key: key);

  @override
  _AddSkillScreenState createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _requiredController = TextEditingController();
  final _spentController = TextEditingController();
  final _categoryController = TextEditingController();

  final List<TextEditingController> _milestoneValueControllers = [];
  final List<TextEditingController> _milestoneDescControllers = [];

  final List<String> _units = [
    'ساعة', 'صفحة', 'سورة', 'كتاب', 'جلسة تدريبية', 'تكرار', 'مجموعة',
    'دقيقة', 'كيلو متر', 'خطوة', 'جزء', 'فصل', 'مقال',
  ];
  late String _selectedUnit;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _selectedUnit = provider.defaultUnit;
    if (provider.skillCategories.isNotEmpty) {
      _selectedCategory = provider.skillCategories.first;
    }
    _spentController.text = '0.0';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _requiredController.dispose();
    _spentController.dispose();
    _categoryController.dispose();
    for (var controller in _milestoneValueControllers) {
      controller.dispose();
    }
    for (var controller in _milestoneDescControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة صنف جديد'),
        content: TextField(
          controller: _categoryController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'اسم الصنف'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (_categoryController.text.trim().isNotEmpty) {
                final provider = Provider.of<AppProvider>(context, listen: false);
                final newCategory = _categoryController.text.trim();
                provider.addSkillCategory(newCategory);
                setState(() {
                  _selectedCategory = newCategory;
                });
                _categoryController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _addMilestoneField() {
    setState(() {
      _milestoneValueControllers.add(TextEditingController());
      _milestoneDescControllers.add(TextEditingController());
    });
  }

  void _removeMilestoneField(int index) {
    setState(() {
      _milestoneValueControllers[index].dispose();
      _milestoneDescControllers[index].dispose();
      _milestoneValueControllers.removeAt(index);
      _milestoneDescControllers.removeAt(index);
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      List<Milestone> milestones = [];
      for (int i = 0; i < _milestoneValueControllers.length; i++) {
        final value = double.tryParse(_milestoneValueControllers[i].text);
        final description = _milestoneDescControllers[i].text;
        if (value != null && description.trim().isNotEmpty) {
          milestones.add(Milestone(value: value, description: description.trim()));
        }
      }
      milestones.sort((a, b) => a.value.compareTo(b.value));

      final newSkill = Skill(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        requiredValue: double.parse(_requiredController.text),
        spentValue: double.tryParse(_spentController.text) ?? 0.0,
        unit: _selectedUnit,
        category: _selectedCategory!,
        milestones: milestones,
      );

      Provider.of<AppProvider>(context, listen: false).addSkill(newSkill);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مهارة جديدة')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم المهارة', border: OutlineInputBorder()),
              validator: (v) => v == null || v.trim().isEmpty ? 'لا يمكن ترك الاسم فارغاً' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    validator: (v) => v == null ? 'الرجاء اختيار صنف' : null,
                    decoration: const InputDecoration(labelText: 'الصنف', border: OutlineInputBorder()),
                    items: provider.skillCategories
                        .map((String category) => DropdownMenuItem<String>(value: category, child: Text(category)))
                        .toList(),
                    onChanged: (newValue) => setState(() => _selectedCategory = newValue),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _showAddCategoryDialog,
                  tooltip: 'إضافة صنف جديد',
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              items: _units.map((String unit) => DropdownMenuItem<String>(value: unit, child: Text(unit))).toList(),
              onChanged: (newValue) => setState(() => _selectedUnit = newValue!),
              decoration: const InputDecoration(labelText: 'الوحدة', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _requiredController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'الهدف النهائي (الكمية المطلوبة)', border: OutlineInputBorder()),
              validator: (v) => v == null || (double.tryParse(v) ?? 0) <= 0 ? 'أدخل رقماً موجباً' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _spentController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'الكمية المنجزة حالياً', border: OutlineInputBorder()),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'أدخل رقماً موجباً أو صفراً';
                final val = double.tryParse(v);
                if (val == null || val < 0) return 'أدخل رقماً موجباً أو صفراً';
                final requiredVal = double.tryParse(_requiredController.text);
                if (requiredVal != null && val > requiredVal) {
                  return 'لا يمكن أن تكون الكمية المنجزة أكبر من الهدف النهائي';
                }
                return null;
              },
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الأهداف المرحلية (اختياري)', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: _addMilestoneField,
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _milestoneValueControllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _milestoneValueControllers[index],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'القيمة', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _milestoneDescControllers[index],
                          decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => _removeMilestoneField(index),
                      )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _submit,
              child: const Text('حفظ المهارة'),
            ),
          ],
        ),
      ),
    );
  }
}