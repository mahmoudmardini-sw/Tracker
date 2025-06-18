// lib/constants/motivational_quotes.dart

import 'dart:math';
import 'package:flutter/material.dart';

const List<String> motivationalQuotesAr = [
  "رحلة الألف ميل تبدأ بخطوة واحدة. ابدأ اليوم.",
  "النجاح هو مجموع جهود صغيرة تتكرر يوماً بعد يوم.",
  "لا تخف من التقدم البطيء، بل من الوقوف ساكناً.",
  "الشخص الوحيد الذي يجب أن تتفوق عليه هو أنت في الأمس.",
  "الاستمرارية هي وقود الإنجاز. لا تتوقف.",
  "كل خبير كان ذات يوم مبتدئاً. ثق برحلتك.",
  "العلم يرفع بيوتاً لا عماد لها، والجهل يهدم بيت العز والشرف.",
  "اصنع من كل يوم فرصة لتعلم شيء جديد.",
  "التحديات هي ما تجعل الحياة مثيرة، والتغلب عليها هو ما يجعلها ذات معنى.",
  "أعظم مجد ليس في عدم السقوط أبداً، بل في النهوض كلما سقطنا."
];

const List<String> motivationalQuotesEn = [
  "The journey of a thousand miles begins with a single step. Start today.",
  "Success is the sum of small efforts, repeated day in and day out.",
  "Be not afraid of going slowly, be afraid only of standing still.",
  "The only person you should try to be better than is the person you were yesterday.",
  "Continuity is the fuel of achievement. Don't stop.",
  "Every expert was once a beginner. Trust your journey.",
  "Knowledge builds houses without pillars, and ignorance demolishes the house of glory and honor.",
  "Make each day your masterpiece.",
  "Challenges are what make life interesting and overcoming them is what makes life meaningful.",
  "Our greatest glory is not in never falling, but in rising every time we fall."
];

String getRandomQuote(BuildContext context) {
  final random = Random();
  final locale = Localizations.localeOf(context).languageCode;

  if (locale == 'ar') {
    return motivationalQuotesAr[random.nextInt(motivationalQuotesAr.length)];
  } else {
    // Default to English for any other language
    return motivationalQuotesEn[random.nextInt(motivationalQuotesEn.length)];
  }
}