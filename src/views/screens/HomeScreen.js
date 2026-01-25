import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, StyleSheet, ScrollView, Alert, RefreshControl } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { getPrayerTimes, getTodaysPrayersStatus } from '../../controllers/PrayerController';
import { getLocation } from '../../controllers/LocationController';
import { getTodayDateFormatted, formatDateForAPI } from '../../utils/dateHelpers';
import PrayerCard from '../components/PrayerCard';
import CountdownTimer from '../components/CountdownTimer';
import ConfirmationDialog from '../components/ConfirmationDialog';
import { runRun, runQuery } from '../../services/database/DatabaseService';
import { scheduleDailyNotifications, registerForPushNotificationsAsync } from '../../services/notifications/NotificationService';
import { COLORS } from '../../constants/colors';

export default function HomeScreen({ navigation }) {
    const [loading, setLoading] = useState(true);
    const [prayers, setPrayers] = useState([]);
    const [nextPrayer, setNextPrayer] = useState(null);
    const [locationName, setLocationName] = useState('Konum alınıyor...');
    const [dialogVisible, setDialogVisible] = useState(false);
    const [selectedPrayer, setSelectedPrayer] = useState(null);
    const [refreshing, setRefreshing] = useState(false);

    const loadData = async (force = false) => {
        try {
            const today = getTodayDateFormatted();

            // 1. Get Location
            const loc = await getLocation();
            setLocationName(`${loc.city}, ${loc.country}`);

            // 2. Get Prayer Times
            const times = await getPrayerTimes(today, loc.city, loc.country, loc.latitude, loc.longitude, force);

            // 3. Get Status from DB
            const dbStatus = await getTodaysPrayersStatus(today);

            // 4. Get today's qaza prayers to check missed status
            const qazaToday = await runQuery(
                `SELECT prayer_name FROM qaza_prayers WHERE missed_date = ? AND is_compensated = 0`,
                [today]
            );
            const missedPrayers = qazaToday.map(q => q.prayer_name);

            // Merge times and status
            // We expect 5 prayers.
            const prayerOrder = ['Sabah', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
            const mergedPrayers = prayerOrder.map(name => {
                const timeVal = times[name.toLowerCase()] || times[getEnglishName(name)];
                const status = dbStatus.find(p => p.prayer_name === name);
                return {
                    id: status?.id,
                    name: name,
                    time: timeVal, // Check keys carefully. API returns English keys: Fajr, Dhuhr etc.
                    // We need mapping.
                    isPerformed: !!status?.is_performed
                };
            });

            // API returns English keys: Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha
            // Our Controller returns them lowercased or as is.
            // Let's fix mapping in merge.
            const apiMapping = {
                'Sabah': times.fajr,
                'Güneş': times.sunrise, // Extra
                'Öğle': times.dhuhr,
                'İkindi': times.asr,
                'Akşam': times.maghrib,
                'Yatsı': times.isha
            };

            // We only track 5 obligatory + maybe sunrise for display?
            // Prompt shows "Güneş" in UI example but maybe not tracked as prayer?
            // Prompt: "2. prayers tablosu check CHECK(prayer_name IN ('Sabah', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'))"
            // So Sun is distinct.

            const uiPrayers = [];
            // Sabah
            uiPrayers.push(createPrayerObj('Sabah', apiMapping['Sabah'], dbStatus, missedPrayers));
            // Gunes (Display only)
            uiPrayers.push({ name: 'Güneş', time: apiMapping['Güneş'], isPerformed: false, isMissed: false, isDisplayOnly: true });
            // Ogle
            uiPrayers.push(createPrayerObj('Öğle', apiMapping['Öğle'], dbStatus, missedPrayers));
            // Ikindi
            uiPrayers.push(createPrayerObj('İkindi', apiMapping['İkindi'], dbStatus, missedPrayers));
            // Aksam
            uiPrayers.push(createPrayerObj('Akşam', apiMapping['Akşam'], dbStatus, missedPrayers));
            // Yatsi
            uiPrayers.push(createPrayerObj('Yatsı', apiMapping['Yatsı'], dbStatus, missedPrayers));

            setPrayers(uiPrayers);
            calculateNextPrayer(uiPrayers);

            // Schedule notifications for prayer times
            await scheduleDailyNotifications(uiPrayers);

            setLoading(false);
            setRefreshing(false);
        } catch (error) {
            console.error(error);
            setLocationName('Hata oluştu');
            setLoading(false);
            setRefreshing(false);
        }
    };

    const createPrayerObj = (name, time, dbStatus, missedPrayers = []) => {
        const status = dbStatus.find(p => p.prayer_name === name);
        return {
            id: status?.id,
            name: name,
            time: time,
            isPerformed: !!status?.is_performed,
            isMissed: missedPrayers.includes(name),
            isDisplayOnly: false
        };
    };

    const getEnglishName = (trName) => {
        // Helper if needed.
        return trName;
    }

    const calculateNextPrayer = (currentPrayers) => {
        // Simple logic: find first prayer after current time
        const now = new Date();
        const currentTime = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;

        // Find first prayer with time > currentTime
        // Note: This is simple string comparison. Ideally use Date.

        // Filter display only? Usually we count down to next actual event including sunrise?
        // Prompt "Sonraki Namaz: İkindi" (implies next obligatory).

        let next = null;
        for (const p of currentPrayers) {
            if (p.time > currentTime) {
                next = p;
                break;
            }
        }

        // If no next prayer today, it's Fajr tomorrow (not handled well in simple logic yet).
        if (!next && currentPrayers.length > 0) {
            // Technically next is Fajr tomorrow.
            next = currentPrayers[0]; // Just showing first for now or handle tomorrow logic
        }

        setNextPrayer(next);
    };

    useFocusEffect(
        useCallback(() => {
            loadData();
        }, [])
    );

    const handlePrayerPress = (prayer) => {
        if (prayer.isDisplayOnly) return;
        setSelectedPrayer(prayer);
        setDialogVisible(true);
    };

    const handleConfirm = async (isCongregation) => {
        if (!selectedPrayer) return;
        try {
            const today = getTodayDateFormatted();
            // 1. Mark as performed with congregation status
            await runRun(
                'UPDATE prayers SET is_performed = 1, is_congregation = ? WHERE id = ?',
                [isCongregation ? 1 : 0, selectedPrayer.id]
            );

            // 2. Remove from qaza_prayers if exists (Undo missed)
            await runRun(
                'DELETE FROM qaza_prayers WHERE prayer_name = ? AND missed_date = ?',
                [selectedPrayer.name, today]
            );

            setDialogVisible(false);
            loadData(); // Refresh UI
        } catch (e) {
            console.error(e);
        }
    };

    const handleMissed = async () => {
        if (!selectedPrayer) return;
        try {
            // 1. Mark as not performed
            await runRun(
                'UPDATE prayers SET is_performed = 0 WHERE id = ?',
                [selectedPrayer.id]
            );

            // 2. Add to qaza_prayers if not exists
            const today = getTodayDateFormatted();
            const existing = await runQuery(
                `SELECT id FROM qaza_prayers WHERE prayer_name = ? AND missed_date = ?`,
                [selectedPrayer.name, today]
            );

            if (existing.length === 0) {
                await runRun(
                    `INSERT INTO qaza_prayers (prayer_name, missed_date, notes) VALUES (?, ?, ?)`,
                    [selectedPrayer.name, today, 'Marked from Home']
                );
            }

            setDialogVisible(false);
            loadData();
        } catch (e) {
            console.error(e);
        }
    };

    return (
        <ScrollView
            style={styles.container}
            refreshControl={<RefreshControl refreshing={refreshing} onRefresh={() => { setRefreshing(true); loadData(true); }} />}
        >
            <View style={styles.header}>
                <Text style={styles.location}>📍 {locationName}</Text>
            </View>

            {nextPrayer && (
                <CountdownTimer
                    targetTime={nextPrayer.time}
                    nextPrayerName={nextPrayer.name}
                    onPrayerTimeReached={() => loadData()}
                />
            )}

            <Text style={styles.sectionTitle}>BUGÜNÜN NAMAZLARI</Text>
            <View style={styles.list}>
                {prayers.map((p, index) => (
                    <PrayerCard
                        key={index}
                        name={p.name}
                        time={p.time}
                        isPerformed={p.isPerformed}
                        isMissed={p.isMissed}
                        isNext={nextPrayer?.name === p.name}
                        onPress={() => handlePrayerPress(p)}
                    />
                ))}
            </View>

            <ConfirmationDialog
                visible={dialogVisible}
                prayerName={selectedPrayer?.name}
                onClose={() => setDialogVisible(false)}
                onConfirm={handleConfirm}
                onMissed={handleMissed}
                onLater={() => setDialogVisible(false)} // Todo: schedule notification
            />
        </ScrollView>
    );
}


// ... (render logic remains, updating styles at bottom)

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background, // Off-white
        padding: 20
    },
    header: {
        alignItems: 'center',
        marginVertical: 10
    },
    location: {
        fontSize: 18,
        fontWeight: 'bold',
        color: COLORS.text // Text color
    },
    sectionTitle: {
        fontSize: 14,
        color: COLORS.textLight, // Lighter text
        marginBottom: 10,
        marginTop: 10,
        fontWeight: '600',
        letterSpacing: 1
    },
    list: {
        marginBottom: 50
    }
});
