import { format, subDays, addDays } from 'date-fns';

/**
 * Bugünün tarihini DD-MM-YYYY formatında döner.
 * API çağrıları ve genel kullanım için.
 */
export const getTodayDateFormatted = () => {
    // Aladhan API expects DD-MM-YYYY
    return format(new Date(), 'dd-MM-yyyy');
};

/**
 * Verilen Date nesnesini DD-MM-YYYY formatına çevirir.
 */
export const formatDateForAPI = (date) => {
    return format(date, 'dd-MM-yyyy');
};

/**
 * İslami gün tanımına göre "bugünün" tarihini döner.
 * 
 * Sorun: Gece yarısı (00:00) sonrası sistem yeni güne geçer,
 * ancak İslami takvimde gün akşam ezanıyla başlar.
 * Kullanıcı gece 00:30'da Yatsı namazını kılmak isteyebilir —
 * bu durumda hâlâ "dünün" namazıdır.
 * 
 * Çözüm: Saat 00:00 – 04:00 arasında bir önceki günü döner.
 * Sabah ezanı genelde 04:30+ olduğundan, 04:00 güvenli bir eşik.
 */
export const getPrayerDateFormatted = () => {
    const now = new Date();
    const hour = now.getHours();

    // Gece geç saatleri (00:00 - 03:59): dünkü namazlar hâlâ geçerli
    if (hour < 4) {
        return format(subDays(now, 1), 'dd-MM-yyyy');
    }

    return format(now, 'dd-MM-yyyy');
};

/**
 * Gece geç saatlerinde miyiz? (00:00 - 03:59)
 * Bu saat diliminde dünkü Yatsı namazı hâlâ "aktif" kabul edilir.
 */
export const isLateNightPeriod = () => {
    return new Date().getHours() < 4;
};

/**
 * Sonraki N günün tarihlerini DD-MM-YYYY formatında döner.
 * Bildirim planlama için kullanılır.
 */
export const getNextDaysFormatted = (days = 3) => {
    const dates = [];
    const now = new Date();
    for (let i = 0; i < days; i++) {
        dates.push(format(addDays(now, i), 'dd-MM-yyyy'));
    }
    return dates;
};

// Returns date string for display (23 Jan 2026) if needed
export const formatDateDisplay = (dateStr) => {
    return dateStr;
};
