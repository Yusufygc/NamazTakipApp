import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View } from 'react-native';
import { useEffect, useState } from 'react';
import { initDB } from './src/services/database/DatabaseService';
import { registerForPushNotificationsAsync } from './src/services/notifications/NotificationService';
import { registerBackgroundTask } from './src/services/background/BackgroundTaskService';
import RootNavigator from './src/views/navigation/RootNavigator';
import { ThemeProvider } from './src/context/ThemeContext';
import 'react-native-gesture-handler'; // Required for Drawer

export default function App() {
    const [dbInitialized, setDbInitialized] = useState(false);

    useEffect(() => {
        const setup = async () => {
            try {
                await initDB();
                // Request notification permissions
                await registerForPushNotificationsAsync();
                // Register background task for periodic prayer time refresh
                await registerBackgroundTask();
                setDbInitialized(true);
            } catch (e) {
                console.error('DB Init Error:', e);
            }
        };
        setup();
    }, []);

    if (!dbInitialized) {
        return (
            <View style={styles.container}>
                <Text>Loading...</Text>
            </View>
        );
    }

    return (
        <ThemeProvider>
            <RootNavigator />
            <StatusBar style="auto" />
        </ThemeProvider>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#fff',
        alignItems: 'center',
        justifyContent: 'center',
    },
});
