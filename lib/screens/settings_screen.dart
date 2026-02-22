import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final l10n = AppLocalizations.of(context);
    final isAr = provider.appLocale.languageCode == 'ar';

    // 1. القائمة الديناميكية للوحدات بناءً على لغة التطبيق الحالية
    final List<String> units = isAr ? [
      'ساعة', 'صفحة', 'سورة', 'كتاب', 'جلسة تدريبية', 'تكرار', 'مجموعة',
      'دقيقة', 'كيلو متر', 'خطوة', 'جزء', 'فصل', 'مقال',
    ] : [
      'Hour', 'Page', 'Surah', 'Book', 'Session', 'Repetition', 'Set',
      'Minute', 'Kilometer', 'Step', 'Part', 'Chapter', 'Article',
    ];

    // 2. الحماية (Safety Check): التأكد من أن الوحدة المحفوظة موجودة فعلياً في القائمة
    String safeUnit = provider.defaultUnit;
    if (!units.contains(safeUnit)) {
      safeUnit = units.first; // إذا لم تكن موجودة، نختار أول وحدة تلقائياً لمنع الخطأ
      // نقوم بتحديثها في الخلفية بصمت
      Future.microtask(() => provider.setDefaultUnit(units.first));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settings ?? (isAr ? 'الإعدادات' : 'Settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // إعدادات اللغة
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(isAr ? 'اللغة' : 'Language'),
            trailing: DropdownButton<String>(
              value: provider.appLocale.languageCode,
              items: const [
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (String? newLang) {
                if (newLang != null) {
                  provider.changeLanguage(Locale(newLang));
                }
              },
            ),
          ),
          const Divider(),

          // إعدادات المظهر (الوضع الليلي/النهاري)
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(isAr ? 'الوضع المظلم' : 'Dark Mode'),
            trailing: Switch(
              value: provider.themeMode == ThemeMode.dark,
              onChanged: (bool value) {
                provider.toggleTheme(value);
              },
            ),
          ),
          const Divider(),

          // وحدة القياس الافتراضية (هنا كان الخطأ وتم حله)
          ListTile(
            leading: const Icon(Icons.straighten),
            title: Text(isAr ? 'الوحدة الافتراضية' : 'Default Unit'),
            trailing: DropdownButton<String>(
              value: safeUnit, // نستخدم المتغير الآمن
              items: units.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  provider.setDefaultUnit(newValue);
                }
              },
            ),
          ),
          const Divider(),

          // إظهار/إخفاء المهارات المكتملة
          SwitchListTile(
            secondary: const Icon(Icons.check_circle_outline),
            title: Text(isAr ? 'إظهار المهارات المكتملة' : 'Show Completed Skills'),
            value: provider.showCompletedSkills,
            onChanged: (bool value) {
              provider.toggleShowCompletedSkills(value);
            },
          ),
          const Divider(),

          // زر حذف جميع البيانات
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.delete_forever),
            label: Text(isAr ? 'حذف جميع البيانات' : 'Delete All Data'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(isAr ? 'تأكيد الحذف' : 'Confirm Delete'),
                  content: Text(isAr
                      ? 'هل أنت متأكد أنك تريد حذف جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء.'
                      : 'Are you sure you want to delete all data? This cannot be undone.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(isAr ? 'إلغاء' : 'Cancel')
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        provider.deleteAllData();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(isAr ? 'تم حذف جميع البيانات بنجاح' : 'All data deleted successfully')),
                        );
                      },
                      child: Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}