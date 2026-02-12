import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useTheme } from '../../context/ThemeContext';

const PrayerCard = ({ name, time, isPerformed, isMissed, isNext, isDisplayOnly, onPress }) => {
    const { colors } = useTheme();
    const styles = getStyles(colors);

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

const getStyles = (colors) => StyleSheet.create({
    container: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        padding: 20,
        marginVertical: 8,
        backgroundColor: colors.white,
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
        backgroundColor: colors.white,
        borderLeftWidth: 5,
        borderLeftColor: '#FFCC00', // Sun color
        opacity: 0.9,
        paddingVertical: 15 // Slightly smaller padding for non-interactive
    },
    // ... other styles
    nextContainer: {
        backgroundColor: colors.primary, // Sage
        borderLeftWidth: 5,
        borderLeftColor: colors.dark
    },
    performedContainer: {
        backgroundColor: colors.secondary + '40', // Lime with opacity
        borderColor: colors.secondary,
        borderWidth: 1
    },
    missedContainer: {
        backgroundColor: colors.danger + '25', // Red with opacity
        borderColor: colors.danger,
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
        color: colors.text
    },
    time: {
        fontSize: 18,
        fontWeight: 'bold',
        color: colors.text
    },
    nextText: {
        color: colors.white
    },
    missedText: {
        color: colors.danger
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
        borderColor: colors.textLight,
        alignItems: 'center',
        justifyContent: 'center'
    },
    checkedCircle: {
        width: 30,
        height: 30,
        borderRadius: 15,
        backgroundColor: colors.secondary,
        alignItems: 'center',
        justifyContent: 'center'
    },
    missedCircle: {
        width: 30,
        height: 30,
        borderRadius: 15,
        backgroundColor: colors.danger,
        alignItems: 'center',
        justifyContent: 'center'
    },
    nextCircle: {
        borderColor: colors.white,
        backgroundColor: colors.white + '30'
    },
    checkmark: {
        color: colors.dark,
        fontSize: 16,
        fontWeight: 'bold'
    },
    missedMark: {
        color: colors.white,
        fontSize: 16,
        fontWeight: 'bold'
    },
    nextIcon: {
        fontSize: 14
    }
});

export default PrayerCard;
