import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import ComparisonStats from '../screens/ComparisonStats';
import PrayerHeatmap from '../components/PrayerHeatmap';
import PrayerRadarChart from '../components/PrayerRadarChart';
import { useTheme } from '../../context/ThemeContext';
import { MaterialCommunityIcons } from '@expo/vector-icons';

const Tab = createBottomTabNavigator();

export default function TabNavigator() {
    const { colors } = useTheme();

    return (
        <Tab.Navigator
            screenOptions={{
                headerShown: false,
                tabBarActiveTintColor: colors.primary,
                tabBarInactiveTintColor: colors.textLight,
                tabBarStyle: {
                    backgroundColor: colors.white,
                    borderTopColor: colors.background
                }
            }}
        >
            <Tab.Screen
                name="Performans"
                component={PrayerRadarChart}
                options={{
                    tabBarIcon: ({ color, size }) => (
                        <MaterialCommunityIcons name="radar" size={size} color={color} />
                    ),
                }}
            />
            <Tab.Screen
                name="Isı Haritası"
                component={PrayerHeatmap}
                options={{
                    tabBarIcon: ({ color, size }) => (
                        <MaterialCommunityIcons name="grid" size={size} color={color} />
                    ),
                }}
            />
            <Tab.Screen
                name="Karşılaştırma"
                component={ComparisonStats}
                options={{
                    tabBarIcon: ({ color, size }) => (
                        <MaterialCommunityIcons name="compare" size={size} color={color} />
                    ),
                }}
            />
        </Tab.Navigator>
    );
}
