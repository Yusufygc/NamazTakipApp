import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import WeeklyStats from '../screens/WeeklyStats';
import MonthlyStats from '../screens/MonthlyStats';
import ComparisonStats from '../screens/ComparisonStats';

const Tab = createBottomTabNavigator();

export default function TabNavigator() {
    return (
        <Tab.Navigator screenOptions={{ headerShown: false }}>
            <Tab.Screen name="Weekly" component={WeeklyStats} />
            <Tab.Screen name="Monthly" component={MonthlyStats} />
            <Tab.Screen name="Comparison" component={ComparisonStats} />
        </Tab.Navigator>
    );
}
