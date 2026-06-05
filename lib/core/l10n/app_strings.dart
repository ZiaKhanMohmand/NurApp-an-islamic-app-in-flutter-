import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/settings_provider.dart';

class AppStrings {
  final bool isArabic;
  AppStrings(this.isArabic);

  String toLocalNum(String text) {
    if (!isArabic) return text;
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = text;
    for (int i = 0; i < en.length; i++) {
      result = result.replaceAll(en[i], ar[i]);
    }
    return result;
  }

  // General
  String get appName => 'NurApp';
  String get home => isArabic ? 'الرئيسية' : 'Home';
  String get quran => isArabic ? 'القرآن' : 'Quran';
  String get tasbeeh => isArabic ? 'التسبيح' : 'Tasbeeh';
  String get qibla => isArabic ? 'القبلة' : 'Qibla';
  String get more => isArabic ? 'المزيد' : 'More';

  // Home
  String get islamicDate => isArabic ? 'التاريخ الإسلامي' : 'Islamic Date';
  String get prayerTimes => isArabic ? 'أوقات الصلاة' : 'Prayer Times';
  String get today => isArabic ? 'اليوم' : 'Today';
  String get next => isArabic ? 'التالي' : 'Next';
  String get verseOfDay => isArabic ? 'آية اليوم' : 'Verse of the Day';
  String get readReflection => isArabic ? 'اقرأ التأمل' : 'READ REFLECTION';
  String get nearbyMosques => isArabic ? 'المساجد القريبة' : 'Nearby Mosques';
  String get ramadanDay => isArabic ? 'يوم رمضان' : 'RAMADAN DAY';
  String get tapToOpen => isArabic ? 'اضغط للفتح' : 'Tap to open';
  String get comingSoon => isArabic ? 'قريباً' : 'Coming Soon';

  // Prayer names
  String get fajr => isArabic ? 'الفجر' : 'Fajr';
  String get dhuhr => isArabic ? 'الظهر' : 'Dhuhr';
  String get asr => isArabic ? 'العصر' : 'Asr';
  String get maghrib => isArabic ? 'المغرب' : 'Maghrib';
  String get isha => isArabic ? 'العشاء' : 'Isha';

  // Qibla
  String get highAccuracy => isArabic ? 'دقة عالية' : 'HIGH ACCURACY';
  String get distanceToMakkah =>
      isArabic ? 'المسافة إلى مكة' : 'DISTANCE TO MAKKAH';
  String get qiblaAngle => isArabic ? 'زاوية القبلة' : 'Qibla Angle';

  // Tasbeeh
  String get todayHistory => isArabic ? 'سجل اليوم' : 'Today\'s History';
  String get sessions => isArabic ? 'جلسات' : 'Sessions';
  String get goal => isArabic ? 'الهدف' : 'Goal';
  String get noSessionsToday =>
      isArabic ? 'لا توجد جلسات اليوم' : 'No sessions yet today';

  // Quran
  String get searchSurah =>
      isArabic ? 'ابحث عن سورة...' : 'Search Surah or Verse...';
  String get lastRead => isArabic ? 'آخر قراءة' : 'LAST READ';
  String get surahs => isArabic ? 'السور' : 'SURAH';
  String get verses => isArabic ? 'آيات' : 'VERSES';
  String get jumpToAyah =>
      isArabic ? 'انتقل إلى رقم الآية...' : 'Jump to Ayah number...';

  // Reflection
  String get dailyGuidance => isArabic ? 'الإرشاد اليومي' : 'DAILY GUIDANCE';
  String get sacredReflection =>
      isArabic ? 'التأمل المقدس' : 'Sacred Reflection';
  String get aiInsight => isArabic ? 'رؤية الذكاء الاصطناعي' : 'AI INSIGHT';
  String get refreshReflection =>
      isArabic ? 'تحديث التأمل' : 'Refresh Reflection';
  String get share => isArabic ? 'مشاركة' : 'Share';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get saved => isArabic ? 'محفوظ!' : 'Saved!';
  String get inspirationalFooter => isArabic
      ? 'العثور على السلام\nفي اللحظة الحالية'
      : 'Finding peace\nin the present moment';

  // Ramadan
  String get ramadanKareem => isArabic ? 'رمضان كريم' : 'Ramadan Kareem';
  String get nextSuhoor => isArabic ? 'السحور القادم' : 'Next Suhoor';
  String get todayIftar => isArabic ? 'إفطار اليوم' : 'Today\'s Iftar';
  String get duaForIftar => isArabic ? 'دعاء الإفطار' : 'Dua for Iftar';
  String get listenToDua => isArabic ? 'استمع إلى الدعاء' : 'Listen to Dua';

  // Settings
  String get preferences => isArabic ? 'التفضيلات' : 'Preferences';
  String get calculationMethod =>
      isArabic ? 'طريقة الحساب' : 'Calculation Method';
  String get asrMadhab => isArabic ? 'مذهب العصر' : 'Asr Madhab';
  String get appTheme => isArabic ? 'مظهر التطبيق' : 'App Theme';
  String get darkMode =>
      isArabic ? 'تبديل الوضع الداكن' : 'Switch to Dark Mode';
  String get language => isArabic ? 'اللغة' : 'Language';
  String get selectLanguage =>
      isArabic ? 'اختر لغة العرض' : 'Select display language';
  String get upgradePremium =>
      isArabic ? 'الترقية إلى بريميوم' : 'Upgrade to Premium';
  String get experienceSerenity =>
      isArabic ? 'تجربة السكينة' : 'Experience Serenity';
  String get premiumDesc => isArabic
      ? 'افتح المزامنة السحابية ومجموعات الأذكار الحصرية.'
      : 'Unlock cloud synchronization, exclusive adkar collections, and high-resolution prayer widgets.';

  // Calendar
  String get upcomingEvents => isArabic ? 'الأحداث القادمة' : 'Upcoming Events';
  String get hijriCalendar => isArabic ? 'التقويم الهجري' : 'Hijri Calendar';

  // Hijri Month Names
  String get muharram => isArabic ? 'محرم' : 'Muharram';
  String get safar => isArabic ? 'صفر' : 'Safar';
  String get rabiAlAwwal => isArabic ? 'ربيع الأول' : 'Rabi Al-Awwal';
  String get rabiAlThani => isArabic ? 'ربيع الآخر' : 'Rabi Al-Thani';
  String get jumadaAlAwwal => isArabic ? 'جمادى الأولى' : 'Jumada Al-Awwal';
  String get jumadaAlThani => isArabic ? 'جمادى الآخرة' : 'Jumada Al-Thani';
  String get rajab => isArabic ? 'رجب' : 'Rajab';
  String get shaban => isArabic ? 'شعبان' : 'Sha\'ban';
  String get ramadan => isArabic ? 'رمضان' : 'Ramadan';
  String get shawwal => isArabic ? 'شوال' : 'Shawwal';
  String get dhulQadah => isArabic ? 'ذو القعدة' : 'Dhul Qa\'dah';
  String get dhulHijjah => isArabic ? 'ذو الحجة' : 'Dhul Hijjah';

  // Islamic Events Names
  String get dayOfAshura => isArabic ? 'يوم عاشوراء' : 'Day of Ashura';
  String get mawlidAlNabi =>
      isArabic ? 'المولد النبوي الشريف' : 'Mawlid Al-Nabi';
  String get israWalMiraj =>
      isArabic ? 'الإسراء والمعراج' : 'Isra\' Wal Mi\'raj';
  String get midShaban => isArabic ? 'ليلة النصف من شعبان' : 'Mid Sha\'ban';
  String get ramadanBegins => isArabic ? 'بداية شهر رمضان' : 'Ramadan Begins';
  String get eidAlFitr => isArabic ? 'عيد الفطر السعيد' : 'Eid Al-Fitr';
  String get eidAlAdha => isArabic ? 'عيد الأضحى المبارك' : 'Eid Al-Adha';

  // Gregorian Months Short
  String shortMonth(int m) {
    if (isArabic) {
      return [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ][m - 1];
    }
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][m - 1];
  }

  // Weekdays Short
  String shortWeekday(int w) {
    if (isArabic) {
      return [
        'الأحد',
        'الإثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
      ][w % 7];
    }
    return ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'][w % 7];
  }
}

// Provider
final stringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(settingsProvider).language;
  return AppStrings(lang == 'ar');
});
