import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { LineChart } from 'react-native-chart-kit';
import { getMonthlyStats } from '../../controllers/PrayerController';
import { COLORS } from '../../constants/colors';

const screenWidth = Dimensions.get('window').width;

export default function MonthlyStats() {
    const [data, setData] = useState(null);

    useFocusEffect(
        useCallback(() => {
            const load = async () => {
                const stats = await getMonthlyStats();
                if (stats.length > 0) {
                    // Show every 5th label to avoid crowding
                    const labels = stats.map((s, i) => i % 5 === 0 ? s.date.slice(0, 5) : '');
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
            <Text style={styles.title}>Aylık Performans</Text>
            {data ? (
                <LineChart
                    data={data}
                    width={screenWidth - 20}
                    height={220}
                    yAxisLabel=""
                    yAxisSuffix=""
                    chartConfig={{
                        backgroundColor: COLORS.white,
                        backgroundGradientFrom: COLORS.white,
                        backgroundGradientTo: COLORS.white,
                        decimalPlaces: 0,
                        color: (opacity = 1) => COLORS.secondary, // Lime
                        labelColor: (opacity = 1) => COLORS.textLight,
                        propsForDots: {
                            r: "3",
                            strokeWidth: "2",
                            stroke: COLORS.secondary
                        }
                    }}
                    bezier
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
        color: COLORS.secondary
    },
    chart: {
        marginVertical: 8,
        borderRadius: 16
    }
});
