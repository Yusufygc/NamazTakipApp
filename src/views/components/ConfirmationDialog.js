import React from 'react';
import { Modal, View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { COLORS } from '../../constants/colors';

const ConfirmationDialog = ({ visible, prayerName, onClose, onConfirm, onMissed, onLater }) => {
    const [isCongregation, setIsCongregation] = React.useState(false);

    // Reset state when visible changes (if necessary, but modal unmounts usually reset? No, visible prop controls. Better to use useEffect)
    React.useEffect(() => {
        if (visible) setIsCongregation(false);
    }, [visible]);

    return (
        <Modal
            transparent={true}
            visible={visible}
            animationType="fade"
            onRequestClose={onClose}
        >
            <View style={styles.overlay}>
                <View style={styles.dialog}>
                    <Text style={styles.icon}>🕌</Text>
                    <Text style={styles.title}>{prayerName?.toUpperCase()} NAMAZINI</Text>
                    <Text style={styles.subtitle}>KILDINIZ MI?</Text>

                    <View style={styles.checkboxContainer}>
                        <TouchableOpacity
                            style={styles.checkbox}
                            onPress={() => setIsCongregation(!isCongregation)}
                        >
                            <Text style={styles.checkboxIcon}>{isCongregation ? '☑️' : '⬜'}</Text>
                            <Text style={styles.checkboxText}>Cemaatle kıldım</Text>
                        </TouchableOpacity>
                    </View>

                    <View style={styles.buttonRow}>
                        <TouchableOpacity style={[styles.button, styles.confirmButton]} onPress={() => onConfirm(isCongregation)}>
                            <Text style={styles.buttonText}>Kıldım ✅</Text>
                        </TouchableOpacity>
                        <TouchableOpacity style={[styles.button, styles.missedButton]} onPress={onMissed}>
                            <Text style={styles.buttonText}>Kılmadım ❌</Text>
                        </TouchableOpacity>
                    </View>

                    <TouchableOpacity style={styles.laterButton} onPress={onLater}>
                        <Text style={styles.laterText}>Daha Sonra Hatırlat</Text>
                    </TouchableOpacity>
                </View>
            </View>
        </Modal>
    );
};

const styles = StyleSheet.create({
    overlay: {
        flex: 1,
        backgroundColor: 'rgba(0,0,0,0.5)',
        justifyContent: 'center',
        alignItems: 'center'
    },
    dialog: {
        backgroundColor: COLORS.white,
        width: '85%',
        borderRadius: 20,
        padding: 20,
        alignItems: 'center',
        elevation: 5,
        shadowColor: "#000",
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.25,
        shadowRadius: 3.84,
    },
    icon: {
        fontSize: 40,
        marginBottom: 10
    },
    title: {
        fontSize: 16,
        color: COLORS.textLight,
        fontWeight: '600',
        marginBottom: 5
    },
    subtitle: {
        fontSize: 24,
        fontWeight: 'bold',
        marginBottom: 25,
        color: COLORS.text
    },
    buttonRow: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        width: '100%',
        marginBottom: 15
    },
    button: {
        flex: 1,
        padding: 15,
        borderRadius: 12,
        alignItems: 'center',
        marginHorizontal: 5
    },
    confirmButton: {
        backgroundColor: COLORS.secondary, // Lime
        borderWidth: 0, // No border for cleaner look
    },
    missedButton: {
        backgroundColor: '#FFEBEE', // Keep red tint for negative action but softer? Or use maybe COLORS.accent?
        // Let's stick to conventional red for missed/danger but soften it.
        // Or user asked for specific palette. 
        // Let's use COLORS.white with red border?
        backgroundColor: COLORS.white,
        borderWidth: 2,
        borderColor: '#ef5350'
    },
    buttonText: {
        fontSize: 16,
        fontWeight: 'bold',
        color: COLORS.text
    },
    laterButton: {
        padding: 10
    },
    laterText: {
        color: COLORS.textLight,
        textDecorationLine: 'underline'
    },
    checkboxContainer: {
        marginBottom: 20,
        flexDirection: 'row',
        alignItems: 'center'
    },
    checkbox: {
        flexDirection: 'row',
        alignItems: 'center'
    },
    checkboxIcon: {
        fontSize: 24,
        marginRight: 10
    },
    checkboxText: {
        fontSize: 16,
        color: COLORS.text,
        fontWeight: '500'
    }
});

export default ConfirmationDialog;
