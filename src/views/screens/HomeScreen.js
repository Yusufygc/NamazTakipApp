import React, { useState, useCallback, useMemo } from 'react';
import { View, Text, StyleSheet, ScrollView, RefreshControl } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { getPrayerTimes, getTodaysPrayersStatus } from '../../controllers/PrayerController';
import { getLocation } from '../../controllers/LocationController';
import { getPrayerDateFormatted } from '../../utils/dateHelpers';
import PrayerCard from '../components/PrayerCard';
import CountdownTimer from '../components/CountdownTimer';
import ConfirmationDialog from '../components/ConfirmationDialog';
import { runRun, runQuery } from '../../services/database/DatabaseService';
import { scheduleDailyNotifications, scheduleMultiDayNotifications } from '../../services/notifications/NotificationService';
import { useTheme } from '../../context/ThemeContext';

export default function HomeScreen({ navigation }) {
    const [loading, setLoading] = useState(true);
    const [prayers, setPrayers] = useState([]);
    const [nextPrayer, setNextPrayer] = useState(null);
    const [locationName, setLocationName] = useState('Konum alınıyor...');
    const [dialogVisible, setDialogVisible] = useState(false);
    const [selectedPrayer, setSelectedPrayer] = useState(null);
    const [refreshing, setRefreshing] = useState(false);
    const { colors } = useTheme();

    // Ref to cache location so we don't re-fetch GPS on every focus
    const locationRef = React.useRef(null);
    const timesRef = React.useRef(null);
    const notificationsScheduled = React.useRef(false);

    /**
     * Sadece DB'den namaz durumlarını oku — hızlı, bağımsız.
     * Konum, API ve bildirim planlaması YAPMAZ.
     */
    const refreshPrayerStatus = async (times) => {
        const today = getPrayerDateFormatted();
        const dbStatus = await getTodaysPrayersStatus(today);

        const qazaToday = await runQuery(
            `SELECT prayer_name FROM qaza_prayers WHERE missed_date = ? AND is_compensated = 0`,
            [today]
        );
        const missedPrayers = qazaToday.map(q => q.prayer_name);

        const apiMapping = {
            'Sabah': times.fajr,
            'Güneş': times.sunrise,
            'Öğle': times.dhuhr,
            'İkindi': times.asr,
            'Akşam': times.maghrib,
            'Yatsı': times.isha
        };

        const uiPrayers = [];
        uiPrayers.push(createPrayerObj('Sabah', apiMapping['Sabah'], dbStatus, missedPrayers));
        uiPrayers.push({ name: 'Güneş', time: apiMapping['Güneş'], isPerformed: false, isMissed: false, isDisplayOnly: true });
        uiPrayers.push(createPrayerObj('Öğle', apiMapping['Öğle'], dbStatus, missedPrayers));
        uiPrayers.push(createPrayerObj('İkindi', apiMapping['İkindi'], dbStatus, missedPrayers));
        uiPrayers.push(createPrayerObj('Akşam', apiMapping['Akşam'], dbStatus, missedPrayers));
        uiPrayers.push(createPrayerObj('Yatsı', apiMapping['Yatsı'], dbStatus, missedPrayers));

        setPrayers(uiPrayers);
        calculateNextPrayer(uiPrayers);
        return uiPrayers;
    };

    /**
     * Tam yükleme: Konum → API → DB → Bildirimler
     * Sadece ilk açılış ve pull-to-refresh'te çalışır.
     */
    const loadData = async (force = false) => {
        try {
            const today = getPrayerDateFormatted();

            // 1. Get Location
            const loc = await getLocation();
            locationRef.current = loc;
            setLocationName(`${loc.city}, ${loc.country}`);

            // 2. Get Prayer Times (cache veya API)
            const times = await getPrayerTimes(today, loc.city, loc.country, loc.latitude, loc.longitude, force);
            timesRef.current = times;

            // 3. DB'den namaz durumlarını oku ve UI güncelle
            const uiPrayers = await refreshPrayerStatus(times);

            // 4. Bildirimleri planla (ilk yükleme veya force refresh'te)
            if (!notificationsScheduled.current || force) {
                notificationsScheduled.current = true;
                scheduleDailyNotifications(uiPrayers).catch(err => console.error('[Notifications]', err));
                scheduleMultiDayNotifications(loc).catch(err => console.error('[Notifications] Multi-day:', err));
            }

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
            const today = getPrayerDateFormatted();

            // Optimistic UI update — anında yansıt
            setPrayers(prev => prev.map(p =>
                p.name === selectedPrayer.name
                    ? { ...p, isPerformed: true, isMissed: false }
                    : p
            ));
            setDialogVisible(false);

            // DB güncelle (arka planda)
            await runRun(
                'UPDATE prayers SET is_performed = 1, is_congregation = ? WHERE id = ?',
                [isCongregation ? 1 : 0, selectedPrayer.id]
            );
            await runRun(
                'DELETE FROM qaza_prayers WHERE prayer_name = ? AND missed_date = ?',
                [selectedPrayer.name, today]
            );
        } catch (e) {
            console.error(e);
            // Hata olursa veriyi yeniden yükle
            loadData();
        }
    };

    const handleMissed = async () => {
        if (!selectedPrayer) return;
        try {
            const today = getPrayerDateFormatted();

            // Optimistic UI update — anında yansıt
            setPrayers(prev => prev.map(p =>
                p.name === selectedPrayer.name
                    ? { ...p, isPerformed: false, isMissed: true }
                    : p
            ));
            setDialogVisible(false);

            // DB güncelle (arka planda)
            await runRun(
                'UPDATE prayers SET is_performed = 0 WHERE id = ?',
                [selectedPrayer.id]
            );

            const existing = await runQuery(
                `SELECT id FROM qaza_prayers WHERE prayer_name = ? AND missed_date = ?`,
                [selectedPrayer.name, today]
            );

            if (existing.length === 0) {
                await runRun(
                    `INSERT INTO qaza_prayers (prayer_name, missed_date, notes) VALUES (?, ?, ?)`,
                    [selectedPrayer.name, today, '']
                );
            }
        } catch (e) {
            console.error(e);
            loadData();
        }
    };

    const styles = useMemo(() => getStyles(colors), [colors]);

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
                    onPrayerTimeReached={() => { if (timesRef.current) refreshPrayerStatus(timesRef.current); }}
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
                        isDisplayOnly={p.isDisplayOnly}
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

const getStyles = (colors) => StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: colors.background, // Off-white
        padding: 15 // Reduced padding
    },
    header: {
        alignItems: 'center',
        marginVertical: 5 // Reduced margin
    },
    location: {
        fontSize: 16,
        fontWeight: 'bold',
        color: colors.text,
        marginBottom: 5
    },
    sectionTitle: {
        fontSize: 13,
        color: colors.textLight, // Lighter text
        marginBottom: 8,
        marginTop: 5,
        fontWeight: '600',
        letterSpacing: 1
    },
    list: {
        marginBottom: 20
    }
});
