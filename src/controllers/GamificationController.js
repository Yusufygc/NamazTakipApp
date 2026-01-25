import { runQuery } from '../services/database/DatabaseService';

export const getStreakStats = async () => {
    try {
        // Get all dates where all 5 prayers were performed
        // We group by date and count performed prayers
        const result = await runQuery(`
            SELECT date, COUNT(*) as count 
            FROM prayers 
            WHERE is_performed = 1 
            GROUP BY date 
            HAVING count = 5 
            ORDER BY date DESC
        `);

        // result is [{date: '2023-10-27', count: 5}, ...]

        let currentStreak = 0;
        let bestStreak = 0; // This might need a separate query or persistent storage if we want "historical best"
        // For now, let's calculate "best streak ever recorded" from the full history we just fetched.
        // Note: If history is huge, this might be slow, but for a single user app it's fine.

        const dates = result.map(r => r.date);

        if (dates.length === 0) {
            return { currentStreak: 0, bestStreak: 0, totalFullDays: 0 };
        }

        // Setup for streak calculation
        const today = new Date().toISOString().split('T')[0];
        const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];

        // 1. Calculate Current Streak
        // Check if the most recent full day is today or yesterday
        const lastFullDay = dates[0];

        if (lastFullDay === today || lastFullDay === yesterday) {
            currentStreak = 1;
            // Iterate backwards
            for (let i = 0; i < dates.length - 1; i++) {
                const d1 = new Date(dates[i]);
                const d2 = new Date(dates[i + 1]);
                const diffTime = Math.abs(d1 - d2);
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

                if (diffDays === 1) {
                    currentStreak++;
                } else {
                    break;
                }
            }
        }

        // 2. Calculate Best Streak (iterate through all gaps)
        let tempStreak = 1;
        let maxStreak = 1;

        for (let i = 0; i < dates.length - 1; i++) {
            const d1 = new Date(dates[i]);
            const d2 = new Date(dates[i + 1]);
            const diffTime = Math.abs(d1 - d2);
            const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

            if (diffDays === 1) {
                tempStreak++;
            } else {
                if (tempStreak > maxStreak) maxStreak = tempStreak;
                tempStreak = 1;
            }
        }
        if (tempStreak > maxStreak) maxStreak = tempStreak;

        bestStreak = maxStreak;

        return {
            currentStreak,
            bestStreak,
            totalFullDays: dates.length
        };

    } catch (error) {
        console.error('Error calculating streak:', error);
        return { currentStreak: 0, bestStreak: 0, totalFullDays: 0 };
    }
};

export const getAchievements = async () => {
    try {
        // Fetch necessary stats
        // 1. Total congregation prayers
        const congregationResult = await runQuery(`
            SELECT COUNT(*) as count FROM prayers WHERE is_performed = 1 AND is_congregation = 1
        `);
        const totalCongregation = congregationResult[0]?.count || 0;

        // 2. Total Fajr prayers
        const fajrResult = await runQuery(`
            SELECT COUNT(*) as count FROM prayers WHERE is_performed = 1 AND prayer_name = 'Sabah'
        `);
        const totalFajr = fajrResult[0]?.count || 0;

        // 3. Get Streak info
        const streakStats = await getStreakStats();
        const currentStreak = streakStats.currentStreak;
        const totalFullDays = streakStats.totalFullDays;
        const bestStreak = streakStats.bestStreak;

        // Define Achievements
        const achievements = [
            {
                id: 'first_week',
                title: 'İlk Hafta',
                description: '7 gün üst üste tüm namazlar',
                icon: '✅',
                isUnlocked: bestStreak >= 7,
                progress: Math.min(bestStreak, 7),
                target: 7
            },
            {
                id: 'month_completer',
                title: 'Ay Tamamlayıcı',
                description: '30 gün tam namaz (Toplam)',
                icon: '🔥',
                isUnlocked: totalFullDays >= 30,
                progress: Math.min(totalFullDays, 30),
                target: 30
            },
            {
                id: 'hundred_days',
                title: '100 Gün',
                description: '100 gün tam namaz (Toplam)',
                icon: '💎',
                isUnlocked: totalFullDays >= 100,
                progress: Math.min(totalFullDays, 100),
                target: 100
            },
            {
                id: 'congregation_friendly',
                title: 'Cemaat Dostu',
                description: '50 vakit cemaatle namaz',
                icon: '🕌',
                isUnlocked: totalCongregation >= 50,
                progress: Math.min(totalCongregation, 50),
                target: 50
            },
            {
                id: 'morning_hero',
                title: 'Sabah Kahramanı',
                description: '30 sabah namazı',
                icon: '⏰',
                isUnlocked: totalFajr >= 30,
                progress: Math.min(totalFajr, 30),
                target: 30
            }
        ];

        return achievements;

    } catch (error) {
        console.error('Error getting achievements:', error);
        return [];
    }
};
