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

  @override
  String get today => 'BUGÜN';

  @override
  String get unlocks => 'Kilit Açma';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get viewAppActivityDetails =>
      'Uygulama etkinlik ayrıntılarını görüntüle';

  @override
  String get waysToDisconnect => 'Bağlantıyı kesme yolları';

  @override
  String get reduceInterruptions => 'Kesintileri azaltın';

  @override
  String get appTimers => 'Uygulama zamanlayıcıları';

  @override
  String get appTimersSubtitle => 'Zamanlayıcı ayarlanmadı';

  @override
  String appTimersSubtitleCount(int count) {
    return '$count zamanlayıcı ayarlandı';
  }

  @override
  String get bedtimeMode => 'Uyku vakti modu';

  @override
  String get bedtimeModeOff => 'Kapalı';

  @override
  String bedtimeModeSchedule(String start, String end) {
    return '$start - $end';
  }

  @override
  String get focus => 'Odaklanma';

  @override
  String get focusTapToSetUp => 'Ayarlamak için dokunun';

  @override
  String get focusActive => 'Aktif';

  @override
  String get screenTimeReminders => 'Ekran süresi hatırlatıcıları';

  @override
  String get screenTimeRemindersOff => 'Kapalı';

  @override
  String get screenTimeRemindersOn => 'Açık';

  @override
  String get manageNotifications => 'Bildirimleri yönet';

  @override
  String get headsUp => 'Dikkat';

  @override
  String get headsUpSubtitle => 'Ayarlamak için dokunun';

  @override
  String get appActivityTitle => 'Uygulama etkinliği';

  @override
  String get dailyAverage => 'Günlük ortalama';

  @override
  String get thisWeek => 'Bu hafta';

  @override
  String get usageByApp => 'Uygulamaya göre kullanım';

  @override
  String get setTimer => 'Zamanlayıcı ayarla';

  @override
  String get dailyLimit => 'Günlük limit';

  @override
  String get noLimit => 'Limit yok';

  @override
  String get minutes => 'dakika';

  @override
  String get hours => 'saat';

  @override
  String get timerSet => 'Zamanlayıcı ayarlandı';

  @override
  String get timerRemoved => 'Zamanlayıcı kaldırıldı';

  @override
  String get bedtimeSettingsTitle => 'Uyku vakti modu';

  @override
  String get bedtimeStart => 'Başlangıç saati';

  @override
  String get bedtimeEnd => 'Bitiş saati';

  @override
  String get bedtimeActiveDays => 'Aktif günler';

  @override
  String get bedtimeOptions => 'Uyku vakti seçenekleri';

  @override
  String get grayscale => 'Gri tonlama';

  @override
  String get doNotDisturb => 'Rahatsız Etmeyin';

  @override
  String get focusModeTitle => 'Odaklanma modu';

  @override
  String get selectAppsToBlock => 'Duraklatılacak uygulamaları seçin';

  @override
  String get takeABreak => 'Mola ver';

  @override
  String get startFocus => 'Odaklanmayı başlat';

  @override
  String get endFocus => 'Odaklanmayı bitir';

  @override
  String get reminderThreshold => 'Şu süreden sonra hatırlat';

  @override
  String get addReminder => 'Hatırlatıcı ekle';

  @override
  String get editReminder => 'Hatırlatıcıyı düzenle';

  @override
  String get deleteReminder => 'Hatırlatıcıyı sil';

  @override
  String get monday => 'Pzt';

  @override
  String get tuesday => 'Sal';

  @override
  String get wednesday => 'Çar';

  @override
  String get thursday => 'Per';

  @override
  String get friday => 'Cum';

  @override
  String get saturday => 'Cmt';

  @override
  String get sunday => 'Paz';

  @override
  String get save => 'Kaydet';

  @override
  String get delete => 'Sil';

  @override
  String get enable => 'Etkinleştir';

  @override
  String get disable => 'Devre dışı bırak';

  @override
  String get on => 'Açık';

  @override
  String get off => 'Kapalı';

  @override
  String get limit => 'Limit';

  @override
  String get remaining => 'kaldı';

  @override
  String get limitExceeded => 'Limit aşıldı';
}
