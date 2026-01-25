import React, { useState, useCallback } from 'react';
import { View, Text, FlatList, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { useFocusEffect } from '@react-navigation/native';
import { runQuery, runRun } from '../../services/database/DatabaseService';
import { getTodayDateFormatted } from '../../utils/dateHelpers';

export default function QazaListScreen() {
    const [qazaList, setQazaList] = useState([]);
    const [loading, setLoading] = useState(true);

    const loadQaza = async () => {
        try {
            // Fetch uncompensated qaza prayers
            const result = await runQuery(
                `SELECT * FROM qaza_prayers WHERE is_compensated = 0 ORDER BY missed_date DESC, id DESC`
            );
            setQazaList(result);
            setLoading(false);
        } catch (e) {
            console.error(e);
            setLoading(false);
        }
    };

    useFocusEffect(
        useCallback(() => {
            loadQaza();
        }, [])
    );

    const handleCompensate = (item) => {
        Alert.alert(
            'Kaza Namazı',
            `${item.missed_date} tarihli ${item.prayer_name} namazını kaza ettiniz mi?`,
            [
                { text: 'İptal', style: 'cancel' },
                {
                    text: 'Evet, Kıldım',
                    onPress: async () => {
                        try {
                            const today = getTodayDateFormatted();
                            // 1. Mark as compensated in qaza_prayers
                            await runRun(
                                `UPDATE qaza_prayers SET is_compensated = 1, compensated_at = ? WHERE id = ?`,
                                [today, item.id]
                            );

                            // 2. Update original prayer record if exists
                            // We match by date and name.
                            await runRun(
                                `UPDATE prayers SET is_performed = 1 WHERE date = ? AND prayer_name = ?`,
                                [item.missed_date, item.prayer_name]
                            );

                            loadQaza();
                        } catch (e) {
                            console.error(e);
                        }
                    }
                }
            ]
        );
    };

    const renderItem = ({ item }) => (
        <View style={styles.card}>
            <View style={styles.info}>
                <Text style={styles.name}>{item.prayer_name}</Text>
                <Text style={styles.date}>{item.missed_date}</Text>
                {item.notes ? <Text style={styles.notes}>{item.notes}</Text> : null}
            </View>
            <TouchableOpacity
                style={styles.button}
                onPress={() => handleCompensate(item)}
            >
                <Text style={styles.buttonText}>Kaza Et</Text>
            </TouchableOpacity>
        </View>
    );

    return (
        <View style={styles.container}>
            {qazaList.length === 0 ? (
                <View style={styles.empty}>
                    <Text style={styles.emptyText}>Kaza borcunuz bulunmuyor. 🤲</Text>
                </View>
            ) : (
                <FlatList
                    data={qazaList}
                    renderItem={renderItem}
                    keyExtractor={item => item.id.toString()}
                    contentContainerStyle={styles.list}
                />
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#fff',
        padding: 10
    },
    list: {
        paddingBottom: 20
    },
    card: {
        backgroundColor: '#fff',
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: 15,
        marginVertical: 5,
        marginHorizontal: 5,
        borderRadius: 10,
        elevation: 2,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.2,
        shadowRadius: 1.41
    },
    info: {
        flex: 1
    },
    name: {
        fontSize: 18,
        fontWeight: 'bold',
        color: '#333'
    },
    date: {
        fontSize: 14,
        color: '#666',
        marginTop: 2
    },
    notes: {
        fontSize: 12,
        color: '#999',
        marginTop: 2,
        fontStyle: 'italic'
    },
    button: {
        backgroundColor: '#ff9800',
        paddingVertical: 8,
        paddingHorizontal: 15,
        borderRadius: 20
    },
    buttonText: {
        color: '#fff',
        fontWeight: 'bold'
    },
    empty: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center'
    },
    emptyText: {
        fontSize: 18,
        color: '#888'
    }
});
