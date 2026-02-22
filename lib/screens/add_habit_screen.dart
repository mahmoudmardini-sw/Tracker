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
  final _formKey = GlobalKey<FormState>();
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
                if (!provider.habitCategories.contains(newCategory)) {
                  provider.addHabitCategory(newCategory);
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

  void _submit() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final isAr = provider.appLocale.languageCode == 'ar';

    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final newHabit = Habit(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        type: _selectedType,
        category: _selectedCategory!,
      );
      provider.addHabit(newHabit);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isAr ? 'تمت إضافة العادة بنجاح!' : 'Habit added successfully!'),
            backgroundColor: Colors.green
        ),
      );

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
    final isAr = provider.appLocale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(isAr ? 'إضافة عادة جديدة' : 'Add New Habit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: isAr ? 'اسم العادة' : 'Habit Name',
                  border: const OutlineInputBorder()
              ),
              autofocus: true,
              validator: (value) => value == null || value.trim().isEmpty
                  ? (isAr ? 'الرجاء إدخال اسم العادة' : 'Please enter habit name')
                  : null,
            ),
            const SizedBox(height: 20),
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
                    items: provider.habitCategories.toSet().map((String category) {
                      return DropdownMenuItem<String>(value: category, child: Text(category));
                    }).toList(),
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
            const SizedBox(height: 20),
            SegmentedButton<HabitType>(
              style: SegmentedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              segments: [
                ButtonSegment(
                    value: HabitType.binary,
                    label: Text(isAr ? 'إنجاز' : 'Done/Skip'),
                    icon: const Icon(Icons.check_box_outlined)
                ),
                ButtonSegment(
                    value: HabitType.counter,
                    label: Text(isAr ? 'عداد' : 'Counter'),
                    icon: const Icon(Icons.add_circle_outline)
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (newSelection) {
                setState(() => _selectedType = newSelection.first);
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: _submit,
              child: Text(isAr ? 'إضافة العادة' : 'Add Habit', style: const TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}