import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../providers/app_provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  HabitType _selectedType = HabitType.binary;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.habitCategories.isNotEmpty) {
      _selectedCategory = provider.habitCategories.first;
    }
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
                provider.addHabitCategory(newCategory);
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

  void _submit() {
    if (_nameController.text.trim().isNotEmpty && _selectedCategory != null) {
      final newHabit = Habit(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        type: _selectedType,
        category: _selectedCategory!,
      );
      Provider.of<AppProvider>(context, listen: false).addHabit(newHabit);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عادة جديدة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'اسم العادة', border: OutlineInputBorder()),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    validator: (v) => v == null ? 'الرجاء اختيار صنف' : null,
                    decoration: const InputDecoration(labelText: 'الصنف', border: OutlineInputBorder()),
                    items: provider.habitCategories.map((String category) {
                      return DropdownMenuItem<String>(value: category, child: Text(category));
                    }).toList(),
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
            const SizedBox(height: 20),
            SegmentedButton<HabitType>(
              style: SegmentedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              segments: const [
                ButtonSegment(value: HabitType.binary, label: Text('إنجاز'), icon: Icon(Icons.check_box_outlined)),
                ButtonSegment(value: HabitType.counter, label: Text('عداد'), icon: Icon(Icons.add_circle_outline)),
              ],
              selected: {_selectedType},
              onSelectionChanged: (newSelection) {
                setState(() => _selectedType = newSelection.first);
              },
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _submit,
              child: const Text('إضافة العادة'),
            )
          ],
        ),
      ),
    );
  }
}