import * as BackgroundTask from 'expo-background-task';
import * as TaskManager from 'expo-task-manager';
import { getLocation } from '../../controllers/LocationController';
import { scheduleMultiDayNotifications } from '../notifications/NotificationService';

const BACKGROUND_PRAYER_TASK = 'BACKGROUND_PRAYER_TASK';

/**
 * Arka plan görevi tanımı.
 * Sistem tarafından periyodik olarak çağrılır.
 * Konum alır → sonraki 3 gün için namaz vakitlerini çeker → bildirimleri planlar.
 */
TaskManager.defineTask(BACKGROUND_PRAYER_TASK, async () => {
    try {
        console.log('[BackgroundTask] Prayer task started');

        const location = await getLocation();
        console.log('[BackgroundTask] Location:', location.city, location.country);

        await scheduleMultiDayNotifications(location);

        console.log('[BackgroundTask] Prayer task completed successfully');
        return BackgroundTask.BackgroundTaskResult.Success;
    } catch (error) {
        console.error('[BackgroundTask] Prayer task failed:', error);
        return BackgroundTask.BackgroundTaskResult.Failed;
    }
});

/**
 * Arka plan görevini kaydeder.
 * App.js'de uygulama başlangıcında çağrılmalıdır.
 */
export const registerBackgroundTask = async () => {
    try {
        // Önce durumu kontrol et — Expo Go'da Restricted döner
        const status = await BackgroundTask.getStatusAsync();

        if (status === BackgroundTask.BackgroundTaskStatus.Restricted) {
            console.log('[BackgroundTask] Skipped — not available (Expo Go or restricted)');
            return;
        }

        if (status === BackgroundTask.BackgroundTaskStatus.Denied) {
            console.log('[BackgroundTask] Skipped — background task permission denied');
            return;
        }

        const isRegistered = await TaskManager.isTaskRegisteredAsync(BACKGROUND_PRAYER_TASK);

        if (!isRegistered) {
            await BackgroundTask.registerTaskAsync(BACKGROUND_PRAYER_TASK);
            console.log('[BackgroundTask] Registered BACKGROUND_PRAYER_TASK');
        } else {
            console.log('[BackgroundTask] BACKGROUND_PRAYER_TASK already registered');
        }

        console.log('[BackgroundTask] Status: Available');

    } catch (error) {
        // Expo Go'da bu hata bekleniyor, sessizce geç
        console.log('[BackgroundTask] Not available in this environment');
    }
};

/**
 * Arka plan görevini kaldırır.
 */
export const unregisterBackgroundTask = async () => {
    try {
        const isRegistered = await TaskManager.isTaskRegisteredAsync(BACKGROUND_PRAYER_TASK);
        if (isRegistered) {
            await BackgroundTask.unregisterTaskAsync(BACKGROUND_PRAYER_TASK);
            console.log('[BackgroundTask] Unregistered BACKGROUND_PRAYER_TASK');
        }
    } catch (error) {
        console.error('[BackgroundTask] Unregistration failed:', error);
    }
};
