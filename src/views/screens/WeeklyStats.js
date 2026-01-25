import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { BarChart } from 'react-native-chart-kit';
import { getWeeklyStats } from '../../controllers/PrayerController';
import { COLORS } from '../../constants/colors';

const screenWidth = Dimensions.get('window').width;

export default function WeeklyStats() {
    const [data, setData] = useState(null);

    useFocusEffect(
        useCallback(() => {
            const load = async () => {
                const stats = await getWeeklyStats();
                // stats: [{date, count}, ...]
                // Format for ChartKit
                if (stats.length > 0) {
                    const labels = stats.map(s => s.date.slice(0, 5)); // DD-MM
                    const values = stats.map(s => s.count);

                    setData({
                        labels,
                        datasets: [{ data: values }]
                    });
                }
            };
            load();
        }, [])
    );

    return (
        <View style={styles.container}>
            <Text style={styles.title}>Haftalık Performans</Text>
            {data ? (
                <BarChart
                    data={data}
                    width={screenWidth - 40}
                    height={220}
                    yAxisLabel=""
                    yAxisSuffix=" vakit"
                    chartConfig={{
                        backgroundColor: COLORS.white,
                        backgroundGradientFrom: COLORS.white,
                        backgroundGradientTo: COLORS.white,
                        decimalPlaces: 0,
                        color: (opacity = 1) => COLORS.primary, // Sage
                        labelColor: (opacity = 1) => COLORS.textLight,
                    }}
                    style={styles.chart}
                />
            ) : (
                <Text style={{ color: COLORS.textLight }}>Veri yükleniyor...</Text>
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
        alignItems: 'center',
        padding: 20
    },
    title: {
        fontSize: 20,
        fontWeight: 'bold',
        marginBottom: 20,
        color: COLORS.primary
    },
    chart: {
        marginVertical: 8,
        borderRadius: 16
    }
});
