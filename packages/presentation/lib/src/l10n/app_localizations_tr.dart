// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get aboutDataSource => 'Hava durumu verileri: Open-Meteo.com';

  @override
  String get aboutLicense => 'Lisans: MIT';

  @override
  String get aboutSourceCode => 'GitHub\'da kaynak kodu';

  @override
  String get aboutTitle => 'Hakkında';

  @override
  String aboutVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get actionBack => 'Geri';

  @override
  String get actionClearSearch => 'Aramayı temizle';

  @override
  String get actionRetry => 'Tekrar dene';

  @override
  String citiesAdd(String name) {
    return '$name ekle';
  }

  @override
  String citiesAlreadySaved(String name) {
    return '$name zaten listenizde';
  }

  @override
  String get citiesEmptySaved => 'Buraya eklemek için bir şehir arayın.';

  @override
  String get citiesNoResults => 'Şehir bulunamadı';

  @override
  String citiesRemove(String name) {
    return '$name kaldır';
  }

  @override
  String citiesRemoved(String name) {
    return '$name kaldırıldı';
  }

  @override
  String get citiesSearchPrompt => 'Şehir ara';

  @override
  String get citiesTitle => 'Şehirler';

  @override
  String get citiesUndo => 'Geri al';

  @override
  String get conditionClear => 'Açık';

  @override
  String get conditionDrizzle => 'Çisenti';

  @override
  String get conditionFog => 'Sisli';

  @override
  String get conditionFreezingDrizzle => 'Donan çisenti';

  @override
  String get conditionFreezingRain => 'Donan yağmur';

  @override
  String get conditionMainlyClear => 'Çoğunlukla açık';

  @override
  String get conditionOvercast => 'Kapalı';

  @override
  String get conditionPartlyCloudy => 'Parçalı bulutlu';

  @override
  String get conditionRain => 'Yağmurlu';

  @override
  String get conditionRainShowers => 'Sağanak yağış';

  @override
  String get conditionSnow => 'Karlı';

  @override
  String get conditionSnowShowers => 'Kar sağanağı';

  @override
  String get conditionThunderstorm => 'Gök gürültülü fırtına';

  @override
  String get conditionThunderstormWithHail => 'Dolulu gök gürültülü fırtına';

  @override
  String get conditionUnknown => 'Bilinmeyen durum';

  @override
  String get errorLocationDenied => 'Konum erişimi kapalı.';

  @override
  String get errorLocationUnavailable =>
      'Konumunuzu bulamadık. Açık havada tekrar deneyin veya bir şehir arayın.';

  @override
  String get errorNoConnection => 'Çevrimdışısınız. Bağlantınızı kontrol edip tekrar deneyin.';

  @override
  String get errorNotFound => 'Bu yeri bulamadık.';

  @override
  String get errorServer =>
      'Hava durumu servisinde şu anda bir sorun var. Lütfen daha sonra tekrar deneyin.';

  @override
  String get errorTimeout => 'Hava durumu servisi çok geç yanıt veriyor.';

  @override
  String get errorUnknown => 'Bir şeyler ters gitti. Lütfen tekrar deneyin.';

  @override
  String get homeAllowLocation => 'Konuma izin ver';

  @override
  String get homeAttribution => 'Hava durumu verileri: Open-Meteo.com';

  @override
  String get homeCurrentLocation => 'Mevcut konum';

  @override
  String homeFeelsLike(String value) {
    return 'Hissedilen $value';
  }

  @override
  String homeHumidity(String value) {
    return 'Nem $value';
  }

  @override
  String get homeLoading => 'Hava durumu yükleniyor';

  @override
  String homeLowHigh(String high, String low) {
    return 'En düşük $low, en yüksek $high';
  }

  @override
  String get homeNext24Hours => 'Önümüzdeki 24 saat';

  @override
  String get homeNext7Days => 'Önümüzdeki 7 gün';

  @override
  String get homeNoLocationMessage =>
      'Bulunduğunuz yerin hava durumunu görmek için konum erişimine izin verin veya bir şehir arayın.';

  @override
  String get homeNoLocationTitle => 'Neredesiniz?';

  @override
  String get homeNow => 'Şimdi';

  @override
  String get homeOpenCities => 'Şehirler';

  @override
  String get homeOpenSettings => 'Ayarlar';

  @override
  String homePrecipitationChance(String value) {
    return 'Yağış olasılığı $value';
  }

  @override
  String get homeSearchCity => 'Şehir ara';

  @override
  String homeSunriseSunset(String sunrise, String sunset) {
    return 'Gün doğumu $sunrise · Gün batımı $sunset';
  }

  @override
  String get homeToday => 'Bugün';

  @override
  String homeUpdatedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün önce güncellendi',
      one: '$count gün önce güncellendi',
    );
    return '$_temp0';
  }

  @override
  String homeUpdatedHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saat önce güncellendi',
      one: '$count saat önce güncellendi',
    );
    return '$_temp0';
  }

  @override
  String homeUpdatedMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dakika önce güncellendi',
      one: '$count dakika önce güncellendi',
    );
    return '$_temp0';
  }

  @override
  String homeWind(String value) {
    return 'Rüzgâr $value';
  }

  @override
  String get languageName => 'Türkçe';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get settingsLanguageFooter => 'Uygulama dili telefonunuzun ayarlarını izler.';

  @override
  String get settingsLanguageOpen => 'Dili değiştir';

  @override
  String get settingsLanguageTitle => 'Dil';

  @override
  String get settingsTemperature => 'Sıcaklık';

  @override
  String get settingsThemeDark => 'Koyu';

  @override
  String get settingsThemeLight => 'Açık';

  @override
  String get settingsThemeSystem => 'Sistem';

  @override
  String get settingsThemeTitle => 'Tema';

  @override
  String get settingsTitle => 'Ayarlar';

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
  String get settingsWindSpeed => 'Rüzgâr hızı';
}
