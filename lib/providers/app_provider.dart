import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import '../models/skill.dart';
import '../models/daily_log.dart';
import '../models/habit.dart';
import '../models/habit_record.dart';
import '../constants/app_constants.dart';

class AppProvider with ChangeNotifier {
  final SharedPreferences prefs;

  ThemeMode _themeMode = ThemeMode.system;
  String _defaultUnit = 'ساعة';
  bool _showCompletedSkills = true;
  String _selectedCategory = 'الكل';

  List<Skill> _skills = [];
  List<DailyLog> _dailyLogs = [];
  List<Habit> _habits = [];
  List<HabitRecord> _habitRecords = [];

  AppProvider(this.prefs);

  ThemeMode get themeMode => _themeMode;
  String get defaultUnit => _defaultUnit;
  bool get showCompletedSkills => _showCompletedSkills;
  List<Skill> get skills => _skills;
  List<DailyLog> get dailyLogs => _dailyLogs;
  String get selectedCategory => _selectedCategory;
  List<Habit> get habits => _habits;
  List<HabitRecord> get habitRecords => _habitRecords;

  void loadAllData() {
    final themeString = prefs.getString(AppConstants.themeModeKey) ?? ThemeMode.system.toString();
    _themeMode = ThemeMode.values.firstWhere((e) => e.toString() == themeString, orElse: () => ThemeMode.system);
    _defaultUnit = prefs.getString(AppConstants.defaultUnitKey) ?? 'ساعة';
    _showCompletedSkills = prefs.getBool(AppConstants.showCompletedSkillsKey) ?? true;
    _selectedCategory = prefs.getString(AppConstants.selectedCategoryKey) ?? 'الكل';
    _loadSkills();
    _loadDailyLogs();
    _loadHabits();
    _loadHabitRecords();
    notifyListeners();
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
    // إزالة السجل القديم لنفس اليوم ونفس العادة، إن وجد
    _habitRecords.removeWhere((r) => r.habitId == record.habitId && isSameDay(r.date, record.date));
    // إضافة السجل الجديد
    _habitRecords.add(record);
    _saveHabitRecords();
    notifyListeners();
  }

  void removeHabitLog(String habitId, DateTime date) {
    _habitRecords.removeWhere((r) => r.habitId == habitId && isSameDay(r.date, date));
    _saveHabitRecords();
    notifyListeners();
  }
// أضف هذه الدوال داخل كلاس AppProvider في ملف lib/providers/app_provider.dart

  void addNoteToSkill(String skillId, String noteText) {
    try {
      final skill = _skills.firstWhere((s) => s.id == skillId);
      skill.notes.insert(0, noteText);
      _saveSkills(); // هذه الدالة تقوم بالحفظ واستدعاء notifyListeners()
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
}