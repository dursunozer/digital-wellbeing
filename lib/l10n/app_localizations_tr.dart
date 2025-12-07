// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Dijital Sağlık';

  @override
  String get totalScreenTime => 'Bugünkü Toplam Ekran Süresi';

  @override
  String get last24Hours => 'Son 24 saat';

  @override
  String get topApps => 'En Çok Kullanılan 5 Uygulama';

  @override
  String allApps(int count) {
    return 'Tüm Uygulamalar ($count)';
  }

  @override
  String get permissionRequired => 'İzin Gerekli';

  @override
  String get permissionMessage =>
      'Uygulama kullanımınızı takip etmek için kullanım istatistiklerine erişim iznine ihtiyacımız var. Bu, Ayarlar\'da manuel olarak etkinleştirilmesi gereken özel bir Android iznidir.';

  @override
  String get grantPermission => 'İzin Ver';

  @override
  String get whyPermission => 'Neden bu izne ihtiyacımız var?';

  @override
  String get trackUsage => 'Kullanımı Takip Et';

  @override
  String get trackUsageDesc =>
      'Her uygulamada ne kadar zaman harcadığınızı izleyin';

  @override
  String get gainInsights => 'İçgörü Kazanın';

  @override
  String get gainInsightsDesc =>
      'Dijital alışkanlıklarınızı ve kalıplarınızı anlayın';

  @override
  String get reduceScreenTime => 'Ekran Süresini Azaltın';

  @override
  String get reduceScreenTimeDesc =>
      'Uygulama kullanımınız hakkında bilinçli kararlar alın';

  @override
  String get privacyNote => 'Verileriniz cihazınızda kalır ve asla paylaşılmaz';

  @override
  String get noDataAvailable => 'Uygulama kullanım verisi mevcut değil';

  @override
  String get startUsingApps =>
      'İstatistikleri görmek için uygulamaları kullanmaya başlayın';

  @override
  String get loadingData => 'Kullanım verileri yükleniyor...';

  @override
  String get errorLoadingData => 'Veri yükleme hatası';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get timeUnitHours => 'sa';

  @override
  String get timeUnitMinutes => 'dk';

  @override
  String get timeUnitSeconds => 'sn';

  @override
  String get resetUsage => 'Kullanımı Sıfırla';

  @override
  String get resetConfirmTitle => 'Kullanım İstatistikleri Sıfırlansın mı?';

  @override
  String get resetConfirmMessage =>
      'Bu işlem mevcut kullanım verilerini temizleyip yeni istatistikler alacak.';

  @override
  String get cancel => 'İptal';

  @override
  String get reset => 'Sıfırla';

  @override
  String get resetInProgress => 'Kullanım verileri sıfırlanıyor...';
}
