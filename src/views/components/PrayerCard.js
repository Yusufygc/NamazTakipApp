import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { COLORS } from '../../constants/colors';

const PrayerCard = ({ name, time, isPerformed, isMissed, isNext, isDisplayOnly, onPress }) => {
    return (
        <TouchableOpacity
            style={[
                styles.container,
                isNext && styles.nextContainer,
                isPerformed && styles.performedContainer,
                isMissed && styles.missedContainer,
                isDisplayOnly && styles.displayOnlyContainer
            ]}
            onPress={isDisplayOnly ? null : onPress}
            activeOpacity={isDisplayOnly ? 1 : 0.7}
        >
            <View style={styles.info}>
                <Text style={[styles.name, isNext && styles.nextText, isMissed && styles.missedText]}>{name}</Text>
                <Text style={[styles.time, isNext && styles.nextText, isMissed && styles.missedText]}>{time}</Text>
            </View>
            <View style={styles.status}>
                {isDisplayOnly ? (
                    // No checkbox for display only (e.g., Sun)
                    <Text style={styles.sunIcon}>☀️</Text>
                ) : isPerformed ? (
                    <View style={styles.checkedCircle}>
                        <Text style={styles.checkmark}>✓</Text>
                    </View>
                ) : isMissed ? (
                    <View style={styles.missedCircle}>
                        <Text style={styles.missedMark}>✕</Text>
                    </View>
                ) : (
                    <View style={[styles.circle, isNext && styles.nextCircle]}>
                        {isNext && <Text style={styles.nextIcon}>⏳</Text>}
                    </View>
                )}
            </View>
        </TouchableOpacity>
    );
};

const styles = StyleSheet.create({
    container: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        padding: 20,
        marginVertical: 8,
        backgroundColor: COLORS.white,
        borderRadius: 16,
        alignItems: 'center',
        shadowColor: "#000",
        shadowOffset: {
            width: 0,
            height: 2,
        },
        shadowOpacity: 0.05,
        shadowRadius: 3.84,
        elevation: 2,
    },
    displayOnlyContainer: {
        backgroundColor: COLORS.white,
        borderLeftWidth: 5,
        borderLeftColor: '#FFCC00', // Sun color
        opacity: 0.9,
        paddingVertical: 15 // Slightly smaller padding for non-interactive
    },
    // ... other styles
    nextContainer: {
        backgroundColor: COLORS.primary, // Sage
        borderLeftWidth: 5,
        borderLeftColor: COLORS.dark
    },
    performedContainer: {
        backgroundColor: COLORS.secondary + '40', // Lime with opacity
        borderColor: COLORS.secondary,
        borderWidth: 1
    },
    missedContainer: {
        backgroundColor: COLORS.danger + '25', // Red with opacity
        borderColor: COLORS.danger,
        borderWidth: 1
    },
    info: {
        flexDirection: 'row',
        width: '65%',
        justifyContent: 'space-between',
        alignItems: 'center'
    },
    name: {
        fontSize: 18,
        fontWeight: '600',
        color: COLORS.text
    },
    time: {
        fontSize: 18,
        fontWeight: 'bold',
        color: COLORS.text
    },
    nextText: {
        color: COLORS.white
    },
    missedText: {
        color: COLORS.danger
    },
    status: {
        width: 40,
        alignItems: 'center',
        justifyContent: 'center'
    },
    sunIcon: {
        fontSize: 24,
    },
    circle: {
        width: 30,
        height: 30,
        borderRadius: 15,
        borderWidth: 2,
        borderColor: COLORS.textLight,
        alignItems: 'center',
        justifyContent: 'center'
    },
    checkedCircle: {
        width: 30,
        height: 30,
        borderRadius: 15,
        backgroundColor: COLORS.secondary,
        alignItems: 'center',
        justifyContent: 'center'
    },
    missedCircle: {
        width: 30,
        height: 30,
        borderRadius: 15,
        backgroundColor: COLORS.danger,
        alignItems: 'center',
        justifyContent: 'center'
    },
    nextCircle: {
        borderColor: COLORS.white,
        backgroundColor: COLORS.white + '30'
    },
    checkmark: {
        color: COLORS.dark,
        fontSize: 16,
        fontWeight: 'bold'
    },
    missedMark: {
        color: COLORS.white,
        fontSize: 16,
        fontWeight: 'bold'
    },
    nextIcon: {
        fontSize: 14
    }
});

export default PrayerCard;

