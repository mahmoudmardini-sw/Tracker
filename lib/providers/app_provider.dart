import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/skill.dart';
import '../models/daily_log.dart';
import '../models/habit.dart';
import '../models/habit_record.dart';
import '../constants/app_constants.dart';
import 'package:table_calendar/table_calendar.dart';

class AppProvider with ChangeNotifier {
  final SharedPreferences prefs;

  ThemeMode _themeMode = ThemeMode.system;
  String _defaultUnit = 'ساعة';
  bool _showCompletedSkills = true;
  String _selectedCategory = 'الكل';
  Locale _appLocale = const Locale('en');

  List<Skill> _skills = [];
  List<DailyLog> _dailyLogs = [];
  List<Habit> _habits = [];
  List<HabitRecord> _habitRecords = [];

  // قوائم ديناميكية جديدة للأصناف
  List<String> _skillCategories = [];
  List<String> _habitCategories = [];

  AppProvider(this.prefs);

  ThemeMode get themeMode => _themeMode;
  String get defaultUnit => _defaultUnit;
  bool get showCompletedSkills => _showCompletedSkills;
  List<Skill> get skills => _skills;
  List<DailyLog> get dailyLogs => _dailyLogs;
  String get selectedCategory => _selectedCategory;
  List<Habit> get habits => _habits;
  List<HabitRecord> get habitRecords => _habitRecords;
  Locale get appLocale => _appLocale;

  // Getters للوصول إلى قوائم الأصناف
  List<String> get skillCategories => _skillCategories;
  List<String> get habitCategories => _habitCategories;

  void loadAllData() {
    final themeString = prefs.getString(AppConstants.themeModeKey) ?? ThemeMode.system.toString();
    _themeMode = ThemeMode.values.firstWhere((e) => e.toString() == themeString, orElse: () => ThemeMode.system);

    final languageCode = prefs.getString(AppConstants.languageCodeKey) ?? 'en';
    _appLocale = Locale(languageCode);

    _defaultUnit = prefs.getString(AppConstants.defaultUnitKey) ?? 'ساعة';
    _showCompletedSkills = prefs.getBool(AppConstants.showCompletedSkillsKey) ?? true;
    _selectedCategory = prefs.getString(AppConstants.selectedCategoryKey) ?? 'الكل';

    // تحميل الأصناف من الذاكرة أو استخدام قائمة افتراضية
    _skillCategories = prefs.getStringList(AppConstants.skillCategoriesKey) ?? ['القرآن', 'رياضة', 'Computer Science', 'لغات', 'أخرى'];
    _habitCategories = prefs.getStringList(AppConstants.habitCategoriesKey) ?? ['صحة', 'دين', 'تطوير الذات', 'أخرى'];

    _loadSkills();
    _loadDailyLogs();
    _loadHabits();
    _loadHabitRecords();
    notifyListeners();
  }

  // دوال جديدة لإضافة الأصناف وحفظها
  Future<void> addSkillCategory(String category) async {
    if (!_skillCategories.contains(category)) {
      _skillCategories.add(category);
      await prefs.setStringList(AppConstants.skillCategoriesKey, _skillCategories);
      notifyListeners();
    }
  }

  Future<void> addHabitCategory(String category) async {
    if (!_habitCategories.contains(category)) {
      _habitCategories.add(category);
      await prefs.setStringList(AppConstants.habitCategoriesKey, _habitCategories);
      notifyListeners();
    }
  }

  Future<void> _loadSkills() async {
    final String? skillsString = prefs.getString(AppConstants.skillsDataKey);
    if (skillsString != null) {
      try {
        _skills = (jsonDecode(skillsString) as List).map((json) => Skill.fromJson(json)).toList();
      } catch (e) {
        await prefs.remove(AppConstants.skillsDataKey);
        _skills = [];
      }
    }
  }

  Future<void> _saveSkills() async {
    await prefs.setString(AppConstants.skillsDataKey, jsonEncode(_skills.map((s) => s.toJson()).toList()));
    notifyListeners();
  }

  void addSkill(Skill skill) {
    _skills.add(skill);
    _saveSkills();
  }

  void updateSkill(Skill skill) {
    final index = _skills.indexWhere((s) => s.id == skill.id);
    if (index != -1) {
      _skills[index] = skill;
      _saveSkills();
    }
  }

  void removeSkill(String skillId) {
    _skills.removeWhere((s) => s.id == skillId);
    removeLogsForSkill(skillId);
    _saveSkills();
  }

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    prefs.setString(AppConstants.themeModeKey, _themeMode.toString());
    notifyListeners();
  }

  Future<void> changeLanguage(Locale newLocale) async {
    _appLocale = newLocale;
    await prefs.setString(AppConstants.languageCodeKey, newLocale.languageCode);
    notifyListeners();
  }

  void setDefaultUnit(String unit) {
    _defaultUnit = unit;
    prefs.setString(AppConstants.defaultUnitKey, unit);
    notifyListeners();
  }

  void toggleShowCompletedSkills(bool value) {
    _showCompletedSkills = value;
    prefs.setBool(AppConstants.showCompletedSkillsKey, value);
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    prefs.setString(AppConstants.selectedCategoryKey, category);
    notifyListeners();
  }

  void _loadDailyLogs() {
    final String? logsString = prefs.getString(AppConstants.dailyLogsDataKey);
    if (logsString != null) {
      _dailyLogs = (jsonDecode(logsString) as List).map((json) => DailyLog.fromJson(json)).toList();
    }
  }

  Future<void> _saveDailyLogs() async {
    await prefs.setString(AppConstants.dailyLogsDataKey, jsonEncode(_dailyLogs.map((log) => log.toJson()).toList()));
  }

  void addDailyLog(DailyLog log) {
    _dailyLogs.add(log);
    _saveDailyLogs();
    notifyListeners();
  }

  void removeLogsForSkill(String skillId) {
    _dailyLogs.removeWhere((log) => log.skillId == skillId);
    _saveDailyLogs();
  }

  void _loadHabits() {
    final String? habitsString = prefs.getString(AppConstants.habitsDataKey);
    if (habitsString != null) {
      _habits = (jsonDecode(habitsString) as List).map((json) => Habit.fromJson(json)).toList();
    }
  }

  Future<void> _saveHabits() async {
    await prefs.setString(AppConstants.habitsDataKey, jsonEncode(_habits.map((h) => h.toJson()).toList()));
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _saveHabits();
    notifyListeners();
  }

  void removeHabit(String habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    _habitRecords.removeWhere((r) => r.habitId == habitId);
    _saveHabits();
    _saveHabitRecords();
    notifyListeners();
  }

  void _loadHabitRecords() {
    final String? recordsString = prefs.getString(AppConstants.habitRecordsDataKey);
    if (recordsString != null) {
      _habitRecords = (jsonDecode(recordsString) as List).map((json) => HabitRecord.fromJson(json)).toList();
    }
  }

  Future<void> _saveHabitRecords() async {
    await prefs.setString(AppConstants.habitRecordsDataKey, jsonEncode(_habitRecords.map((r) => r.toJson()).toList()));
  }

  void logHabit(HabitRecord record) {
    _habitRecords.removeWhere((r) => r.habitId == record.habitId && isSameDay(r.date, record.date));
    _habitRecords.add(record);
    _saveHabitRecords();
    notifyListeners();
  }

  void removeHabitLog(String habitId, DateTime date) {
    _habitRecords.removeWhere((r) => r.habitId == habitId && isSameDay(r.date, date));
    _saveHabitRecords();
    notifyListeners();
  }

  void addNoteToSkill(String skillId, String noteText) {
    try {
      final skill = _skills.firstWhere((s) => s.id == skillId);
      skill.notes.insert(0, noteText);
      _saveSkills();
    } catch (e) {
      //
    }
  }

  void removeNoteFromSkill(String skillId, int noteIndex) {
    try {
      final skill = _skills.firstWhere((s) => s.id == skillId);
      skill.notes.removeAt(noteIndex);
      _saveSkills();
    } catch (e) {
      //
    }
  }

  HabitRecord? getHabitRecordForDay(String habitId, DateTime day) {
    try {
      return _habitRecords.firstWhere((r) => r.habitId == habitId && isSameDay(r.date, day));
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteAllData() async {
    _skills.clear();
    _dailyLogs.clear();
    _habits.clear();
    _habitRecords.clear();

    await prefs.remove(AppConstants.skillsDataKey);
    await prefs.remove(AppConstants.dailyLogsDataKey);
    await prefs.remove(AppConstants.habitsDataKey);
    await prefs.remove(AppConstants.habitRecordsDataKey);

    notifyListeners();
  }
}