import { format } from 'date-fns';

export const getTodayDateFormatted = () => {
    // Aladhan API expects DD-MM-YYYY
    return format(new Date(), 'dd-MM-yyyy');
};

export const formatDateForAPI = (date) => {
    return format(date, 'dd-MM-yyyy');
};

// Returns date string for display (23 Jan 2026) if needed
export const formatDateDisplay = (dateStr) => {
    return dateStr;
}
