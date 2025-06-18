// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- السطر الجديد الأول: استيراد المكتبة
import 'providers/app_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  // التأكد من تهيئة كل شيء قبل تشغيل التطبيق
  WidgetsFlutterBinding.ensureInitialized();

  // --- السطر الجديد الثاني: تهيئة بيانات اللغة العربية ---
  // ننتظر حتى يتم تحميلها قبل تشغيل واجهة المستخدم
  await initializeDateFormatting('ar_SA', null);

  // باقي الكود كما هو
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(prefs)..loadAllData(),
      child: const SkillTrackerApp(),
    ),
  );
}

class SkillTrackerApp extends StatelessWidget {
  const SkillTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return MaterialApp(
      title: 'Skill Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: provider.themeMode,
      home: HomeScreen(),
    );
  }
}