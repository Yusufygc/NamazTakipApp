import React, { useState, useCallback, useMemo } from 'react';
import { View, Text, StyleSheet, ScrollView, Dimensions, TouchableOpacity } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { BarChart, LineChart } from 'react-native-chart-kit';
import { getComparisonStats, getWeeklyStats, getMonthlyStats } from '../../controllers/PrayerController';
import { useTheme } from '../../context/ThemeContext';
import { MaterialCommunityIcons } from '@expo/vector-icons';

const screenWidth = Dimensions.get('window').width;

export default function ComparisonStats() {
    const [stats, setStats] = useState({ currentWeek: 0, prevWeek: 0 });
    const [weeklyData, setWeeklyData] = useState(null);
    const [monthlyData, setMonthlyData] = useState(null);
    const [viewMode, setViewMode] = useState('weekly'); // 'weekly' or 'monthly'
    const { colors } = useTheme();

    useFocusEffect(
        useCallback(() => {
            const load = async () => {
                // Load comparison stats
                const compResult = await getComparisonStats();
                setStats(compResult);

                // Load weekly stats
                const wStats = await getWeeklyStats();
                if (wStats.length > 0) {
                    setWeeklyData({
                        labels: wStats.map(s => s.date.slice(0, 5)),
                        datasets: [{ data: wStats.map(s => s.count) }]
                    });
                }

                // Load monthly stats
                const mStats = await getMonthlyStats();
                if (mStats.length > 0) {
                    setMonthlyData({
                        labels: mStats.map((s, i) => i % 5 === 0 ? s.date.slice(0, 5) : ''),
                        datasets: [{ data: mStats.map(s => s.count) }]
                    });
                }
            };
            load();
        }, [])
    );

    const diff = stats.currentWeek - stats.prevWeek;
    const isBetter = diff >= 0;

    const chartConfig = {
        backgroundColor: colors.white,
        backgroundGradientFrom: colors.white,
        backgroundGradientTo: colors.white,
        decimalPlaces: 0,
        color: (opacity = 1) => colors.primary,
        labelColor: (opacity = 1) => colors.textLight,
        propsForDots: {
            r: "4",
            strokeWidth: "2",
            stroke: colors.secondary
        },
        barPercentage: 0.7,
    };

    const renderChart = () => {
        if (viewMode === 'weekly' && weeklyData) {
            return (
                <BarChart
                    data={weeklyData}
                    width={screenWidth - 40}
                    height={220}
                    yAxisLabel=""
                    yAxisSuffix=""
                    chartConfig={chartConfig}
                    style={styles.chart}
                    showValuesOnTopOfBars
                />
            );
        } else if (viewMode === 'monthly' && monthlyData) {
            return (
                <LineChart
                    data={monthlyData}
                    width={screenWidth - 40}
                    height={220}
                    yAxisLabel=""
                    yAxisSuffix=""
                    chartConfig={chartConfig}
                    bezier
                    style={styles.chart}
                />
            );
        }
        return <Text style={styles.noDataText}>Veri bulunamadı.</Text>;
    };

    const styles = useMemo(() => getStyles(colors), [colors]);

    return (
        <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
            <Text style={styles.title}>İstatistikler & Karşılaştırma</Text>

            {/* Comparison Cards */}
            <View style={styles.statsRow}>
                <View style={styles.statCard}>
                    <Text style={styles.statLabel}>Bu Hafta</Text>
                    <Text style={styles.statValue}>{stats.currentWeek}</Text>
                    <MaterialCommunityIcons name="calendar-week" size={24} color={colors.primary} style={styles.icon} />
                </View>
                <View style={styles.statCard}>
                    <Text style={styles.statLabel}>Geçen Hafta</Text>
                    <Text style={styles.statValue}>{stats.prevWeek}</Text>
                    <MaterialCommunityIcons name="calendar-clock" size={24} color={colors.textLight} style={styles.icon} />
                </View>
            </View>

            {/* Difference Card */}
            <View style={[styles.diffCard, isBetter ? styles.betterParams : styles.worseParams]}>
                <View>
                    <Text style={styles.diffLabel}>Gelişim Durumu</Text>
                    <Text style={styles.diffValue}>
                        {diff > 0 ? '+' : ''}{diff} Vakit
                    </Text>
                </View>
                <View style={styles.diffIconContainer}>
                    <MaterialCommunityIcons
                        name={isBetter ? "trending-up" : "trending-down"}
                        size={32}
                        color={isBetter ? colors.secondary : '#ef5350'}
                    />
                    <Text style={[styles.diffText, { color: isBetter ? colors.secondary : '#ef5350' }]}>
                        {isBetter ? 'Yükselişte' : 'Düşüşte'}
                    </Text>
                </View>
            </View>

            {/* Toggle View */}
            <View style={styles.toggleContainer}>
                <TouchableOpacity
                    style={[styles.toggleButton, viewMode === 'weekly' && styles.activeToggle]}
                    onPress={() => setViewMode('weekly')}
                >
                    <Text style={[styles.toggleText, viewMode === 'weekly' && styles.activeToggleText]}>Haftalık</Text>
                </TouchableOpacity>
                <TouchableOpacity
                    style={[styles.toggleButton, viewMode === 'monthly' && styles.activeToggle]}
                    onPress={() => setViewMode('monthly')}
                >
                    <Text style={[styles.toggleText, viewMode === 'monthly' && styles.activeToggleText]}>Aylık</Text>
                </TouchableOpacity>
            </View>

            {/* Charts */}
            <View style={styles.chartContainer}>
                <Text style={styles.chartTitle}>
                    {viewMode === 'weekly' ? 'Haftalık Namaz Grafiği' : 'Aylık Performans Grafiği'}
                </Text>
                {renderChart()}
            </View>
        </ScrollView>
    );
}

const getStyles = (colors) => StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: colors.background,
    },
    contentContainer: {
        padding: 20,
        paddingBottom: 40,
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 20,
        color: colors.primary,
        textAlign: 'center',
    },
    statsRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        marginBottom: 15,
    },
    statCard: {
        flex: 1,
        backgroundColor: colors.white,
        padding: 15,
        borderRadius: 15,
        marginHorizontal: 5,
        alignItems: 'center',
        elevation: 3,
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 3.84,
    },
    statLabel: {
        fontSize: 14,
        color: colors.textLight,
        marginBottom: 5,
    },
    statValue: {
        fontSize: 28,
        fontWeight: 'bold',
        color: colors.primary,
    },
    icon: {
        marginTop: 10,
        opacity: 0.8,
    },
    diffCard: {
        backgroundColor: colors.white,
        padding: 20,
        borderRadius: 15,
        marginBottom: 25,
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        elevation: 3,
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 3.84,
        borderLeftWidth: 5,
    },
    betterParams: {
        borderLeftColor: colors.secondary,
    },
    worseParams: {
        borderLeftColor: '#ef5350',
    },
    diffLabel: {
        fontSize: 16,
        color: colors.textLight,
    },
    diffValue: {
        fontSize: 32,
        fontWeight: 'bold',
        color: colors.text,
    },
    diffIconContainer: {
        alignItems: 'center',
    },
    diffText: {
        marginTop: 5,
        fontWeight: '600',
    },
    toggleContainer: {
        flexDirection: 'row',
        backgroundColor: colors.white,
        borderRadius: 12,
        padding: 4,
        marginBottom: 20,
        borderWidth: 1,
        borderColor: colors.dark + '20',
    },
    toggleButton: {
        flex: 1,
        paddingVertical: 10,
        alignItems: 'center',
        borderRadius: 8,
    },
    activeToggle: {
        backgroundColor: colors.primary,
    },
    toggleText: {
        fontSize: 16,
        fontWeight: '600',
        color: colors.textLight,
    },
    activeToggleText: {
        color: colors.white,
    },
    chartContainer: {
        backgroundColor: colors.white,
        borderRadius: 20,
        padding: 15,
        alignItems: 'center',
        elevation: 2,
    },
    chartTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: colors.text,
        marginBottom: 15,
        alignSelf: 'flex-start',
        marginLeft: 10,
    },
    chart: {
        borderRadius: 16,
        marginVertical: 8,
    },
    noDataText: {
        textAlign: 'center',
        color: colors.textLight,
        marginVertical: 20,
    }
});
