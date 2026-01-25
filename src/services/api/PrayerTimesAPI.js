import axios from 'axios';

const BASE_URL = 'https://api.aladhan.com/v1';

export const getPrayerTimesByCoordinates = async (date, latitude, longitude, method = 13) => {
    try {
        const response = await axios.get(`${BASE_URL}/timings/${date}`, {
            params: {
                latitude,
                longitude,
                method
            }
        });

        if (response.data && response.data.code === 200) {
            return response.data;
        } else {
            throw new Error('API returned error');
        }
    } catch (error) {
        console.error('Prayer API Error:', error);
        throw error;
    }
};
