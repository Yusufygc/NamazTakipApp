import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'notification_scheduler.dart';
import '../data/app_database.dart';
import '../data/prayer_repository.dart';
import '../data/settings_repository.dart';
import '../domain/notification_plan.dart';

const String kRefreshTaskName = 'refreshNotifications';
const String _kUniqueName = 'namaz_takip_refresh';

/// Arka plan izolatında çağrılır. Konumu GPS'ten almaz; son bilinen konumla
/// vakitleri cihazda hesaplayıp bildirimleri yeniler.
///
/// İşleyiciyi, Workmanager'ın ister gibi üst düzey bir fonksiyon olarak ön yüz
/// kaydeder (ve metinleri kendi verir); backend yalnızca işi yapar.
void handleBackgroundTasks(NotificationTexts texts) {
  Workmanager().executeTask((task, inputData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = SettingsRepository(prefs);
      final db = await AppDatabase.open();
      if (db.corruptedBackupPath != null) {
        await settings.setCorruptedDbBackup(db.corruptedBackupPath);
      }
      try {
        await NotificationScheduler(
          settings: settings,
          prayers: PrayerRepository(db),
          texts: texts,
        ).reschedule();
      } finally {
        await db.close();
      }
      return true;
    } catch (e) {
      debugPrint('[Background] $e');
      return false;
    }
  });
}

class BackgroundService {
  const BackgroundService();

  /// [entryPoint], `@pragma('vm:entry-point')` ile işaretli üst düzey bir
  /// fonksiyon olmalıdır; içinde `NamazBackend.handleBackgroundTasks` çağrılır.
  Future<void> register(void Function() entryPoint) async {
    await Workmanager().initialize(entryPoint);
    await Workmanager().registerPeriodicTask(
      _kUniqueName,
      kRefreshTaskName,
      frequency: const Duration(hours: 12),
      initialDelay: const Duration(hours: 1),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
