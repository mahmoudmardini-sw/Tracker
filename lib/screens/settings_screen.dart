// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  // NEW: Confirmation dialog logic
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من رغبتك في حذف جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('حذف', style: TextStyle(color: Colors.red.shade400)),
              onPressed: () {
                // Call the provider to delete all data
                Provider.of<AppProvider>(context, listen: false).deleteAllData();
                Navigator.of(dialogContext).pop(); // Close the dialog
                // Optional: Show a confirmation snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حذف جميع البيانات بنجاح.')),
                );
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    final List<String> units = const [
      'ساعة', 'صفحة', 'سورة', 'كتاب', 'جلسة تدريبية',
      'تكرار', 'مجموعة', 'دقيقة', 'كيلو متر', 'خطوة',
      'جزء', 'فصل', 'مقال',
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          SwitchListTile(
            title: const Text('الوضع الليلي'),
            subtitle: const Text('تفعيل الثيم الداكن للتطبيق'),
            value: provider.themeMode == ThemeMode.dark,
            onChanged: (isDarkMode) {
              provider.toggleTheme(isDarkMode);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('الوحدة الافتراضية للمهارات الجديدة'),
            subtitle: Text('الوحدة الحالية: ${provider.defaultUnit}'),
            trailing: DropdownButton<String>(
              value: provider.defaultUnit,
              items: units.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  provider.setDefaultUnit(newValue);
                }
              },
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('إظهار المهارات المكتملة'),
            subtitle: const Text('عرض المهارات التي تم إنجازها بنسبة 100%'),
            value: provider.showCompletedSkills,
            onChanged: (value) {
              provider.toggleShowCompletedSkills(value);
            },
          ),
          const Divider(),
          // NEW: Delete all data button
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: Colors.red.shade400),
            title: Text('حذف جميع البيانات', style: TextStyle(color: Colors.red.shade400)),
            subtitle: const Text('حذف جميع المهارات والعادات والسجلات بشكل دائم'),
            onTap: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }
}