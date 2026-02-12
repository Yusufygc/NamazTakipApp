import { createDrawerNavigator, DrawerContentScrollView, DrawerItemList } from '@react-navigation/drawer';
import { View, Text, ImageBackground, StyleSheet } from 'react-native';
import HomeScreen from '../screens/HomeScreen';
import QazaListScreen from '../screens/QazaListScreen';
import SettingsScreen from '../screens/SettingsScreen';
import TabNavigator from './TabNavigator';
import { useTheme } from '../../context/ThemeContext';
import GamificationScreen from '../screens/GamificationScreen';
import AboutScreen from '../screens/AboutScreen';

const Drawer = createDrawerNavigator();

// Custom Drawer Content with Ayasofya background
function CustomDrawerContent(props) {
    const { colors } = useTheme();
    const styles = getStyles(colors);

    return (
        <ImageBackground
            source={require('../../../assets/images/Ayasofya.png')}
            style={styles.backgroundImage}
            imageStyle={{ opacity: 0.25 }}
        >
            {/* Header Section */}
            <View style={styles.headerContainer}>
                <Text style={styles.headerTitle}>Namaz Takip</Text>
                <Text style={styles.headerSubtitle}>🕌</Text>
            </View>

            {/* Drawer Items */}
            <DrawerContentScrollView {...props} contentContainerStyle={styles.drawerContent}>
                <DrawerItemList {...props} />
            </DrawerContentScrollView>
        </ImageBackground>
    );
}

const getStyles = (colors) => StyleSheet.create({
    backgroundImage: {
        flex: 1,
    },
    headerContainer: {
        backgroundColor: colors.primary,
        paddingTop: 50,
        paddingBottom: 20,
        paddingHorizontal: 20,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
    },
    headerTitle: {
        color: colors.white,
        fontSize: 24,
        fontWeight: 'bold',
    },
    headerSubtitle: {
        fontSize: 28,
    },
    drawerContent: {
        paddingTop: 10,
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
                },
                headerTintColor: colors.white,
                headerTitleStyle: {
                    fontWeight: 'bold',
                },
                drawerActiveTintColor: colors.background,
                drawerActiveBackgroundColor: colors.primary + '99',
                drawerInactiveTintColor: colors.text,
                drawerStyle: {
                    backgroundColor: 'transparent',
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
