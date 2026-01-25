import React, { useState, useCallback } from 'react';
import { View, Text, Switch, StyleSheet } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { runQuery, runRun } from '../../services/database/DatabaseService';
import { COLORS } from '../../constants/colors';

export default function SettingsScreen() {
    const [notificationsEnabled, setNotificationsEnabled] = useState(true);
    const [calculationMethod, setCalculationMethod] = useState('13');

    const loadSettings = async () => {
        try {
            const result = await runQuery('SELECT * FROM app_settings');
            // Convert array to object
            const settings = {};
            result.forEach(row => {
                settings[row.setting_key] = row.setting_value;
            });

            setNotificationsEnabled(settings.notification_enabled === '1');
            setCalculationMethod(settings.calculation_method || '13');
        } catch (e) {
            console.error(e);
        }
    };

    useFocusEffect(
        useCallback(() => {
            loadSettings();
        }, [])
    );

    const toggleSwitch = async (value) => {
        setNotificationsEnabled(value);
        await runRun(
            `UPDATE app_settings SET setting_value = ? WHERE setting_key = 'notification_enabled'`,
            [value ? '1' : '0']
        );
    };

    return (
        <View style={styles.container}>
            <Text style={styles.header}>Uygulama Ayarları</Text>

            <View style={styles.row}>
                <Text style={styles.label}>Bildirimler</Text>
                <Switch
                    trackColor={{ false: "#767577", true: COLORS.primary }}
                    thumbColor={notificationsEnabled ? COLORS.accent : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={toggleSwitch}
                    value={notificationsEnabled}
                />
            </View>

            <View style={styles.row}>
                <Text style={styles.label}>Hesaplama Yöntemi</Text>
                <Text style={styles.value}>{calculationMethod === '13' ? 'Diyanet (TR)' : 'Diğer'}</Text>
            </View>

            <View style={styles.info}>
                <Text style={styles.infoText}>Versiyon: 1.0.0</Text>
                <Text style={styles.infoText}>Geliştirici: AI Antigravity</Text>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background, // Off-white
        padding: 20
    },
    header: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 30,
        color: COLORS.primary // Sage
    },
    row: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingVertical: 15,
        borderBottomWidth: 1,
        borderBottomColor: COLORS.dark + '20' // Olive with low opacity
    },
    label: {
        fontSize: 18,
        color: COLORS.text
    },
    value: {
        fontSize: 16,
        color: COLORS.textLight
    },
    info: {
        marginTop: 50,
        alignItems: 'center'
    },
    infoText: {
        color: COLORS.textLight,
        marginBottom: 5
    }
});
