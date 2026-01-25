import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { getComparisonStats } from '../../controllers/PrayerController';

export default function ComparisonStats() {
    const [stats, setStats] = useState({ currentWeek: 0, prevWeek: 0 });

    useFocusEffect(
        useCallback(() => {
            const load = async () => {
                const result = await getComparisonStats();
                setStats(result);
            };
            load();
        }, [])
    );

    const diff = stats.currentWeek - stats.prevWeek;
    const isBetter = diff >= 0;

    return (
        <View style={styles.container}>
            <Text style={styles.title}>Haftalık Karşılaştırma</Text>

            <View style={styles.card}>
                <Text style={styles.label}>Bu Hafta</Text>
                <Text style={styles.value}>{stats.currentWeek}</Text>
            </View>

            <View style={styles.card}>
                <Text style={styles.label}>Geçen Hafta</Text>
                <Text style={styles.value}>{stats.prevWeek}</Text>
            </View>

            <View style={[styles.card, isBetter ? styles.better : styles.worse]}>
                <Text style={styles.label}>Fark</Text>
                <Text style={styles.diffValue}>
                    {diff > 0 ? '+' : ''}{diff} ({isBetter ? 'Daha İyi 🚀' : 'Düşüşte 📉'})
                </Text>
            </View>
        </View>
    );
}

import { COLORS } from '../../constants/colors';

// ... (logic)

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
        padding: 20,
        alignItems: 'center'
    },
    title: {
        fontSize: 22,
        fontWeight: 'bold',
        marginBottom: 30,
        color: COLORS.primary
    },
    card: {
        width: '100%',
        backgroundColor: COLORS.white,
        padding: 20,
        borderRadius: 15,
        marginBottom: 15,
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        shadowColor: COLORS.dark,
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 2
    },
    label: {
        fontSize: 18,
        color: COLORS.text
    },
    value: {
        fontSize: 24,
        fontWeight: 'bold',
        color: COLORS.primary
    },
    better: {
        backgroundColor: COLORS.secondary + '20', // Light Lime
        borderWidth: 1,
        borderColor: COLORS.secondary
    },
    worse: {
        backgroundColor: '#ffebee', // Keep red indication? Or use accent?
        // Let's keep red for worse performance to be clear
        borderWidth: 1,
        borderColor: '#ef5350'
    },
    diffValue: {
        fontSize: 20,
        fontWeight: 'bold',
        color: COLORS.text
    }
});
