import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

const PrayerCard = ({ name, time, isPerformed, isNext, onPress }) => {
    return (
        <TouchableOpacity
            style={[
                styles.container,
                isNext && styles.nextContainer,
                isPerformed && styles.performedContainer
            ]}
            onPress={onPress}
        >
            <View style={styles.info}>
                <Text style={[styles.name, isNext && styles.nextText]}>{name}</Text>
                <Text style={[styles.time, isNext && styles.nextText]}>{time}</Text>
            </View>
            <View style={styles.status}>
                {isPerformed ? (
                    <Text style={styles.checked}>✅</Text>
                ) : (
                    <Text style={styles.unchecked}>{isNext ? '⏱️' : '⚪'}</Text>
                )}
            </View>
        </TouchableOpacity>
    );
};

const styles = StyleSheet.create({
    container: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        padding: 15,
        marginVertical: 5,
        backgroundColor: '#f0f0f0',
        borderRadius: 10,
        alignItems: 'center'
    },
    nextContainer: {
        backgroundColor: '#e3f2fd',
        borderWidth: 1,
        borderColor: '#2196f3'
    },
    performedContainer: {
        backgroundColor: '#e8f5e9'
    },
    info: {
        flexDirection: 'row',
        width: '60%',
        justifyContent: 'space-between'
    },
    name: {
        fontSize: 18,
        fontWeight: '500'
    },
    time: {
        fontSize: 18,
        fontWeight: 'bold'
    },
    nextText: {
        color: '#1565c0'
    },
    status: {
        width: 30,
        alignItems: 'center'
    },
    checked: {
        fontSize: 20
    },
    unchecked: {
        fontSize: 20
    }
});

export default PrayerCard;
