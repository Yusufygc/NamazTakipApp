import { createDrawerNavigator } from '@react-navigation/drawer';
import HomeScreen from '../screens/HomeScreen';
import QazaListScreen from '../screens/QazaListScreen';
import SettingsScreen from '../screens/SettingsScreen';
import TabNavigator from './TabNavigator';
import { COLORS } from '../../constants/colors';

import GamificationScreen from '../screens/GamificationScreen';

const Drawer = createDrawerNavigator();

export default function DrawerNavigator() {
    return (
        <Drawer.Navigator
            initialRouteName="Home"
            screenOptions={{
                headerStyle: {
                    backgroundColor: COLORS.primary, // Sage
                },
                headerTintColor: COLORS.white,
                headerTitleStyle: {
                    fontWeight: 'bold',
                },
                drawerActiveTintColor: COLORS.primary,
                drawerInactiveTintColor: COLORS.text
            }}
        >
            <Drawer.Screen name="Home" component={HomeScreen} options={{ title: 'Namaz Takip' }} />
            <Drawer.Screen name="Gamification" component={GamificationScreen} options={{ title: 'Rozetler & Seri' }} />
            <Drawer.Screen name="QazaPrayers" component={QazaListScreen} options={{ title: 'Kaza Namazları' }} />
            <Drawer.Screen name="Statistics" component={TabNavigator} options={{ title: 'İstatistikler' }} />
            <Drawer.Screen name="Settings" component={SettingsScreen} options={{ title: 'Ayarlar' }} />
        </Drawer.Navigator>
    );
}
