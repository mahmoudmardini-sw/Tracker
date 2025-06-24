// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Skill Tracker';

  @override
  String get skillsTab => 'Skills';

  @override
  String get habitsTab => 'Habits';

  @override
  String get addSkill => 'Add Skill';

  @override
  String get addHabit => 'Add Habit';

  @override
  String get achievementsLog => 'Achievements Log';

  @override
  String get settings => 'Settings';

  @override
  String get filter => 'Filter';

  @override
  String get all => 'All';

  @override
  String get noSkillsMessage =>
      'No skills added yet. Tap the + button to add one!';

  @override
  String addProgressTo(String skillName) {
    return 'Add Progress to $skillName';
  }

  @override
  String addedAmount(String unit) {
    return 'Added Amount ($unit)';
  }

  @override
  String get pleaseEnterValue => 'Please enter a value.';

  @override
  String get pleaseEnterNumber => 'Please enter a valid number.';

  @override
  String get save => 'Save';

  @override
  String completed(Object spentValue, Object requiredValue, Object unit) {
    return '$spentValue / $requiredValue $unit Completed';
  }

  @override
  String get addProgress => 'Add Progress';

  @override
  String get theCount => 'Count';

  @override
  String get noHabitsMessage =>
      'No habits tracked yet. Tap the + icon to add one!';

  @override
  String get nightMode => 'Night Mode';

  @override
  String get enableDarkMode => 'Enable dark theme for the app';

  @override
  String get language => 'Language';

  @override
  String get defaultUnit => 'Default Unit';

  @override
  String currentUnit(Object unit) {
    return 'Current: $unit';
  }

  @override
  String get showCompletedSkills => 'Show Completed Skills';

  @override
  String get deleteAllData => 'Delete All Data';

  @override
  String get deleteAllDataSub => 'This action is irreversible.';

  @override
  String get deleteAllDataConfirmation =>
      'Are you sure you want to delete ALL application data? This cannot be undone.';

  @override
  String get deleteConfirmationTitle => 'Delete Confirmation';

  @override
  String deleteSkillConfirmation(Object skillName) {
    return 'Are you sure you want to delete the skill \'\'$skillName\'\'? All related logs will also be deleted.';
  }

  @override
  String deleteHabitConfirmation(Object habitName) {
    return 'Are you sure you want to delete the habit \'\'$habitName\'\'? All its records will also be deleted.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteSkillTooltip => 'Delete Skill';

  @override
  String get deleteHabitTooltip => 'Delete Habit';

  @override
  String updateCounterFor(String habitName) {
    return 'Update Counter: $habitName';
  }
}
