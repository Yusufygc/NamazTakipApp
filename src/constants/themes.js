// Mevcut varsayılan tema (colors.js ile birebir aynı)
const defaultTheme = {
    primary: '#A5C89E',
    secondary: '#D8E983',
    accent: '#FFFBB1',
    dark: '#AEB877',
    background: '#FAFAFA',
    white: '#FFFFFF',
    text: '#2C3E50',
    textLight: '#7F8C8D',
    success: '#D8E983',
    danger: '#ff8a80',
    warning: '#FFFBB1',
};

const darkTheme = {
    primary: '#5C8A6E',
    secondary: '#8BC34A',
    accent: '#FFD54F',
    dark: '#37474F',
    background: '#121212',
    white: '#1E1E1E',
    text: '#E0E0E0',
    textLight: '#9E9E9E',
    success: '#8BC34A',
    danger: '#ff8a80',
    warning: '#FFD54F',
};

const oceanTheme = {
    primary: '#5B9BD5',
    secondary: '#81D4FA',
    accent: '#B3E5FC',
    dark: '#1565C0',
    background: '#F5F9FF',
    white: '#FFFFFF',
    text: '#1A237E',
    textLight: '#5C6BC0',
    success: '#81D4FA',
    danger: '#ff8a80',
    warning: '#FFE082',
};

const roseTheme = {
    primary: '#C2727A',
    secondary: '#F48FB1',
    accent: '#FCE4EC',
    dark: '#880E4F',
    background: '#FFF5F7',
    white: '#FFFFFF',
    text: '#3E2723',
    textLight: '#8D6E63',
    success: '#F48FB1',
    danger: '#ff8a80',
    warning: '#FFE082',
};

const goldTheme = {
    primary: '#C9A94E',
    secondary: '#FFD54F',
    accent: '#FFF8E1',
    dark: '#6D5F1B',
    background: '#FFFEF5',
    white: '#FFFFFF',
    text: '#3E2723',
    textLight: '#8D6E63',
    success: '#FFD54F',
    danger: '#ff8a80',
    warning: '#FFE082',
};

export const THEMES = {
    default: {
        key: 'default',
        name: 'Varsayılan',
        icon: '🌿',
        colors: defaultTheme,
    },
    dark: {
        key: 'dark',
        name: 'Koyu',
        icon: '🌙',
        colors: darkTheme,
    },
    ocean: {
        key: 'ocean',
        name: 'Okyanus',
        icon: '🌊',
        colors: oceanTheme,
    },
    rose: {
        key: 'rose',
        name: 'Gül Kurusu',
        icon: '🌹',
        colors: roseTheme,
    },
    gold: {
        key: 'gold',
        name: 'Altın',
        icon: '✨',
        colors: goldTheme,
    },
};

export const THEME_KEYS = Object.keys(THEMES);
