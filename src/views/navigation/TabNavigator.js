import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import WeeklyStats from '../screens/WeeklyStats';
import MonthlyStats from '../screens/MonthlyStats';
import ComparisonStats from '../screens/ComparisonStats';
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
            <Tab.Screen name="Weekly" component={WeeklyStats} />
            <Tab.Screen name="Monthly" component={MonthlyStats} />
            <Tab.Screen name="Comparison" component={ComparisonStats} />
        </Tab.Navigator>
    );
}
