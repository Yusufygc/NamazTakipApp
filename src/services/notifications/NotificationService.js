import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';

Notifications.setNotificationHandler({
    handleNotification: async () => ({
        shouldShowAlert: true,
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
                    hour: hours,
                    minute: minutes,
                    repeats: false, // Just for today
                },
            });

            // 2. Hatırlatma (15 dk sonra) - Güncel namazı hatırlat
            const reminderDate = new Date(triggerDate.getTime() + 15 * 60000);
            const rHours = reminderDate.getHours();
            const rMinutes = reminderDate.getMinutes();

            await Notifications.scheduleNotificationAsync({
                content: {
                    title: `${prayer.name} Namazını Kıldınız mı?`,
                    body: 'Namazınızı işaretlemek için tıklayın.',
                    data: { prayerName: prayer.name, type: 'REMINDER' },
                },
                trigger: {
                    hour: rHours,
                    minute: rMinutes,
                    repeats: false,
                },
            });
        }
    }
};

