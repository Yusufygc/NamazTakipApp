import React, { useState, useCallback } from 'react';
import { View, Text, Switch, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { runQuery, runRun } from '../../services/database/DatabaseService';
import { useTheme } from '../../context/ThemeContext';
import { THEME_KEYS } from '../../constants/themes';

export default function SettingsScreen() {
    const [notificationsEnabled, setNotificationsEnabled] = useState(true);
    const [calculationMethod, setCalculationMethod] = useState('13');
    const { colors, themeName, setTheme, themes } = useTheme();

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

    const styles = getStyles(colors);

    return (
        <ScrollView style={styles.container}>
            <Text style={styles.header}>Uygulama Ayarları</Text>

            <View style={styles.row}>
                <Text style={styles.label}>Bildirimler</Text>
                <Switch
                    trackColor={{ false: "#767577", true: colors.primary }}
                    thumbColor={notificationsEnabled ? colors.accent : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={toggleSwitch}
                    value={notificationsEnabled}
                />
            </View>

            <View style={styles.row}>
                <Text style={styles.label}>Hesaplama Yöntemi</Text>
                <Text style={styles.value}>{calculationMethod === '13' ? 'Diyanet (TR)' : 'Diğer'}</Text>
            </View>

            {/* Tema Seçimi */}
            <Text style={styles.sectionTitle}>Tema Seçimi</Text>
            <View style={styles.themeGrid}>
                {THEME_KEYS.map((key) => {
                    const theme = themes[key];
                    const isSelected = themeName === key;
                    return (
                        <TouchableOpacity
                            key={key}
                            style={[
                                styles.themeCard,
                                { borderColor: isSelected ? theme.colors.primary : colors.dark + '20' },
                                isSelected && styles.themeCardSelected,
                            ]}
                            onPress={() => setTheme(key)}
                            activeOpacity={0.7}
                        >
                            {/* Renk Önizleme */}
                            <View style={styles.colorPreview}>
                                <View style={[styles.colorDot, { backgroundColor: theme.colors.primary }]} />
                                <View style={[styles.colorDot, { backgroundColor: theme.colors.secondary }]} />
                                <View style={[styles.colorDot, { backgroundColor: theme.colors.accent }]} />
                                <View style={[styles.colorDot, { backgroundColor: theme.colors.dark }]} />
                            </View>
                            {/* Tema Adı */}
                            <View style={styles.themeInfo}>
                                <Text style={styles.themeIcon}>{theme.icon}</Text>
                                <Text style={[
                                    styles.themeName,
                                    isSelected && { color: theme.colors.primary, fontWeight: 'bold' }
                                ]}>
                                    {theme.name}
                                </Text>
                            </View>
                            {/* Seçim İşareti */}
                            {isSelected && (
                                <View style={[styles.checkBadge, { backgroundColor: theme.colors.primary }]}>
                                    <Text style={styles.checkText}>✓</Text>
                                </View>
                            )}
                        </TouchableOpacity>
                    );
                })}
            </View>

            <View style={styles.info}>
                <Text style={styles.infoText}>Versiyon: 1.0.0</Text>
                <Text style={styles.infoText}>Geliştirici: MYY</Text>
            </View>
        </ScrollView>
    );
}

const getStyles = (colors) => StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: colors.background,
        padding: 20
    },
    header: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 30,
        color: colors.primary
    },
    row: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        paddingVertical: 15,
        borderBottomWidth: 1,
        borderBottomColor: colors.dark + '20'
    },
    label: {
        fontSize: 18,
        color: colors.text
    },
    value: {
        fontSize: 16,
        color: colors.textLight
    },
    sectionTitle: {
        fontSize: 20,
        fontWeight: 'bold',
        color: colors.primary,
        marginTop: 30,
        marginBottom: 15,
    },
    themeGrid: {
        gap: 12,
    },
    themeCard: {
        backgroundColor: colors.white,
        borderRadius: 16,
        padding: 16,
        borderWidth: 2,
        borderColor: colors.dark + '20',
        flexDirection: 'row',
        alignItems: 'center',
        elevation: 2,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.1,
        shadowRadius: 3,
    },
    themeCardSelected: {
        elevation: 5,
        shadowOpacity: 0.2,
        shadowRadius: 6,
    },
    colorPreview: {
        flexDirection: 'row',
        gap: 6,
        marginRight: 16,
    },
    colorDot: {
        width: 24,
        height: 24,
        borderRadius: 12,
        borderWidth: 1,
        borderColor: 'rgba(0,0,0,0.1)',
    },
    themeInfo: {
        flex: 1,
        flexDirection: 'row',
        alignItems: 'center',
        gap: 8,
    },
    themeIcon: {
        fontSize: 20,
    },
    themeName: {
        fontSize: 16,
        color: colors.text,
        fontWeight: '500',
    },
    checkBadge: {
        width: 28,
        height: 28,
        borderRadius: 14,
        justifyContent: 'center',
        alignItems: 'center',
    },
    checkText: {
        color: '#FFFFFF',
        fontSize: 14,
        fontWeight: 'bold',
    },
    info: {
        marginTop: 50,
        marginBottom: 30,
        alignItems: 'center'
    },
    infoText: {
        color: colors.textLight,
        marginBottom: 5
    }
});
