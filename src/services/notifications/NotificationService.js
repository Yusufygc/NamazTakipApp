import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';
import { getNextDaysFormatted } from '../../utils/dateHelpers';
import { getPrayerTimesByCoordinates } from '../api/PrayerTimesAPI';
import { runQuery, runRun } from '../database/DatabaseService';

Notifications.setNotificationHandler({
    handleNotification: async () => ({
        shouldShowBanner: true,
        shouldShowList: true,
        shouldPlaySound: true,
        shouldSetBadge: false,
    }),
});

export const registerForPushNotificationsAsync = async () => {
    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;
    if (existingStatus !== 'granted') {
        const { status } = await Notifications.requestPermissionsAsync();
        finalStatus = status;
    }
    if (finalStatus !== 'granted') {
        console.log('Failed to get push notification permission!');
        return;
    }
    return finalStatus;
};

// Get previous prayer name for reminder
const getPreviousPrayerName = (currentPrayerName) => {
    const prayerOrder = ['Sabah', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
    const currentIndex = prayerOrder.indexOf(currentPrayerName);

    if (currentIndex === -1) return null;

    if (currentIndex === 0) {
        return 'Yatsı'; // Sabah ezanında Yatsı'yı sor (dünkü)
    }
    return prayerOrder[currentIndex - 1];
};

/**
 * Bugünün namazları için bildirim planla (mevcut davranış korunuyor).
 * HomeScreen'den bugünkü prayers dizisi ile çağrılır.
 */
export const scheduleDailyNotifications = async (prayers) => {
    // Bildirim ayarını kontrol et
    const settings = await runQuery(
        "SELECT setting_value FROM app_settings WHERE setting_key = 'notification_enabled'"
    );
    if (settings.length > 0 && settings[0].setting_value === '0') {
        console.log('[Notifications] Disabled by user — skipping');
        await Notifications.cancelAllScheduledNotificationsAsync();
        return;
    }

    // Not: cancelAll burada yapılmaz — scheduleMultiDayNotifications zaten hem bugünü hem gelecek günleri kapsar.

    const now = new Date();
    console.log('[Notifications] Scheduling notifications, current time:', now.toLocaleTimeString());

    for (let i = 0; i < prayers.length; i++) {
        const prayer = prayers[i];

        if (prayer.isDisplayOnly) continue; // Skip Sunrise

        const [hours, minutes] = prayer.time.split(':').map(Number);
        const triggerDate = new Date();
        triggerDate.setHours(hours, minutes, 0, 0);

        if (triggerDate > now) {
            const previousPrayer = getPreviousPrayerName(prayer.name);

            let notificationBody;
            if (previousPrayer) {
                notificationBody = `Selamünaleyküm! ${prayer.name} ezanı okundu. ${previousPrayer} namazını kıldın mı?`;
            } else {
                notificationBody = `${prayer.name} namazı vakti girdi.`;
            }

            console.log(`[Notifications] Scheduling ADHAN for ${prayer.name} at ${hours}:${minutes}`);

            await Notifications.scheduleNotificationAsync({
                content: {
                    title: `${prayer.name} Vakti 🕌`,
                    body: notificationBody,
                    sound: true,
                    data: {
                        prayerName: prayer.name,
                        previousPrayer: previousPrayer,
                        type: 'ADHAN'
                    },
                },
                trigger: {
                    type: 'date',
                    date: triggerDate,
                },
            });

            // Hatırlatma (15 dk sonra)
            const reminderDate = new Date(triggerDate.getTime() + 15 * 60000);

            console.log(`[Notifications] Scheduling REMINDER for ${prayer.name} at ${reminderDate.toLocaleTimeString()}`);

            await Notifications.scheduleNotificationAsync({
                content: {
                    title: `${prayer.name} Namazını Kıldınız mı?`,
                    body: 'Namazınızı işaretlemek için tıklayın.',
                    data: { prayerName: prayer.name, type: 'REMINDER' },
                },
                trigger: {
                    type: 'date',
                    date: reminderDate,
                },
            });
        }
    }

    const scheduled = await Notifications.getAllScheduledNotificationsAsync();
    console.log(`[Notifications] Today scheduled: ${scheduled.length}`);
};

/**
 * Sonraki 3 gün için bildirim planla.
 * Her gün 5 vakit × 2 bildirim (ezan + hatırlatma) = max 30 bildirim.
 * iOS sınırı 64 — güvenli aralıkta.
 * 
 * @param {object} location - { latitude, longitude, city, country }
 */
export const scheduleMultiDayNotifications = async (location) => {
    try {
        // Bildirim ayarını kontrol et
        const settings = await runQuery(
            "SELECT setting_value FROM app_settings WHERE setting_key = 'notification_enabled'"
        );
        if (settings.length > 0 && settings[0].setting_value === '0') {
            console.log('[Notifications] Disabled by user — skipping multi-day');
            await Notifications.cancelAllScheduledNotificationsAsync();
            return;
        }

        // Tüm mevcut bildirimleri temizle (tek nokta)
        await Notifications.cancelAllScheduledNotificationsAsync();

        const dates = getNextDaysFormatted(3); // Bugün + 2 gün sonrası
        const now = new Date();
        let totalScheduled = 0;

        console.log(`[Notifications] Multi-day scheduling for dates: ${dates.join(', ')}`);

        for (let dayOffset = 0; dayOffset < dates.length; dayOffset++) {
            const dateStr = dates[dayOffset];

            try {
                // Önbellekten veya API'den vakitleri çek
                let timings;

                // Önce önbelleğe bak
                const cache = await runQuery(
                    'SELECT * FROM prayer_times_cache WHERE date = ? AND city = ? LIMIT 1',
                    [dateStr, location.city]
                );

                if (cache.length > 0) {
                    timings = {
                        Fajr: cache[0].fajr,
                        Dhuhr: cache[0].dhuhr,
                        Asr: cache[0].asr,
                        Maghrib: cache[0].maghrib,
                        Isha: cache[0].isha,
                    };
                } else {
                    // API'den çek
                    const response = await getPrayerTimesByCoordinates(
                        dateStr,
                        location.latitude,
                        location.longitude
                    );
                    timings = response.data.timings;

                    // Önbelleğe kaydet
                    await runRun(
                        `INSERT OR IGNORE INTO prayer_times_cache (date, city, country, fajr, sunrise, dhuhr, asr, maghrib, isha, latitude, longitude)
                         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                        [
                            dateStr,
                            location.city,
                            location.country,
                            timings.Fajr,
                            timings.Sunrise || '',
                            timings.Dhuhr,
                            timings.Asr,
                            timings.Maghrib,
                            timings.Isha,
                            location.latitude,
                            location.longitude
                        ]
                    );
                }

                // Namaz vakit mapping
                const prayerMapping = [
                    { name: 'Sabah', time: timings.Fajr },
                    { name: 'Öğle', time: timings.Dhuhr },
                    { name: 'İkindi', time: timings.Asr },
                    { name: 'Akşam', time: timings.Maghrib },
                    { name: 'Yatsı', time: timings.Isha },
                ];

                for (const prayer of prayerMapping) {
                    if (!prayer.time) continue;

                    const [hours, minutes] = prayer.time.split(':').map(Number);
                    const triggerDate = new Date();
                    triggerDate.setDate(triggerDate.getDate() + dayOffset);
                    triggerDate.setHours(hours, minutes, 0, 0);

                    // Sadece gelecekteki vakitleri planla
                    if (triggerDate <= now) continue;

                    const previousPrayer = getPreviousPrayerName(prayer.name);

                    let notificationBody;
                    if (previousPrayer) {
                        notificationBody = `Selamünaleyküm! ${prayer.name} ezanı okundu. ${previousPrayer} namazını kıldın mı?`;
                    } else {
                        notificationBody = `${prayer.name} namazı vakti girdi.`;
                    }

                    // 1. Ezan bildirimi
                    await Notifications.scheduleNotificationAsync({
                        content: {
                            title: `${prayer.name} Vakti 🕌`,
                            body: notificationBody,
                            sound: true,
                            data: {
                                prayerName: prayer.name,
                                previousPrayer: previousPrayer,
                                type: 'ADHAN',
                                date: dateStr,
                            },
                        },
                        trigger: {
                            type: 'date',
                            date: triggerDate,
                        },
                    });
                    totalScheduled++;

                    // 2. Hatırlatma (15 dk sonra)
                    const reminderDate = new Date(triggerDate.getTime() + 15 * 60000);
                    await Notifications.scheduleNotificationAsync({
                        content: {
                            title: `${prayer.name} Namazını Kıldınız mı?`,
                            body: 'Namazınızı işaretlemek için tıklayın.',
                            data: {
                                prayerName: prayer.name,
                                type: 'REMINDER',
                                date: dateStr,
                            },
                        },
                        trigger: {
                            type: 'date',
                            date: reminderDate,
                        },
                    });
                    totalScheduled++;
                }
            } catch (dayError) {
                console.error(`[Notifications] Error scheduling for ${dateStr}:`, dayError);
                // Bir gün hata verse bile diğer günlere devam et
            }
        }

        console.log(`[Notifications] Multi-day total scheduled: ${totalScheduled} (limit: 64)`);

        // Log all
        const scheduled = await Notifications.getAllScheduledNotificationsAsync();
        console.log(`[Notifications] Verified scheduled count: ${scheduled.length}`);

    } catch (error) {
        console.error('[Notifications] Multi-day scheduling failed:', error);
    }
};
