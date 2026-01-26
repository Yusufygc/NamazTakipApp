import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';

Notifications.setNotificationHandler({
    handleNotification: async () => ({
        shouldShowBanner: true,
        shouldShowList: true,
        shouldPlaySound: true,
        shouldSetBadge: false,
    }),
});

export const registerForPushNotificationsAsync = async () => {
    let token;
    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;
    if (existingStatus !== 'granted') {
        const { status } = await Notifications.requestPermissionsAsync();
        finalStatus = status;
    }
    if (finalStatus !== 'granted') {
        console.log('Failed to get push token for push notification!');
        return;
    }
    return finalStatus;
};

// Get previous prayer name for reminder
const getPreviousPrayerName = (currentPrayerName) => {
    const prayerOrder = ['Sabah', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
    const currentIndex = prayerOrder.indexOf(currentPrayerName);

    if (currentIndex === -1) return null;

    // Sabah -> Yatsı (previous day)
    // Öğle -> Sabah
    // İkindi -> Öğle
    // Akşam -> İkindi
    // Yatsı -> Akşam
    if (currentIndex === 0) {
        return 'Yatsı'; // Sabah ezanında Yatsı'yı sor (dünkü)
    }
    return prayerOrder[currentIndex - 1];
};

export const scheduleDailyNotifications = async (prayers) => {
    // Cancel all existing to avoid duplicates
    await Notifications.cancelAllScheduledNotificationsAsync();

    const now = new Date();
    console.log('[Notifications] Scheduling notifications, current time:', now.toLocaleTimeString());

    for (let i = 0; i < prayers.length; i++) {
        const prayer = prayers[i];

        if (prayer.isDisplayOnly) continue; // Skip Sunrise

        const [hours, minutes] = prayer.time.split(':').map(Number);
        const triggerDate = new Date();
        triggerDate.setHours(hours, minutes, 0, 0);

        if (triggerDate > now) {
            // Get previous prayer name for the reminder
            const previousPrayer = getPreviousPrayerName(prayer.name);

            // 1. Ezan Vakti - Bir önceki namazı hatırlat
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

            // 2. Hatırlatma (15 dk sonra) - Güncel namazı hatırlat
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

    // Log scheduled notifications for debugging
    const scheduled = await Notifications.getAllScheduledNotificationsAsync();
    console.log(`[Notifications] Total scheduled: ${scheduled.length}`);
    scheduled.forEach((n) => {
        console.log(`[Notifications] - ${n.content.title} at ${new Date(n.trigger.value).toLocaleTimeString()}`);
    });
};

