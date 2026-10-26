import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../data/app_database.dart';
import '../data/prayer_repository.dart';
import '../data/settings_repository.dart';
import 'notification_scheduler.dart';

const String kRefreshTaskName = 'refreshNotifications';
const String _kUniqueName = 'namaz_takip_refresh';

/// Workmanager tarafından ayrı izolatta çağrılır. Konumu GPS'ten almaz,
/// son bilinen konumla vakitleri cihazda hesaplayıp bildirimleri yeniler.
@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final db = await AppDatabase.open();
      try {
        await NotificationScheduler(
          settings: SettingsRepository(prefs),
          prayers: PrayerRepository(db),
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

  Future<void> register() async {
    await Workmanager().initialize(backgroundDispatcher);
    await Workmanager().registerPeriodicTask(
      _kUniqueName,
      kRefreshTaskName,
      frequency: const Duration(hours: 12),
      initialDelay: const Duration(hours: 1),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
