import React, { useState, useEffect, useRef } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { COLORS } from '../../constants/colors';

const CountdownTimer = ({ targetTime, nextPrayerName, onPrayerTimeReached }) => {
    const [timeLeft, setTimeLeft] = useState('');
    const hasTriggeredRef = useRef(false);

    useEffect(() => {
        // Reset trigger flag when targetTime changes
        hasTriggeredRef.current = false;
    }, [targetTime]);

    useEffect(() => {
        if (!targetTime) return;

        const interval = setInterval(() => {
            const now = new Date();
            const [hours, minutes] = targetTime.split(':').map(Number);

            let target = new Date();
            target.setHours(hours, minutes, 0, 0);

            // Check if target time has passed (within the same minute window)
            const nowTime = now.getHours() * 60 + now.getMinutes();
            const targetTimeMinutes = hours * 60 + minutes;

            // If target time just passed and we haven't triggered yet
            if (nowTime >= targetTimeMinutes && !hasTriggeredRef.current) {
                hasTriggeredRef.current = true;
                // Call callback after a short delay to allow the current prayer time to settle
                if (onPrayerTimeReached) {
                    setTimeout(() => {
                        onPrayerTimeReached();
                    }, 2000); // 2 second delay to ensure smooth transition
                }
            }

            // Calculate time difference for display
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
    }, [targetTime, onPrayerTimeReached]);

    return (
        <View style={styles.container}>
            <Text style={styles.label}>SONRAKİ NAMAZ</Text>
            <Text style={styles.name}>{nextPrayerName}</Text>
            <Text style={styles.time}>{targetTime}</Text>

            <View style={styles.timerContainer}>
                <Text style={styles.remainingLabel}>Kalan Süre</Text>
                <View style={styles.timerBox}>
                    <Text style={styles.countdown}>{timeLeft}</Text>
                </View>
            </View>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        backgroundColor: COLORS.dark, // Olive
        padding: 20, // Reduced padding
        borderRadius: 20,
        alignItems: 'center',
        marginVertical: 15, // Reduced margin
        shadowColor: COLORS.dark,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 10,
        elevation: 5
    },
    label: {
        color: COLORS.accent, // Lemon
        fontSize: 12, // Reduced font size
        marginBottom: 5,
        letterSpacing: 2,
        fontWeight: '600'
    },
    name: {
        color: COLORS.white,
        fontSize: 28, // Slightly reduced
        fontWeight: 'bold',
        marginBottom: 0
    },
    time: {
        color: COLORS.white + 'CC', // With opacity
        fontSize: 16,
        marginBottom: 10 // Reduced margin
    },
    timerContainer: {
        alignItems: 'center',
        marginTop: 5
    },
    remainingLabel: {
        color: COLORS.white + '90',
        fontSize: 12,
        marginBottom: 5,
        textTransform: 'uppercase',
        letterSpacing: 1
    },
    timerBox: {
        backgroundColor: COLORS.white + '20',
        paddingHorizontal: 20,
        paddingVertical: 8, // Reduced padding
        borderRadius: 12
    },
    countdown: {
        color: COLORS.white, // Lemon
        fontSize: 24, // Slightly reduced
        fontWeight: 'bold',
        fontVariant: ['tabular-nums']
    }
});

export default CountdownTimer;

