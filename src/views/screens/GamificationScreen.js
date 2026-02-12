import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, ScrollView, RefreshControl, Dimensions, TouchableOpacity } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { useTheme } from '../../context/ThemeContext';
import { getAchievements } from '../../controllers/GamificationController';

const { width } = Dimensions.get('window');

const AchievementCard = ({ item, colors }) => {
    const styles = getStyles(colors);
    return (
        <View style={[styles.card, !item.isUnlocked && styles.lockedCard]}>
            <View style={styles.iconContainer}>
                <Text style={styles.icon}>{item.isUnlocked ? item.icon : '🔒'}</Text>
            </View>
            <View style={styles.contentContainer}>
                <Text style={styles.cardTitle}>{item.title}</Text>
                <Text style={styles.cardDescription}>{item.description}</Text>
                <View style={styles.progressBarContainer}>
                    <View style={[styles.progressBar, { width: `${(item.progress / item.target) * 100}%` }]} />
                </View>
                <Text style={styles.progressText}>{item.progress} / {item.target}</Text>
            </View>
            {item.isUnlocked && <Text style={styles.checkMark}>✅</Text>}
        </View>
    );
};

export default function GamificationScreen() {
    const [stats, setStats] = useState({
        achievements: [],
        currentStreak: 0,
        bestStreak: 0
    });
    const [refreshing, setRefreshing] = useState(false);
    const { colors } = useTheme();

    const loadData = async () => {
        const achievements = await getAchievements();
        const { getStreakStats } = require('../../controllers/GamificationController');
        const streakData = await getStreakStats();

        setStats({
            achievements,
            currentStreak: streakData.currentStreak,
            bestStreak: streakData.bestStreak
        });
        setRefreshing(false);
    };

    useFocusEffect(
        useCallback(() => {
            loadData();
        }, [])
    );

    const styles = getStyles(colors);

    return (
        <ScrollView
            style={styles.container}
            refreshControl={<RefreshControl refreshing={refreshing} onRefresh={() => { setRefreshing(true); loadData(); }} />}
        >
            <View style={styles.header}>
                <Text style={styles.headerTitle}>Başarılarım</Text>
            </View>

            {/* STREAK CARD */}
            <View style={styles.streakContainer}>
                <View style={styles.fireContainer}>
                    <Text style={styles.fireIcon}>🔥</Text>
                </View>
                <View style={styles.streakInfo}>
                    <Text style={styles.streakTitle}>KESİNTİSİZ SERİ</Text>
                    <Text style={styles.streakCount}>{stats.currentStreak} GÜN</Text>
                    <Text style={styles.streakSub}>En uzun seri: {stats.bestStreak} gün</Text>
                </View>
            </View>

            {/* ACHIEVEMENTS LIST */}
            <Text style={styles.sectionTitle}>ROZETLER</Text>
            <View style={styles.grid}>
                {stats.achievements.map((item, index) => (
                    <AchievementCard key={item.id} item={item} colors={colors} />
                ))}
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
        marginBottom: 20,
        alignItems: 'center'
    },
    headerTitle: {
        fontSize: 24,
        fontWeight: 'bold',
        color: colors.primary
    },
    streakContainer: {
        backgroundColor: colors.white,
        borderRadius: 20,
        padding: 20,
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 30,
        elevation: 5,
        shadowColor: colors.primary,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.2,
        shadowRadius: 10,
    },
    fireContainer: {
        backgroundColor: '#FFF3E0', // Light orange
        width: 80,
        height: 80,
        borderRadius: 40,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 20
    },
    fireIcon: {
        fontSize: 40
    },
    streakInfo: {
        flex: 1
    },
    streakTitle: {
        fontSize: 14,
        color: colors.textLight,
        marginBottom: 5,
        letterSpacing: 1,
        fontWeight: '600'
    },
    streakCount: {
        fontSize: 32,
        fontWeight: 'bold',
        color: colors.text,
        marginBottom: 5
    },
    streakSub: {
        fontSize: 14,
        color: colors.textLight
    },
    sectionTitle: {
        fontSize: 18,
        fontWeight: 'bold',
        color: colors.text,
        marginBottom: 15
    },
    grid: {
        paddingBottom: 40
    },
    card: {
        backgroundColor: colors.white,
        borderRadius: 16,
        padding: 15,
        marginBottom: 15,
        flexDirection: 'row',
        alignItems: 'center',
        elevation: 2,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4
    },
    lockedCard: {
        backgroundColor: colors.background,
        opacity: 0.8
    },
    iconContainer: {
        width: 50,
        height: 50,
        borderRadius: 25,
        backgroundColor: colors.background,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 15
    },
    icon: {
        fontSize: 24
    },
    contentContainer: {
        flex: 1
    },
    cardTitle: {
        fontSize: 16,
        fontWeight: 'bold',
        color: colors.text,
        marginBottom: 2
    },
    cardDescription: {
        fontSize: 12,
        color: colors.textLight,
        marginBottom: 8
    },
    progressBarContainer: {
        height: 6,
        backgroundColor: '#E0E0E0',
        borderRadius: 3,
        overflow: 'hidden',
        marginBottom: 4
    },
    progressBar: {
        height: '100%',
        backgroundColor: colors.secondary, // Lime green
        borderRadius: 3
    },
    progressText: {
        fontSize: 10,
        color: colors.textLight,
        textAlign: 'right'
    },
    checkMark: {
        marginLeft: 10,
        fontSize: 16
    }
});
