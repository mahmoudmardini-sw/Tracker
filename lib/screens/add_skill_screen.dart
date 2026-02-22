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

  late List<String> _units;
  late String _selectedUnit;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);

    final isAr = provider.appLocale.languageCode == 'ar';
    _units = isAr ? [
      'ساعة', 'صفحة', 'سورة', 'كتاب', 'جلسة تدريبية', 'تكرار', 'مجموعة',
      'دقيقة', 'كيلو متر', 'خطوة', 'جزء', 'فصل', 'مقال',
    ] : [
      'Hour', 'Page', 'Surah', 'Book', 'Session', 'Repetition', 'Set',
      'Minute', 'Kilometer', 'Step', 'Part', 'Chapter', 'Article',
    ];

    if (_units.contains(provider.defaultUnit)) {
      _selectedUnit = provider.defaultUnit;
    } else {
      _selectedUnit = _units.first;
    }

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
    final provider = Provider.of<AppProvider>(context, listen: false);
    final isAr = provider.appLocale.languageCode == 'ar';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? 'إضافة صنف جديد' : 'Add New Category'),
        content: TextField(
          controller: _categoryController,
          autofocus: true,
          decoration: InputDecoration(labelText: isAr ? 'اسم الصنف' : 'Category Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isAr ? 'إلغاء' : 'Cancel')
          ),
          ElevatedButton(
            onPressed: () {
              final newCategory = _categoryController.text.trim();
              if (newCategory.isNotEmpty) {
                if (!provider.skillCategories.contains(newCategory)) {
                  provider.addSkillCategory(newCategory);
                }
                setState(() {
                  _selectedCategory = newCategory;
                });
                _categoryController.clear();
                Navigator.pop(context);
              }
            },
            child: Text(isAr ? 'إضافة' : 'Add'),
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
    final provider = Provider.of<AppProvider>(context, listen: false);
    final isAr = provider.appLocale.languageCode == 'ar';

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

      provider.addSkill(newSkill);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isAr ? 'تم حفظ المهارة بنجاح!' : 'Skill saved successfully!'),
            backgroundColor: Colors.green
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isAr = provider.appLocale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? 'إضافة مهارة جديدة' : 'Add New Skill')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: isAr ? 'اسم المهارة' : 'Skill Name',
                  border: const OutlineInputBorder()
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? (isAr ? 'لا يمكن ترك الاسم فارغاً' : 'Name cannot be empty')
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    validator: (v) => v == null
                        ? (isAr ? 'الرجاء اختيار صنف' : 'Please select a category')
                        : null,
                    decoration: InputDecoration(
                        labelText: isAr ? 'الصنف' : 'Category',
                        border: const OutlineInputBorder()
                    ),
                    items: provider.skillCategories.toSet().map((String category) =>
                        DropdownMenuItem<String>(value: category, child: Text(category))
                    ).toList(),
                    onChanged: (newValue) => setState(() => _selectedCategory = newValue),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _showAddCategoryDialog,
                  tooltip: isAr ? 'إضافة صنف جديد' : 'Add new category',
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              items: _units.map((String unit) => DropdownMenuItem<String>(value: unit, child: Text(unit))).toList(),
              onChanged: (newValue) => setState(() => _selectedUnit = newValue!),
              decoration: InputDecoration(
                  labelText: isAr ? 'الوحدة' : 'Unit',
                  border: const OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _requiredController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: isAr ? 'الهدف النهائي (الكمية المطلوبة)' : 'Final Goal (Required Amount)',
                  border: const OutlineInputBorder()
              ),
              validator: (v) => v == null || (double.tryParse(v) ?? 0) <= 0
                  ? (isAr ? 'أدخل رقماً موجباً' : 'Enter a positive number')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _spentController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: isAr ? 'الكمية المنجزة حالياً' : 'Currently Completed Amount',
                  border: const OutlineInputBorder()
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return isAr ? 'أدخل رقماً موجباً أو صفراً' : 'Enter a positive number or zero';
                final val = double.tryParse(v);
                if (val == null || val < 0) return isAr ? 'أدخل رقماً موجباً أو صفراً' : 'Enter a positive number or zero';
                final requiredVal = double.tryParse(_requiredController.text);
                if (requiredVal != null && val > requiredVal) {
                  return isAr ? 'لا يمكن أن تكون الكمية المنجزة أكبر من الهدف النهائي' : 'Completed amount cannot be greater than final goal';
                }
                return null;
              },
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    isAr ? 'الأهداف المرحلية (اختياري)' : 'Milestones (Optional)',
                    style: Theme.of(context).textTheme.titleMedium
                ),
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
                          decoration: InputDecoration(
                              labelText: isAr ? 'القيمة' : 'Value',
                              border: const OutlineInputBorder()
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return isAr ? 'مطلوب' : 'Required';
                            final val = double.tryParse(v);
                            if (val == null) return isAr ? 'أدخل رقماً' : 'Enter a number';
                            final requiredVal = double.tryParse(_requiredController.text);
                            if (requiredVal != null && val > requiredVal) {
                              return isAr ? 'أكبر من النهائي!' : 'Greater than goal!';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _milestoneDescControllers[index],
                          decoration: InputDecoration(
                              labelText: isAr ? 'الوصف' : 'Description',
                              border: const OutlineInputBorder()
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? (isAr ? 'مطلوب' : 'Required')
                              : null,
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
              child: Text(isAr ? 'حفظ المهارة' : 'Save Skill', style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}