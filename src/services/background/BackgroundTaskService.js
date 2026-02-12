import * as BackgroundFetch from 'expo-background-fetch';
import * as TaskManager from 'expo-task-manager';
import { getLocation } from '../../controllers/LocationController';
import { scheduleMultiDayNotifications } from '../notifications/NotificationService';

const BACKGROUND_PRAYER_FETCH = 'BACKGROUND_PRAYER_FETCH';

/**
 * Arka plan görevi tanımı.
 * Sistem tarafından periyodik olarak çağrılır (~her 12-24 saatte bir).
 * Konum alır → sonraki 3 gün için namaz vakitlerini çeker → bildirimleri planlar.
 */
TaskManager.defineTask(BACKGROUND_PRAYER_FETCH, async () => {
    try {
        console.log('[BackgroundTask] Prayer fetch started');

        // Konum al
        const location = await getLocation();
        console.log('[BackgroundTask] Location:', location.city, location.country);

        // 3 günlük bildirimleri planla
        await scheduleMultiDayNotifications(location);

        console.log('[BackgroundTask] Prayer fetch completed successfully');
        return BackgroundFetch.BackgroundFetchResult.NewData;
    } catch (error) {
        console.error('[BackgroundTask] Prayer fetch failed:', error);
        return BackgroundFetch.BackgroundFetchResult.Failed;
    }
});

/**
 * Arka plan görevini kaydeder.
 * App.js'de uygulama başlangıcında çağrılmalıdır.
 * 
 * minimumInterval: 43200 saniye = 12 saat
 * Sistem bu değeri minimum olarak kabul eder, gerçek çalışma sıklığı
 * iOS/Android'in pil optimizasyon politikalarına bağlıdır.
 */
export const registerBackgroundTask = async () => {
    try {
        const isRegistered = await TaskManager.isTaskRegisteredAsync(BACKGROUND_PRAYER_FETCH);

        if (!isRegistered) {
            await BackgroundFetch.registerTaskAsync(BACKGROUND_PRAYER_FETCH, {
                minimumInterval: 12 * 60 * 60, // 12 saat (saniye cinsinden)
                stopOnTerminate: false, // Uygulama kapatılsa bile devam et
                startOnBoot: true, // Cihaz yeniden başlatıldığında çalış
            });
            console.log('[BackgroundTask] Registered BACKGROUND_PRAYER_FETCH');
        } else {
            console.log('[BackgroundTask] BACKGROUND_PRAYER_FETCH already registered');
        }

        // Mevcut durumu logla
        const status = await BackgroundFetch.getStatusAsync();
        const statusMap = {
            [BackgroundFetch.BackgroundFetchStatus.Restricted]: 'Restricted',
            [BackgroundFetch.BackgroundFetchStatus.Denied]: 'Denied',
            [BackgroundFetch.BackgroundFetchStatus.Available]: 'Available',
        };
        console.log('[BackgroundTask] Status:', statusMap[status] || 'Unknown');

    } catch (error) {
        console.error('[BackgroundTask] Registration failed:', error);
    }
};

/**
 * Arka plan görevini kaldırır (gerekirse).
 */
export const unregisterBackgroundTask = async () => {
    try {
        const isRegistered = await TaskManager.isTaskRegisteredAsync(BACKGROUND_PRAYER_FETCH);
        if (isRegistered) {
            await TaskManager.unregisterTaskAsync(BACKGROUND_PRAYER_FETCH);
            console.log('[BackgroundTask] Unregistered BACKGROUND_PRAYER_FETCH');
        }
    } catch (error) {
        console.error('[BackgroundTask] Unregistration failed:', error);
    }
};
