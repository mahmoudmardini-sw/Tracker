import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import '../providers/app_provider.dart';

class AddHabitScreen extends StatefulWidget {
  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _nameController = TextEditingController();
  HabitType _selectedType = HabitType.binary;

  void _submit() {
    if (_nameController.text.trim().isNotEmpty) {
      final newHabit = Habit(
        id: Uuid().v4(),
        name: _nameController.text.trim(),
        type: _selectedType,
      );
      Provider.of<AppProvider>(context, listen: false).addHabit(newHabit);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة عادة جديدة')),
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
                setState(() {
                  _selectedType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 40),
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