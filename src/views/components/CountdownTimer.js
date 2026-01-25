import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet } from 'react-native';

const CountdownTimer = ({ targetTime, nextPrayerName }) => {
    const [timeLeft, setTimeLeft] = useState('');

    useEffect(() => {
        if (!targetTime) return;

        const interval = setInterval(() => {
            const now = new Date();
            const [hours, minutes] = targetTime.split(':').map(Number);

            let target = new Date();
            target.setHours(hours, minutes, 0, 0);

            // If target time (e.g. 05:47) is less than now (e.g. 22:00), 
            // it means the target matches tomorrow's time (assuming we are counting down to it).
            // However, we rely on the parent ensuring 'targetTime' is truly the NEXT prayer.
            // If we blindly add 1 day when target < now, it works for the "next prayer is tomorrow" case.
            if (target <= now) {
                target.setDate(target.getDate() + 1);
            }

            let diff = target - now;

            if (diff < 0) {
                // Should have been caught by target <= now logic ideally, but just in case
                // loop or just 00:00:00
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
            <Text style={styles.countdown}>⏰ {timeLeft}</Text>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        backgroundColor: '#263238',
        padding: 20,
        borderRadius: 15,
        alignItems: 'center',
        marginVertical: 20
    },
    label: {
        color: '#cfd8dc',
        fontSize: 14,
        marginBottom: 5
    },
    name: {
        color: '#fff',
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 5
    },
    time: {
        color: '#fff',
        fontSize: 18,
        marginBottom: 10
    },
    countdown: {
        color: '#ffeb3b',
        fontSize: 22,
        fontWeight: 'bold'
    }
});

export default CountdownTimer;
