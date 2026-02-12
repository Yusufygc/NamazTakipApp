import React, { useState, useCallback } from 'react';
import { View, Text, StyleSheet, Dimensions } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import Svg, { Polygon, Line, Circle, Text as SvgText, G } from 'react-native-svg';
import { getRadarChartData } from '../../controllers/PrayerController';
import { useTheme } from '../../context/ThemeContext';

const screenWidth = Dimensions.get('window').width;
const SIZE = screenWidth - 40; // Daha geniş alan
const CENTER = SIZE / 2;
const RADIUS = SIZE / 2 - 60; // Etiketler için daha fazla alan

const PRAYERS = ['Sabah', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
const ANGLES = PRAYERS.map((_, i) => (Math.PI * 2 * i) / PRAYERS.length - Math.PI / 2);

// Convert polar to cartesian coordinates
const polarToCartesian = (angle, radius) => {
    return {
        x: CENTER + radius * Math.cos(angle),
        y: CENTER + radius * Math.sin(angle)
    };
};

// Generate polygon points string
const getPolygonPoints = (values) => {
    return PRAYERS.map((prayer, i) => {
        const value = values[prayer] || 0;
        const radius = (value / 100) * RADIUS;
        const point = polarToCartesian(ANGLES[i], radius);
        return `${point.x},${point.y}`;
    }).join(' ');
};

// Generate grid polygon points
const getGridPolygonPoints = (level) => {
    const radius = (level / 100) * RADIUS;
    return ANGLES.map(angle => {
        const point = polarToCartesian(angle, radius);
        return `${point.x},${point.y}`;
    }).join(' ');
};

export default function PrayerRadarChart() {
    const [data, setData] = useState({
        Sabah: 0,
        Öğle: 0,
        İkindi: 0,
        Akşam: 0,
        Yatsı: 0
    });
    const [loading, setLoading] = useState(true);
    const { colors } = useTheme();

    useFocusEffect(
        useCallback(() => {
            loadData();
        }, [])
    );

    const loadData = async () => {
        setLoading(true);
        const chartData = await getRadarChartData();
        setData(chartData);
        setLoading(false);
    };

    // Grid levels: 20%, 40%, 60%, 80%, 100%
    const gridLevels = [20, 40, 60, 80, 100];
    const styles = getStyles(colors);

    return (
        <View style={styles.container}>
            <Text style={styles.title}>🕌 Namaz Performansı</Text>
            <Text style={styles.subtitle}>Her namaz vaktindeki kılma oranınız</Text>

            <View style={styles.chartContainer}>
                <Svg width={SIZE} height={SIZE}>
                    {/* Grid lines (pentagons) */}
                    {gridLevels.map(level => (
                        <Polygon
                            key={level}
                            points={getGridPolygonPoints(level)}
                            fill="none"
                            stroke={colors.textLight}
                            strokeWidth="0.5"
                            strokeOpacity={0.3}
                        />
                    ))}

                    {/* Axis lines from center to each vertex */}
                    {ANGLES.map((angle, i) => {
                        const end = polarToCartesian(angle, RADIUS);
                        return (
                            <Line
                                key={i}
                                x1={CENTER}
                                y1={CENTER}
                                x2={end.x}
                                y2={end.y}
                                stroke={colors.textLight}
                                strokeWidth="0.5"
                                strokeOpacity={0.3}
                            />
                        );
                    })}

                    {/* Data polygon */}
                    <Polygon
                        points={getPolygonPoints(data)}
                        fill={colors.primary}
                        fillOpacity={0.4}
                        stroke={colors.primary}
                        strokeWidth="2"
                    />

                    {/* Data points with values */}
                    {PRAYERS.map((prayer, i) => {
                        const value = data[prayer] || 0;
                        const radius = (value / 100) * RADIUS;
                        const point = polarToCartesian(ANGLES[i], radius);
                        return (
                            <G key={prayer}>
                                <Circle
                                    cx={point.x}
                                    cy={point.y}
                                    r="6"
                                    fill={colors.primary}
                                    stroke={colors.white}
                                    strokeWidth="2"
                                />
                            </G>
                        );
                    })}

                    {/* Labels */}
                    {PRAYERS.map((prayer, i) => {
                        const labelRadius = RADIUS + 35; // Daha uzak etiketler
                        const point = polarToCartesian(ANGLES[i], labelRadius);
                        const value = data[prayer] || 0;

                        // Sabah (üstte) için y offset ekle
                        const isTop = i === 0; // Sabah en üstte
                        const yOffset = isTop ? 10 : 0;

                        return (
                            <G key={prayer}>
                                <SvgText
                                    x={point.x}
                                    y={point.y + yOffset}
                                    fontSize="14"
                                    fontWeight="600"
                                    fill={colors.text}
                                    textAnchor="middle"
                                >
                                    {prayer}
                                </SvgText>
                                <SvgText
                                    x={point.x}
                                    y={point.y + yOffset + 16}
                                    fontSize="12"
                                    fontWeight="bold"
                                    fill={value >= 80 ? '#4CAF50' : value >= 50 ? '#FFC107' : '#F44336'}
                                    textAnchor="middle"
                                >
                                    % {value}
                                </SvgText>
                            </G>
                        );
                    })}
                </Svg>
            </View>

            {/* Legend */}
            <View style={styles.legend}>
                <View style={styles.legendItem}>
                    <View style={[styles.legendDot, { backgroundColor: '#4CAF50' }]} />
                    <Text style={styles.legendText}>%80+ Harika</Text>
                </View>
                <View style={styles.legendItem}>
                    <View style={[styles.legendDot, { backgroundColor: '#FFC107' }]} />
                    <Text style={styles.legendText}>%50-79 İyi</Text>
                </View>
                <View style={styles.legendItem}>
                    <View style={[styles.legendDot, { backgroundColor: '#F44336' }]} />
                    <Text style={styles.legendText}>%0-49 Geliştir</Text>
                </View>
            </View>

            {/* Weak prayer indicator */}
            {!loading && (
                <View style={styles.insightCard}>
                    <Text style={styles.insightTitle}>💡 Analiz</Text>
                    <Text style={styles.insightText}>
                        {getInsight(data)}
                    </Text>
                </View>
            )}

            {loading && <Text style={styles.loadingText}>Yükleniyor...</Text>}
        </View>
    );
}

// Get insight text based on data
const getInsight = (data) => {
    const entries = Object.entries(data);
    const min = entries.reduce((a, b) => a[1] < b[1] ? a : b);
    const max = entries.reduce((a, b) => a[1] > b[1] ? a : b);

    if (min[1] === max[1] && min[1] === 100) {
        return "Mükemmel! Tüm namazlarınızı düzenli kılıyorsunuz. 🌟";
    }

    if (min[1] < 50) {
        return `${min[0]} namazında gelişme gösterebilirsiniz. En güçlü olduğunuz vakit: ${max[0]} (%${max[1]})`;
    }

    return `En güçlü vakitiniz: ${max[0]} (%${max[1]}). Devam edin!`;
};

const getStyles = (colors) => StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: colors.background,
        padding: 16,
        alignItems: 'center',
    },
    title: {
        fontSize: 22,
        fontWeight: 'bold',
        color: colors.primary,
        marginBottom: 4,
    },
    subtitle: {
        fontSize: 14,
        color: colors.textLight,
        marginBottom: 16,
    },
    chartContainer: {
        backgroundColor: colors.white,
        borderRadius: 16,
        padding: 16,
        elevation: 3,
        shadowColor: colors.dark,
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
    },
    legend: {
        flexDirection: 'row',
        justifyContent: 'center',
        marginTop: 16,
        gap: 16,
    },
    legendItem: {
        flexDirection: 'row',
        alignItems: 'center',
        gap: 6,
    },
    legendDot: {
        width: 12,
        height: 12,
        borderRadius: 6,
    },
    legendText: {
        fontSize: 12,
        color: colors.textLight,
    },
    insightCard: {
        backgroundColor: colors.accent,
        borderRadius: 12,
        padding: 16,
        marginTop: 16,
        width: '100%',
    },
    insightTitle: {
        fontSize: 16,
        fontWeight: 'bold',
        color: colors.text,
        marginBottom: 8,
    },
    insightText: {
        fontSize: 14,
        color: colors.text,
        lineHeight: 20,
    },
    loadingText: {
        marginTop: 16,
        color: colors.textLight,
    },
});
