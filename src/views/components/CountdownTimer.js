import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { COLORS } from '../../constants/colors';

const CountdownTimer = ({ targetTime, nextPrayerName }) => {
    const [timeLeft, setTimeLeft] = useState('');

    useEffect(() => {
        if (!targetTime) return;

        const interval = setInterval(() => {
            const now = new Date();
            const [hours, minutes] = targetTime.split(':').map(Number);

            let target = new Date();
            target.setHours(hours, minutes, 0, 0);

            if (target <= now) {
                target.setDate(target.getDate() + 1);
            }

            let diff = target - now;

            if (diff < 0) {
                setTimeLeft('00:00:00');
            } else {
                const h = Math.floor(diff / (1000 * 60 * 60));
                const m = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                const s = Math.floor((diff % (1000 * 60)) / 1000);

                setTimeLeft(
                    `${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`
                );
            }
        }, 1000);

        return () => clearInterval(interval);
    }, [targetTime]);

    return (
        <View style={styles.container}>
            <Text style={styles.label}>SONRAKİ NAMAZ</Text>
            <Text style={styles.name}>{nextPrayerName}</Text>
            <Text style={styles.time}>{targetTime}</Text>
            <View style={styles.timerBox}>
                <Text style={styles.countdown}>{timeLeft}</Text>
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        backgroundColor: COLORS.dark, // Olive
        padding: 25,
        borderRadius: 20,
        alignItems: 'center',
        marginVertical: 20,
        shadowColor: COLORS.dark,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 10,
        elevation: 5
    },
    label: {
        color: COLORS.accent, // Lemon
        fontSize: 14,
        marginBottom: 5,
        letterSpacing: 2,
        fontWeight: '600'
    },
    name: {
        color: COLORS.white,
        fontSize: 32,
        fontWeight: 'bold',
        marginBottom: 0
    },
    time: {
        color: COLORS.white + 'CC', // With opacity
        fontSize: 18,
        marginBottom: 15
    },
    timerBox: {
        backgroundColor: COLORS.white + '20',
        paddingHorizontal: 20,
        paddingVertical: 10,
        borderRadius: 12
    },
    countdown: {
        color: COLORS.accent, // Lemon
        fontSize: 28,
        fontWeight: 'bold',
        fontVariant: ['tabular-nums']
    }
});

export default CountdownTimer;
