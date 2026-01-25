import React, { useState, useCallback } from 'react';
import { View, Text, FlatList, TouchableOpacity, StyleSheet, Alert, LayoutAnimation, Platform, UIManager } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { runQuery, runRun } from '../../services/database/DatabaseService';
import { getTodayDateFormatted } from '../../utils/dateHelpers';
import { COLORS } from '../../constants/colors';

// Enable LayoutAnimation for Android
if (Platform.OS === 'android' && UIManager.setLayoutAnimationEnabledExperimental) {
    UIManager.setLayoutAnimationEnabledExperimental(true);
}

// Group qaza prayers by date
const groupByDate = (qazaList) => {
    const grouped = {};
    qazaList.forEach(item => {
        if (!grouped[item.missed_date]) {
            grouped[item.missed_date] = [];
        }
        grouped[item.missed_date].push(item);
    });

    return Object.entries(grouped)
        .map(([date, prayers]) => ({
            date,
            prayers,
            kazaCount: prayers.length
        }))
        .sort((a, b) => b.date.localeCompare(a.date)); // En yeni tarih önce
};

// Format date for display (2026-01-25 -> 25 Ocak 2026)
const formatDateForDisplay = (dateStr) => {
    const months = [
        'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
        'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    const parts = dateStr.split('-');
    if (parts.length === 3) {
        const day = parseInt(parts[2], 10);
        const month = months[parseInt(parts[1], 10) - 1];
        const year = parts[0];
        return `${day} ${month} ${year}`;
    }
    return dateStr;
};

// DayCard Component - Expandable card for each day
const DayCard = ({ date, prayers, kazaCount, onCompensate, expandedDate, setExpandedDate }) => {
    const isExpanded = expandedDate === date;

    const toggleExpand = () => {
        LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
        setExpandedDate(isExpanded ? null : date);
    };

    return (
        <View style={styles.dayCard}>
            {/* Header - Always visible */}
            <TouchableOpacity
                style={[styles.dayCardHeader, isExpanded && styles.dayCardHeaderExpanded]}
                onPress={toggleExpand}
                activeOpacity={0.7}
            >
                <View style={styles.dateContainer}>
                    <Text style={styles.calendarIcon}>📅</Text>
                    <Text style={styles.dateText}>{formatDateForDisplay(date)}</Text>
                </View>
                <View style={styles.badgeContainer}>
                    <View style={styles.kazaBadge}>
                        <Text style={styles.kazaBadgeText}>{kazaCount} Kaza</Text>
                    </View>
                    <Text style={styles.expandIcon}>{isExpanded ? '▲' : '▼'}</Text>
                </View>
            </TouchableOpacity>

            {/* Expanded Content - Prayer list */}
            {isExpanded && (
                <View style={styles.prayerListContainer}>
                    {prayers.map((prayer) => (
                        <View key={prayer.id} style={styles.prayerItem}>
                            <View style={styles.prayerInfo}>
                                <Text style={styles.missedIcon}>❌</Text>
                                <Text style={styles.prayerName}>{prayer.prayer_name}</Text>
                                {prayer.notes && (
                                    <Text style={styles.prayerNotes}>({prayer.notes})</Text>
                                )}
                            </View>
                            <TouchableOpacity
                                style={styles.compensateButton}
                                onPress={() => onCompensate(prayer)}
                            >
                                <Text style={styles.compensateButtonText}>Kaza Et</Text>
                            </TouchableOpacity>
                        </View>
                    ))}
                </View>
            )}
        </View>
    );
};

export default function QazaListScreen() {
    const [qazaList, setQazaList] = useState([]);
    const [loading, setLoading] = useState(true);
    const [expandedDate, setExpandedDate] = useState(null);

    const loadQaza = async () => {
        try {
            // Fetch uncompensated qaza prayers
            const result = await runQuery(
                `SELECT * FROM qaza_prayers WHERE is_compensated = 0 ORDER BY missed_date DESC, id DESC`
            );
            setQazaList(result);
            setLoading(false);
        } catch (e) {
            console.error(e);
            setLoading(false);
        }
    };

    useFocusEffect(
        useCallback(() => {
            loadQaza();
        }, [])
    );

    const handleCompensate = (item) => {
        Alert.alert(
            'Kaza Namazı',
            `${formatDateForDisplay(item.missed_date)} tarihli ${item.prayer_name} namazını kaza ettiniz mi?`,
            [
                { text: 'İptal', style: 'cancel' },
                {
                    text: 'Evet, Kıldım',
                    onPress: async () => {
                        try {
                            const today = getTodayDateFormatted();
                            // 1. Mark as compensated in qaza_prayers
                            await runRun(
                                `UPDATE qaza_prayers SET is_compensated = 1, compensated_at = ? WHERE id = ?`,
                                [today, item.id]
                            );

                            // 2. Update original prayer record if exists
                            await runRun(
                                `UPDATE prayers SET is_performed = 1 WHERE date = ? AND prayer_name = ?`,
                                [item.missed_date, item.prayer_name]
                            );

                            loadQaza();
                        } catch (e) {
                            console.error(e);
                        }
                    }
                }
            ]
        );
    };

    // Group prayers by date
    const groupedQaza = groupByDate(qazaList);

    // Calculate total kaza count
    const totalKazaCount = qazaList.length;

    const renderDayCard = ({ item }) => (
        <DayCard
            date={item.date}
            prayers={item.prayers}
            kazaCount={item.kazaCount}
            onCompensate={handleCompensate}
            expandedDate={expandedDate}
            setExpandedDate={setExpandedDate}
        />
    );

    return (
        <View style={styles.container}>
            {/* Summary Header */}
            {totalKazaCount > 0 && (
                <View style={styles.summaryHeader}>
                    <Text style={styles.summaryText}>
                        Toplam <Text style={styles.summaryCount}>{totalKazaCount}</Text> kaza namazınız bulunmaktadır
                    </Text>
                </View>
            )}

            {qazaList.length === 0 ? (
                <View style={styles.empty}>
                    <Text style={styles.emptyIcon}>🤲</Text>
                    <Text style={styles.emptyText}>Kaza borcunuz bulunmuyor</Text>
                    <Text style={styles.emptySubtext}>Tüm namazlarınızı vaktinde kılıyorsunuz</Text>
                </View>
            ) : (
                <FlatList
                    data={groupedQaza}
                    renderItem={renderDayCard}
                    keyExtractor={item => item.date}
                    contentContainerStyle={styles.list}
                    showsVerticalScrollIndicator={false}
                />
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
        padding: 12
    },
    summaryHeader: {
        backgroundColor: COLORS.accent,
        padding: 12,
        borderRadius: 10,
        marginBottom: 12,
        alignItems: 'center'
    },
    summaryText: {
        fontSize: 14,
        color: COLORS.text
    },
    summaryCount: {
        fontWeight: 'bold',
        color: COLORS.danger,
        fontSize: 16
    },
    list: {
        paddingBottom: 20
    },
    dayCard: {
        backgroundColor: COLORS.white,
        borderRadius: 12,
        marginBottom: 10,
        elevation: 3,
        shadowColor: COLORS.dark,
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.15,
        shadowRadius: 5,
        overflow: 'hidden'
    },
    dayCardHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: 16,
        backgroundColor: COLORS.white
    },
    dayCardHeaderExpanded: {
        backgroundColor: COLORS.primary,
        borderBottomWidth: 1,
        borderBottomColor: 'rgba(0,0,0,0.05)'
    },
    dateContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        flex: 1
    },
    calendarIcon: {
        fontSize: 18,
        marginRight: 10
    },
    dateText: {
        fontSize: 16,
        fontWeight: '600',
        color: COLORS.text
    },
    badgeContainer: {
        flexDirection: 'row',
        alignItems: 'center'
    },
    kazaBadge: {
        backgroundColor: COLORS.danger,
        paddingHorizontal: 10,
        paddingVertical: 5,
        borderRadius: 15,
        marginRight: 8
    },
    kazaBadgeText: {
        color: COLORS.white,
        fontSize: 12,
        fontWeight: 'bold'
    },
    expandIcon: {
        fontSize: 12,
        color: COLORS.textLight
    },
    prayerListContainer: {
        padding: 12,
        backgroundColor: '#FAFAFA'
    },
    prayerItem: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingVertical: 12,
        paddingHorizontal: 8,
        borderBottomWidth: 1,
        borderBottomColor: 'rgba(0,0,0,0.05)'
    },
    prayerInfo: {
        flexDirection: 'row',
        alignItems: 'center',
        flex: 1
    },
    missedIcon: {
        fontSize: 14,
        marginRight: 10
    },
    prayerName: {
        fontSize: 16,
        fontWeight: '500',
        color: COLORS.text
    },
    prayerNotes: {
        fontSize: 12,
        color: COLORS.textLight,
        marginLeft: 8,
        fontStyle: 'italic'
    },
    compensateButton: {
        backgroundColor: COLORS.primary,
        paddingVertical: 8,
        paddingHorizontal: 16,
        borderRadius: 20
    },
    compensateButtonText: {
        color: COLORS.white,
        fontWeight: 'bold',
        fontSize: 13
    },
    empty: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center'
    },
    emptyIcon: {
        fontSize: 60,
        marginBottom: 16
    },
    emptyText: {
        fontSize: 20,
        fontWeight: 'bold',
        color: COLORS.text,
        marginBottom: 8
    },
    emptySubtext: {
        fontSize: 14,
        color: COLORS.textLight,
        textAlign: 'center'
    }
});
