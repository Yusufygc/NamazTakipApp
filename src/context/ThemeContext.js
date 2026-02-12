import React, { createContext, useContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { THEMES } from '../constants/themes';

const THEME_STORAGE_KEY = '@prayer_tracker_theme';

const ThemeContext = createContext();

export function ThemeProvider({ children }) {
    const [themeName, setThemeName] = useState('default');
    const [isLoaded, setIsLoaded] = useState(false);

    // Uygulama açılışında kaydedilmiş temayı yükle
    useEffect(() => {
        const loadTheme = async () => {
            try {
                const savedTheme = await AsyncStorage.getItem(THEME_STORAGE_KEY);
                if (savedTheme && THEMES[savedTheme]) {
                    setThemeName(savedTheme);
                }
            } catch (e) {
                console.error('Tema yüklenirken hata:', e);
            }
            setIsLoaded(true);
        };
        loadTheme();
    }, []);

    // Tema değiştir ve kaydet
    const setTheme = async (newThemeName) => {
        if (!THEMES[newThemeName]) return;
        setThemeName(newThemeName);
        try {
            await AsyncStorage.setItem(THEME_STORAGE_KEY, newThemeName);
        } catch (e) {
            console.error('Tema kaydedilirken hata:', e);
        }
    };

    const colors = THEMES[themeName]?.colors || THEMES.default.colors;

    return (
        <ThemeContext.Provider value={{
            colors,
            themeName,
            setTheme,
            themes: THEMES,
            isLoaded,
        }}>
            {children}
        </ThemeContext.Provider>
    );
}

export function useTheme() {
    const context = useContext(ThemeContext);
    if (!context) {
        throw new Error('useTheme must be used within a ThemeProvider');
    }
    return context;
}
