import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// NEW: Changed the import to a direct relative path
import '../l10n/app_localizations.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showDeleteConfirmationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteConfirmationTitle),
          content: Text(l10n.deleteAllDataConfirmation),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(l10n.delete, style: TextStyle(color: Colors.red.shade400)),
              onPressed: () {
                Provider.of<AppProvider>(context, listen: false).deleteAllData();
                Navigator.of(dialogContext).pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data has been deleted.')),
                  );
                }
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
    final l10n = AppLocalizations.of(context)!;

    final List<String> units = const [
      'ساعة', 'صفحة', 'سورة', 'كتاب', 'جلسة تدريبية',
      'تكرار', 'مجموعة', 'دقيقة', 'كيلو متر', 'خطوة',
      'جزء', 'فصل', 'مقال',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          SwitchListTile(
            title: Text(l10n.nightMode),
            subtitle: Text(l10n.enableDarkMode),
            value: provider.themeMode == ThemeMode.dark,
            onChanged: (isDarkMode) => provider.toggleTheme(isDarkMode),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.language),
            trailing: DropdownButton<Locale>(
              value: provider.appLocale,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
              ],
              onChanged: (newLocale) {
                if (newLocale != null) {
                  provider.changeLanguage(newLocale);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.defaultUnit),
            subtitle: Text(l10n.currentUnit(provider.defaultUnit)),
            trailing: DropdownButton<String>(
              value: provider.defaultUnit,
              items: units.map((String unit) => DropdownMenuItem<String>(value: unit, child: Text(unit))).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  provider.setDefaultUnit(newValue);
                }
              },
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: Text(l10n.showCompletedSkills),
            value: provider.showCompletedSkills,
            onChanged: (value) => provider.toggleShowCompletedSkills(value),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: Colors.red.shade400),
            title: Text(l10n.deleteAllData, style: TextStyle(color: Colors.red.shade400)),
            subtitle: Text(l10n.deleteAllDataSub),
            onTap: () => _showDeleteConfirmationDialog(context),
          ),
        ],
      ),
    );
  }
}