// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart'; // <-- استيراد الـ Provider الصحيح

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استخدام AppProvider بدلاً من ThemeProvider
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
        ],
      ),
    );
  }
}