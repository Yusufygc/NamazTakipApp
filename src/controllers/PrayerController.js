import { getPrayerTimesByCoordinates } from '../services/api/PrayerTimesAPI';
import { runQuery, runRun } from '../services/database/DatabaseService';

export const getPrayerTimes = async (date, city, country, latitude, longitude, forceUpdate = false) => {
    try {
        // 1. Check Cache
        if (!forceUpdate) {
            const cache = await runQuery(
                'SELECT * FROM prayer_times_cache WHERE date = ? AND city = ? LIMIT 1',
                [date, city]
            );

            if (cache.length > 0) {
                console.log('Serving from cache');
                return cache[0];
            }
        } else {
            console.log('Force update: deleting cache');
            await runRun('DELETE FROM prayer_times_cache WHERE date = ? AND city = ?', [date, city]);
        }

        // 2. Fetch from API
        console.log('Fetching from API (Coords)');
        const response = await getPrayerTimesByCoordinates(date, latitude, longitude);
        const timings = response.data.timings;
        const meta = response.data.meta || {};

        // 3. Save to Cache
        await runRun(
            `INSERT INTO prayer_times_cache (date, city, country, fajr, sunrise, dhuhr, asr, maghrib, isha, latitude, longitude)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
            [
                date,
                city,
                country,
                timings.Fajr,
                timings.Sunrise,
                timings.Dhuhr,
                timings.Asr,
                timings.Maghrib,
                timings.Isha,
                meta.latitude || 0,
                meta.longitude || 0
            ]
        );

        // 4. Create daily prayer records for tracking
        const prayerNames = ['Sabah', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
        const timeMap = {
            'Sabah': timings.Fajr,
            'Öğle': timings.Dhuhr,
            'İkindi': timings.Asr,
            'Akşam': timings.Maghrib,
            'Yatsı': timings.Isha
        };

        for (const name of prayerNames) {
            // Use INSERT OR IGNORE to avoid duplicates if re-running
            await runRun(
                `INSERT OR IGNORE INTO prayers (prayer_name, date, prayer_time, is_performed)
         VALUES (?, ?, ?, 0)`,
                [name, date, timeMap[name]]
            );
        }

        // Return the structure matching database/cache
        return {
            date,
            city,
            country,
            fajr: timings.Fajr,
            sunrise: timings.Sunrise,
            dhuhr: timings.Dhuhr,
            asr: timings.Asr,
            maghrib: timings.Maghrib,
            isha: timings.Isha
        };

    } catch (error) {
        console.error('Error in getPrayerTimes:', error);
        throw error;
    }
};

export const getTodaysPrayersStatus = async (date) => {
    try {
        const prayers = await runQuery(
            'SELECT * FROM prayers WHERE date = ?',
            [date]
        );
        return prayers;
    } catch (error) {
        console.error('Error fetching prayer status:', error);
        return [];
    }
};

export const getWeeklyStats = async () => {
    try {
        // Last 7 days
        const result = await runQuery(`
      SELECT date, COUNT(*) as count 
      FROM prayers 
      WHERE is_performed = 1
      GROUP BY date
      ORDER BY date DESC
      LIMIT 7
    `);
        return result.reverse(); // Show oldest first for chart
    } catch (error) {
        console.error(error);
        return [];
    }
};

export const getMonthlyStats = async () => {
    try {
        // Last 30 days
        const result = await runQuery(`
      SELECT date, COUNT(*) as count 
      FROM prayers 
      WHERE is_performed = 1
      GROUP BY date
      ORDER BY date DESC
      LIMIT 30
    `);
        return result.reverse();
    } catch (error) {
        console.error(error);
        return [];
    }
};

export const getComparisonStats = async () => {
    try {
        // Current week (last 7 days)
        const currentWeek = await runQuery(`
        SELECT COUNT(*) as count 
        FROM prayers 
        WHERE is_performed = 1 
        AND date >= date('now', '-7 days')
      `);

        // Previous week (7-14 days ago)
        const prevWeek = await runQuery(`
        SELECT COUNT(*) as count 
        FROM prayers 
        WHERE is_performed = 1 
        AND date < date('now', '-7 days')
        AND date >= date('now', '-14 days')
      `);

        return {
            currentWeek: currentWeek[0]?.count || 0,
            prevWeek: prevWeek[0]?.count || 0
        };
    } catch (error) {
        console.error(error);
        return { currentWeek: 0, prevWeek: 0 };
    }
};

// Get heatmap data for a specific month
// Returns array of { date, performedCount } for each day
export const getHeatmapData = async (year, month) => {
    try {
        // Database stores dates as DD-MM-YYYY format
        // So we need to search for dates ending with -MM-YYYY
        const monthStr = `${String(month).padStart(2, '0')}-${year}`;
        console.log('[Heatmap Query] Looking for dates like: %-' + monthStr);

        const result = await runQuery(`
            SELECT 
                date,
                SUM(CASE WHEN is_performed = 1 THEN 1 ELSE 0 END) as performedCount,
                COUNT(*) as totalCount
            FROM prayers
            WHERE date LIKE ?
            AND prayer_name != 'Güneş'
            GROUP BY date
            ORDER BY date ASC
        `, [`%-${monthStr}`]);

        console.log('[Heatmap Query] Result count:', result.length);

        return result;
    } catch (error) {
        console.error('Error getting heatmap data:', error);
        return [];
    }
};

// Get radar chart data - performance by prayer name
// Returns { Sabah: 85, Öğle: 90, İkindi: 75, Akşam: 95, Yatsı: 80 } as percentages
export const getRadarChartData = async (days = 30) => {
    try {
        const result = await runQuery(`
            SELECT 
                prayer_name,
                COUNT(*) as total,
                SUM(CASE WHEN is_performed = 1 THEN 1 ELSE 0 END) as performed
            FROM prayers
            WHERE prayer_name IN ('Sabah', 'Öğle', 'İkindi', 'Akşam', 'Yatsı')
            GROUP BY prayer_name
        `);

        // Convert to percentages
        const data = {
            Sabah: 0,
            Öğle: 0,
            İkindi: 0,
            Akşam: 0,
            Yatsı: 0
        };

        result.forEach(item => {
            if (item.total > 0) {
                data[item.prayer_name] = Math.round((item.performed / item.total) * 100);
            }
        });

        console.log('[RadarChart] Data:', JSON.stringify(data));
        return data;
    } catch (error) {
        console.error('Error getting radar chart data:', error);
        return { Sabah: 0, Öğle: 0, İkindi: 0, Akşam: 0, Yatsı: 0 };
    }
};
