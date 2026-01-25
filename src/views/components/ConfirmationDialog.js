import React from 'react';
import { Modal, View, Text, TouchableOpacity, StyleSheet } from 'react-native';

const ConfirmationDialog = ({ visible, prayerName, onClose, onConfirm, onMissed, onLater }) => {
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

                    <View style={styles.buttonRow}>
                        <TouchableOpacity style={[styles.button, styles.confirmButton]} onPress={onConfirm}>
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
        backgroundColor: '#fff',
        width: '85%',
        borderRadius: 20,
        padding: 20,
        alignItems: 'center',
        elevation: 5
    },
    icon: {
        fontSize: 40,
        marginBottom: 10
    },
    title: {
        fontSize: 18,
        color: '#555',
        fontWeight: 'bold'
    },
    subtitle: {
        fontSize: 22,
        fontWeight: 'bold',
        marginBottom: 20,
        color: '#333'
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
        borderRadius: 10,
        alignItems: 'center',
        marginHorizontal: 5
    },
    confirmButton: {
        backgroundColor: '#e8f5e9',
        borderWidth: 1,
        borderColor: '#4caf50'
    },
    missedButton: {
        backgroundColor: '#ffebee',
        borderWidth: 1,
        borderColor: '#ef5350'
    },
    buttonText: {
        fontSize: 16,
        fontWeight: '600'
    },
    laterButton: {
        padding: 10
    },
    laterText: {
        color: '#757575',
        textDecorationLine: 'underline'
    }
});

export default ConfirmationDialog;
