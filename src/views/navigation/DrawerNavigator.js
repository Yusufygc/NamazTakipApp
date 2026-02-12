import { createDrawerNavigator, DrawerContentScrollView, DrawerItemList } from '@react-navigation/drawer';
import { View, Text, StyleSheet, Platform, StatusBar } from 'react-native';
import HomeScreen from '../screens/HomeScreen';
import QazaListScreen from '../screens/QazaListScreen';
import SettingsScreen from '../screens/SettingsScreen';
import TabNavigator from './TabNavigator';
import { useTheme } from '../../context/ThemeContext';
import GamificationScreen from '../screens/GamificationScreen';
import AboutScreen from '../screens/AboutScreen';

const Drawer = createDrawerNavigator();

const STATUSBAR_HEIGHT = Platform.OS === 'android' ? (StatusBar.currentHeight || 24) : 44;

function CustomDrawerContent(props) {
    const { colors } = useTheme();
    const styles = getStyles(colors);

    return (
        <View style={styles.container}>
            {/* Header */}
            <View style={styles.header}>
                <Text style={styles.headerTitle}>Namaz Takip</Text>
                <Text style={styles.headerEmoji}>🕌</Text>
            </View>

            {/* Menu Items */}
            <DrawerContentScrollView {...props} contentContainerStyle={styles.scrollContent}>
                <DrawerItemList {...props} />
            </DrawerContentScrollView>

            {/* Footer */}
            <View style={styles.footer}>
                <Text style={styles.footerText}>v1.0.0</Text>
            </View>
        </View>
    );
}

const getStyles = (colors) => StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: colors.background,
    },
    header: {
        backgroundColor: colors.primary,
        paddingTop: STATUSBAR_HEIGHT + 12,
        paddingBottom: 18,
        paddingHorizontal: 20,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
    },
    headerTitle: {
        color: colors.white,
        fontSize: 22,
        fontWeight: 'bold',
    },
    headerEmoji: {
        fontSize: 28,
    },
    scrollContent: {
        paddingTop: 8,
    },
    footer: {
        padding: 16,
        borderTopWidth: 1,
        borderTopColor: colors.primary + '20',
        alignItems: 'center',
    },
    footerText: {
        color: colors.textLight,
        fontSize: 12,
    },
});

export default function DrawerNavigator() {
    const { colors } = useTheme();

    return (
        <Drawer.Navigator
            initialRouteName="Home"
            drawerContent={(props) => <CustomDrawerContent {...props} />}
            screenOptions={{
                headerStyle: {
                    backgroundColor: colors.primary,
                    elevation: 4,
                    shadowOpacity: 0.3,
                },
                headerTintColor: colors.white,
                headerTitleStyle: {
                    fontWeight: 'bold',
                },
                drawerActiveTintColor: colors.white,
                drawerActiveBackgroundColor: colors.primary,
                drawerInactiveTintColor: colors.text,
                drawerStyle: {
                    backgroundColor: colors.background,
                    width: 280,
                },
                drawerLabelStyle: {
                    fontSize: 15,
                    fontWeight: '500',
                    marginLeft: -10,
                },
                drawerItemStyle: {
                    borderRadius: 8,
                    marginHorizontal: 8,
                    marginVertical: 2,
                },
            }}
        >
            <Drawer.Screen name="Home" component={HomeScreen} options={{ title: 'Namaz Takip' }} />
            <Drawer.Screen name="Gamification" component={GamificationScreen} options={{ title: 'Rozetler & Seri' }} />
            <Drawer.Screen name="QazaPrayers" component={QazaListScreen} options={{ title: 'Kaza Namazları' }} />
            <Drawer.Screen name="Statistics" component={TabNavigator} options={{ title: 'İstatistikler' }} />
            <Drawer.Screen name="Settings" component={SettingsScreen} options={{ title: 'Ayarlar' }} />
            <Drawer.Screen name="About" component={AboutScreen} options={{ title: 'Hakkında' }} />
        </Drawer.Navigator>
    );
}
