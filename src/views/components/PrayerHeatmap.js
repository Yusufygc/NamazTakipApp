import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, Dimensions } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { getHeatmapData } from '../../controllers/PrayerController';
import { useTheme } from '../../context/ThemeContext';

const screenWidth = Dimensions.get('window').width;
const CELL_SIZE = (screenWidth - 80) / 7; // 7 days per row

const MONTHS_TR = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
];

const DAYS_TR = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

// Get color based on performed prayer count (0-5)
const getHeatColor = (count) => {
    if (count === 5) return '#4CAF50'; // Full green - all 5 prayers
    if (count >= 3) return '#FFC107'; // Yellow - 3-4 prayers
    if (count >= 1) return '#FF9800'; // Orange - 1-2 prayers
    return '#F44336'; // Red - 0 prayers
};

// Get emoji based on performance
const getHeatEmoji = (count) => {
    if (count === 5) return '🟩';
    if (count >= 3) return '🟨';
    return '🟥';
};

export default function PrayerHeatmap() {
    const [currentDate, setCurrentDate] = useState(new Date());
    const [heatmapData, setHeatmapData] = useState({});
    const [loading, setLoading] = useState(true);
    const { colors } = useTheme();

    const year = currentDate.getFullYear();
    const month = currentDate.getMonth() + 1; // 1-12

    useFocusEffect(
        useCallback(() => {
            loadHeatmapData();
        }, [year, month])
    );

    const loadHeatmapData = async () => {
        setLoading(true);
        console.log('[Heatmap] Loading data for:', year, month);
        const data = await getHeatmapData(year, month);
        console.log('[Heatmap] Raw data received:', JSON.stringify(data));

        // Convert to map for easy lookup: { "2026-01-15": 5, ... }
        const dataMap = {};
        data.forEach(item => {
            console.log('[Heatmap] Item:', item.date, 'performedCount:', item.performedCount);
            dataMap[item.date] = item.performedCount;
        });

        console.log('[Heatmap] DataMap:', JSON.stringify(dataMap));
        setHeatmapData(dataMap);
        setLoading(false);
    };

    // Navigate to previous month
    const goToPrevMonth = () => {
        setCurrentDate(new Date(year, month - 2, 1));
    };

    // Navigate to next month
    const goToNextMonth = () => {
        const now = new Date();
        const nextMonth = new Date(year, month, 1);
        if (nextMonth <= now) {
            setCurrentDate(nextMonth);
        }
    };

    // Generate calendar grid
    const generateCalendarGrid = () => {
        const firstDay = new Date(year, month - 1, 1);
        const lastDay = new Date(year, month, 0);
        const daysInMonth = lastDay.getDate();

        // Get day of week for first day (0 = Sunday, adjust, Monday = 0)
        let firstDayOfWeek = firstDay.getDay() - 1;
        if (firstDayOfWeek === -1) firstDayOfWeek = 6; // Sunday -> 6

        const weeks = [];
        let currentWeek = [];

        // Add empty cells for days before the first day
        for (let i = 0; i < firstDayOfWeek; i++) {
            currentWeek.push(null);
        }

        // Add all days of the month
        for (let day = 1; day <= daysInMonth; day++) {
            // Database uses DD-MM-YYYY format
            const dateStr = `${String(day).padStart(2, '0')}-${String(month).padStart(2, '0')}-${year}`;
            const count = heatmapData[dateStr] ?? -1; // -1 means no data

            currentWeek.push({ day, date: dateStr, count });

            if (currentWeek.length === 7) {
                weeks.push(currentWeek);
                currentWeek = [];
            }
        }

        // Fill remaining days of last week
        if (currentWeek.length > 0) {
            while (currentWeek.length < 7) {
                currentWeek.push(null);
            }
            weeks.push(currentWeek);
        }

        return weeks;
    };

    const weeks = generateCalendarGrid();
    const isCurrentMonth = year === new Date().getFullYear() && month === new Date().getMonth() + 1;
    const styles = getStyles(colors);

    return (
        <View style={styles.container}>
            {/* Header with month navigation */}
            <View style={styles.header}>
                <TouchableOpacity onPress={goToPrevMonth} style={styles.navButton}>
                    <Text style={styles.navButtonText}>◀</Text>
                </TouchableOpacity>

                <Text style={styles.title}>
                    {MONTHS_TR[month - 1]} {year}
                </Text>

                <TouchableOpacity
                    onPress={goToNextMonth}
                    style={[styles.navButton, isCurrentMonth && styles.navButtonDisabled]}
                    disabled={isCurrentMonth}
                >
                    <Text style={[styles.navButtonText, isCurrentMonth && styles.navButtonTextDisabled]}>▶</Text>
                </TouchableOpacity>
            </View>

            {/* Day labels */}
            <View style={styles.dayLabels}>
                {DAYS_TR.map((day, index) => (
                    <View key={index} style={styles.dayLabelCell}>
                        <Text style={styles.dayLabelText}>{day}</Text>
                    </View>
                ))}
            </View>

            {/* Calendar grid */}
            <View style={styles.calendarGrid}>
                {weeks.map((week, weekIndex) => (
                    <View key={weekIndex} style={styles.weekRow}>
                        {week.map((dayData, dayIndex) => (
                            <View key={dayIndex} style={styles.dayCell}>
                                {dayData ? (
                                    <View
                                        style={[
                                            styles.dayCellInner,
                                            dayData.count >= 0 && { backgroundColor: getHeatColor(dayData.count) },
                                            dayData.count === -1 && styles.noDataCell
                                        ]}
                                    >
                                        <Text style={[
                                            styles.dayNumber,
                                            dayData.count >= 0 && styles.dayNumberWithData
                                        ]}>
                                            {dayData.day}
                                        </Text>
                                        {dayData.count >= 0 && (
                                            <Text style={styles.countText}>{dayData.count}/5</Text>
                                        )}
                                    </View>
                                ) : (
                                    <View style={styles.emptyCell} />
                                )}
                            </View>
                        ))}
                    </View>
                ))}
            </View>

            {/* Legend */}
            <View style={styles.legend}>
                <View style={styles.legendItem}>
                    <View style={[styles.legendColor, { backgroundColor: '#4CAF50' }]} />
                    <Text style={styles.legendText}>5/5</Text>
                </View>
                <View style={styles.legendItem}>
                    <View style={[styles.legendColor, { backgroundColor: '#FFC107' }]} />
                    <Text style={styles.legendText}>3-4</Text>
                </View>
                <View style={styles.legendItem}>
                    <View style={[styles.legendColor, { backgroundColor: '#FF9800' }]} />
                    <Text style={styles.legendText}>1-2</Text>
                </View>
                <View style={styles.legendItem}>
                    <View style={[styles.legendColor, { backgroundColor: '#F44336' }]} />
                    <Text style={styles.legendText}>0</Text>
                </View>
            </View>

            {loading && (
                <Text style={styles.loadingText}>Yükleniyor...</Text>
            )}
        </View>
    );
}

const getStyles = (colors) => StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: colors.background,
        padding: 16,
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 20,
    },
    title: {
        fontSize: 20,
        fontWeight: 'bold',
        color: colors.primary,
    },
    navButton: {
        padding: 12,
        backgroundColor: colors.primary,
        borderRadius: 8,
    },
    navButtonDisabled: {
        backgroundColor: colors.textLight,
        opacity: 0.5,
    },
    navButtonText: {
        color: colors.white,
        fontSize: 16,
        fontWeight: 'bold',
    },
    navButtonTextDisabled: {
        color: colors.background,
    },
    dayLabels: {
        flexDirection: 'row',
        marginBottom: 8,
    },
    dayLabelCell: {
        width: CELL_SIZE,
        alignItems: 'center',
    },
    dayLabelText: {
        fontSize: 12,
        fontWeight: '600',
        color: colors.textLight,
    },
    calendarGrid: {
        backgroundColor: colors.white,
        borderRadius: 12,
        padding: 8,
        elevation: 2,
        shadowColor: colors.dark,
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
    },
    weekRow: {
        flexDirection: 'row',
    },
    dayCell: {
        width: CELL_SIZE,
        height: CELL_SIZE,
        padding: 2,
    },
    dayCellInner: {
        flex: 1,
        borderRadius: 8,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: colors.background,
    },
    noDataCell: {
        backgroundColor: '#E0E0E0',
    },
    emptyCell: {
        flex: 1,
    },
    dayNumber: {
        fontSize: 12,
        fontWeight: '600',
        color: colors.text,
    },
    dayNumberWithData: {
        color: colors.white,
    },
    countText: {
        fontSize: 8,
        color: 'rgba(255,255,255,0.9)',
        fontWeight: '500',
    },
    legend: {
        flexDirection: 'row',
        justifyContent: 'center',
        marginTop: 16,
        gap: 16,
    },
    legendItem: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 4,
    },
    legendColor: {
        width: 16,
        height: 16,
        borderRadius: 4,
    },
    legendText: {
        fontSize: 12,
        color: colors.textLight,
    },
    loadingText: {
        textAlign: 'center',
        color: colors.textLight,
        marginTop: 16,
    },
});
