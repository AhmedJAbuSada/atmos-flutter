// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get aboutDataSource => 'بيانات الطقس من Open-Meteo.com';

  @override
  String get aboutLicense => 'الترخيص: MIT';

  @override
  String get aboutSourceCode => 'الشيفرة المصدرية على GitHub';

  @override
  String get aboutTitle => 'حول التطبيق';

  @override
  String aboutVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get actionBack => 'رجوع';

  @override
  String get actionClearSearch => 'مسح البحث';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String citiesAdd(String name) {
    return 'إضافة $name';
  }

  @override
  String citiesAlreadySaved(String name) {
    return '$name موجودة في قائمتك بالفعل';
  }

  @override
  String get citiesEmptySaved => 'ابحث عن مدينة لإضافتها هنا.';

  @override
  String get citiesNoResults => 'لم يتم العثور على مدن';

  @override
  String citiesRemove(String name) {
    return 'إزالة $name';
  }

  @override
  String citiesRemoved(String name) {
    return 'تمت إزالة $name';
  }

  @override
  String get citiesSearchPrompt => 'ابحث عن مدينة';

  @override
  String get citiesTitle => 'المدن';

  @override
  String get citiesUndo => 'تراجع';

  @override
  String get conditionClear => 'صافٍ';

  @override
  String get conditionDrizzle => 'رذاذ';

  @override
  String get conditionFog => 'ضباب';

  @override
  String get conditionFreezingDrizzle => 'رذاذ متجمد';

  @override
  String get conditionFreezingRain => 'مطر متجمد';

  @override
  String get conditionMainlyClear => 'صافٍ غالبًا';

  @override
  String get conditionOvercast => 'غائم';

  @override
  String get conditionPartlyCloudy => 'غائم جزئيًا';

  @override
  String get conditionRain => 'مطر';

  @override
  String get conditionRainShowers => 'زخات مطر';

  @override
  String get conditionSnow => 'ثلج';

  @override
  String get conditionSnowShowers => 'زخات ثلج';

  @override
  String get conditionThunderstorm => 'عاصفة رعدية';

  @override
  String get conditionThunderstormWithHail => 'عاصفة رعدية مع بَرَد';

  @override
  String get conditionUnknown => 'حالة غير معروفة';

  @override
  String get errorLocationDenied => 'الوصول إلى الموقع متوقف.';

  @override
  String get errorLocationUnavailable =>
      'لم نتمكن من تحديد موقعك. حاول مرة أخرى في مكان مفتوح أو ابحث عن مدينة.';

  @override
  String get errorNoConnection => 'أنت غير متصل بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get errorNotFound => 'لم نتمكن من العثور على هذا المكان.';

  @override
  String get errorServer => 'هناك مشكلة في خدمة الطقس حاليًا. يرجى المحاولة لاحقًا.';

  @override
  String get errorTimeout => 'خدمة الطقس تستغرق وقتًا طويلًا للرد.';

  @override
  String get errorUnknown => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get homeAllowLocation => 'السماح بالموقع';

  @override
  String get homeAttribution => 'بيانات الطقس من Open-Meteo.com';

  @override
  String get homeCurrentLocation => 'الموقع الحالي';

  @override
  String homeFeelsLike(String value) {
    return 'الإحساس $value';
  }

  @override
  String homeHumidity(String value) {
    return 'الرطوبة $value';
  }

  @override
  String get homeLoading => 'جارٍ تحميل التوقعات';

  @override
  String homeLowHigh(String high, String low) {
    return 'الصغرى $low، العظمى $high';
  }

  @override
  String get homeNext24Hours => 'الساعات الـ 24 القادمة';

  @override
  String get homeNext7Days => 'الأيام السبعة القادمة';

  @override
  String get homeNoLocationMessage =>
      'اسمح بالوصول إلى الموقع لترى الطقس حيث أنت، أو ابحث عن مدينة.';

  @override
  String get homeNoLocationTitle => 'أين أنت؟';

  @override
  String get homeNow => 'الآن';

  @override
  String get homeOpenCities => 'المدن';

  @override
  String get homeOpenSettings => 'الإعدادات';

  @override
  String homePrecipitationChance(String value) {
    return 'احتمال الهطول $value';
  }

  @override
  String get homeSearchCity => 'البحث عن مدينة';

  @override
  String homeSunriseSunset(String sunrise, String sunset) {
    return 'الشروق $sunrise · الغروب $sunset';
  }

  @override
  String get homeToday => 'اليوم';

  @override
  String homeUpdatedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم التحديث قبل $count يوم',
      many: 'تم التحديث قبل $count يومًا',
      few: 'تم التحديث قبل $count أيام',
      two: 'تم التحديث قبل يومين',
      one: 'تم التحديث قبل يوم',
      zero: 'تم التحديث اليوم',
    );
    return '$_temp0';
  }

  @override
  String homeUpdatedHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم التحديث قبل $count ساعة',
      many: 'تم التحديث قبل $count ساعة',
      few: 'تم التحديث قبل $count ساعات',
      two: 'تم التحديث قبل ساعتين',
      one: 'تم التحديث قبل ساعة',
      zero: 'تم التحديث الآن',
    );
    return '$_temp0';
  }

  @override
  String homeUpdatedMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم التحديث قبل $count دقيقة',
      many: 'تم التحديث قبل $count دقيقة',
      few: 'تم التحديث قبل $count دقائق',
      two: 'تم التحديث قبل دقيقتين',
      one: 'تم التحديث قبل دقيقة',
      zero: 'تم التحديث الآن',
    );
    return '$_temp0';
  }

  @override
  String homeWind(String value) {
    return 'الرياح $value';
  }

  @override
  String get languageName => 'العربية';

  @override
  String get settingsAbout => 'حول التطبيق';

  @override
  String get settingsLanguageFooter => 'لغة التطبيق تتبع إعدادات هاتفك.';

  @override
  String get settingsLanguageOpen => 'تغيير اللغة';

  @override
  String get settingsLanguageTitle => 'اللغة';

  @override
  String get settingsTemperature => 'درجة الحرارة';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeSystem => 'حسب النظام';

  @override
  String get settingsThemeTitle => 'المظهر';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsUnitCelsius => '°C';

  @override
  String get settingsUnitFahrenheit => '°F';

  @override
  String get settingsUnitKilometersPerHour => 'km/h';

  @override
  String get settingsUnitMetersPerSecond => 'm/s';

  @override
  String get settingsUnitMilesPerHour => 'mph';

  @override
  String get settingsWindSpeed => 'سرعة الرياح';
}
