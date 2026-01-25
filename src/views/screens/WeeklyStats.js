import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { BarChart } from 'react-native-chart-kit';
import { getWeeklyStats } from '../../controllers/PrayerController';

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
                        backgroundColor: '#fff',
                        backgroundGradientFrom: '#fff',
                        backgroundGradientTo: '#fff',
                        decimalPlaces: 0,
                        color: (opacity = 1) => `rgba(33, 150, 243, ${opacity})`,
                        labelColor: (opacity = 1) => `rgba(0, 0, 0, ${opacity})`,
                    }}
                    style={styles.chart}
                />
            ) : (
                <Text>Veri yükleniyor...</Text>
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#fff',
        alignItems: 'center',
        padding: 20
    },
    title: {
        fontSize: 20,
        fontWeight: 'bold',
        marginBottom: 20
    },
    chart: {
        marginVertical: 8,
        borderRadius: 16
    }
});
