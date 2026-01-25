import { createDrawerNavigator } from '@react-navigation/drawer';
import HomeScreen from '../screens/HomeScreen';
import QazaListScreen from '../screens/QazaListScreen';
import SettingsScreen from '../screens/SettingsScreen';
import TabNavigator from './TabNavigator';

const Drawer = createDrawerNavigator();

export default function DrawerNavigator() {
    return (
        <Drawer.Navigator initialRouteName="Home">
            <Drawer.Screen name="Home" component={HomeScreen} options={{ title: 'Namaz Takip' }} />
            <Drawer.Screen name="QazaPrayers" component={QazaListScreen} options={{ title: 'Kaza Namazları' }} />
            <Drawer.Screen name="Statistics" component={TabNavigator} options={{ title: 'İstatistikler' }} />
            <Drawer.Screen name="Settings" component={SettingsScreen} options={{ title: 'Ayarlar' }} />
        </Drawer.Navigator>
    );
}
