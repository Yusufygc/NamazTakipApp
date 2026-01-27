import { createDrawerNavigator, DrawerContentScrollView, DrawerItemList } from '@react-navigation/drawer';
import { View, Text, ImageBackground, StyleSheet } from 'react-native';
import HomeScreen from '../screens/HomeScreen';
import QazaListScreen from '../screens/QazaListScreen';
import SettingsScreen from '../screens/SettingsScreen';
import TabNavigator from './TabNavigator';
import { COLORS } from '../../constants/colors';
import GamificationScreen from '../screens/GamificationScreen';

const Drawer = createDrawerNavigator();

// Custom Drawer Content with Ayasofya background
function CustomDrawerContent(props) {
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

const styles = StyleSheet.create({
    backgroundImage: {
        flex: 1,
    },
    headerContainer: {
        backgroundColor: COLORS.primary,
        paddingTop: 50,
        paddingBottom: 20,
        paddingHorizontal: 20,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
    },
    headerTitle: {
        color: COLORS.white,
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
    return (
        <Drawer.Navigator
            initialRouteName="Home"
            drawerContent={(props) => <CustomDrawerContent {...props} />}
            screenOptions={{
                headerStyle: {
                    backgroundColor: COLORS.primary,
                },
                headerTintColor: COLORS.white,
                headerTitleStyle: {
                    fontWeight: 'bold',
                },
                drawerActiveTintColor: COLORS.background,
                drawerActiveBackgroundColor: 'rgba(165, 200, 158, 0.6)',
                drawerInactiveTintColor: COLORS.text,
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
        </Drawer.Navigator>
    );
}
