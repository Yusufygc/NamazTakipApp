import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { LineChart } from 'react-native-chart-kit';
import { getMonthlyStats } from '../../controllers/PrayerController';

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
                        backgroundColor: '#ffffff',
                        backgroundGradientFrom: '#ffffff',
                        backgroundGradientTo: '#ffffff',
                        decimalPlaces: 0,
                        color: (opacity = 1) => `rgba(76, 175, 80, ${opacity})`,
                        labelColor: (opacity = 1) => `rgba(0, 0, 0, ${opacity})`,
                        propsForDots: {
                            r: "3",
                            strokeWidth: "2",
                            stroke: "#4caf50"
                        }
                    }}
                    bezier
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
