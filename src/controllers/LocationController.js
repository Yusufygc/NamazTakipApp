import * as Location from 'expo-location';

export const getLocation = async () => {
    try {
        const { status } = await Location.requestForegroundPermissionsAsync();
        if (status !== 'granted') {
            throw new Error('Permission to access location was denied');
        }

        const location = await Location.getCurrentPositionAsync({});

        // Reverse geocode to get city and country
        const address = await Location.reverseGeocodeAsync({
            latitude: location.coords.latitude,
            longitude: location.coords.longitude
        });

        let city = '';
        let country = '';

        if (address && address.length > 0) {
            const addr = address[0];
            city = addr.city || addr.subregion || addr.region || 'Unknown';
            country = addr.country || 'Turkey'; // Default for safety
        }

        return {
            latitude: location.coords.latitude,
            longitude: location.coords.longitude,
            city,
            country
        };
    } catch (error) {
        console.error('Location error:', error);
        throw error;
    }
};
