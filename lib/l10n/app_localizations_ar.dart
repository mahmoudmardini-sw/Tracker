// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'متتبع المهارات';

  @override
  String get skillsTab => 'المهارات';

  @override
  String get habitsTab => 'العادات';

  @override
  String get addSkill => 'أضف مهارة';

  @override
  String get addHabit => 'أضف عادة';

  @override
  String get achievementsLog => 'سجل الإنجازات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get filter => 'تصفية';

  @override
  String get all => 'الكل';

  @override
  String get noSkillsMessage =>
      'لا توجد مهارات بعد. اضغط على زر + لإضافة واحدة!';

  @override
  String addProgressTo(String skillName) {
    return 'إضافة تقدم إلى $skillName';
  }

  @override
  String addedAmount(String unit) {
    return 'الكمية المضافة ($unit)';
  }

  @override
  String get pleaseEnterValue => 'الرجاء إدخال قيمة.';

  @override
  String get pleaseEnterNumber => 'الرجاء إدخال رقم صحيح.';

  @override
  String get save => 'حفظ';

  @override
  String completed(Object spentValue, Object requiredValue, Object unit) {
    return 'تم إنجاز $spentValue / $requiredValue $unit';
  }

  @override
  String get addProgress => 'أضف تقدماً';

  @override
  String get theCount => 'العدد';

  @override
  String get noHabitsMessage =>
      'لا توجد عادات بعد. اضغط على زر + لإضافة واحدة!';

  @override
  String get nightMode => 'الوضع الليلي';

  @override
  String get enableDarkMode => 'فعل الوضع الداكن للتطبيق';

  @override
  String get language => 'اللغة';

  @override
  String get defaultUnit => 'الوحدة الافتراضية';

  @override
  String currentUnit(Object unit) {
    return 'الحالية: $unit';
  }

  @override
  String get showCompletedSkills => 'إظهار المهارات المكتملة';

  @override
  String get deleteAllData => 'حذف جميع البيانات';

  @override
  String get deleteAllDataSub => 'هذا الإجراء لا يمكن التراجع عنه';

  @override
  String get deleteAllDataConfirmation =>
      'هل أنت متأكد من حذف كل بيانات التطبيق؟ لا يمكن التراجع عن هذا الأمر.';

  @override
  String get deleteConfirmationTitle => 'تأكيد الحذف';

  @override
  String deleteSkillConfirmation(Object skillName) {
    return 'هل أنت متأكد من رغبتك في حذف المهارة \'\'$skillName\'\'؟ سيتم حذف جميع السجلات المرتبطة بها أيضاً.';
  }

  @override
  String deleteHabitConfirmation(Object habitName) {
    return 'هل أنت متأكد من رغبتك في حذف العادة \'\'$habitName\'\'؟ سيتم حذف جميع سجلاتها أيضاً.';
  }

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get deleteSkillTooltip => 'حذف المهارة';

  @override
  String get deleteHabitTooltip => 'حذف العادة';

  @override
  String updateCounterFor(String habitName) {
    return 'تحديث عداد: $habitName';
  }
}
