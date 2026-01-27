import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import WeeklyStats from '../screens/WeeklyStats';
import MonthlyStats from '../screens/MonthlyStats';
import ComparisonStats from '../screens/ComparisonStats';
import PrayerHeatmap from '../components/PrayerHeatmap';
import PrayerRadarChart from '../components/PrayerRadarChart';
import { COLORS } from '../../constants/colors';

const Tab = createBottomTabNavigator();

export default function TabNavigator() {
    return (
        <Tab.Navigator
            screenOptions={{
                headerShown: false,
                tabBarActiveTintColor: COLORS.primary,
                tabBarInactiveTintColor: COLORS.textLight,
                tabBarStyle: {
                    backgroundColor: COLORS.white,
                    borderTopColor: COLORS.background
                }
            }}
        >
            <Tab.Screen name="Haftalık" component={WeeklyStats} />
            <Tab.Screen name="Performans" component={PrayerRadarChart} />
            <Tab.Screen name="Isı Haritası" component={PrayerHeatmap} />
            <Tab.Screen name="Karşılaştırma" component={ComparisonStats} />
        </Tab.Navigator>
    );
}
