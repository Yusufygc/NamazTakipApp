import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useTheme } from '../../context/ThemeContext';

const Section = ({ icon, title, children, colors }) => {
    const styles = getStyles(colors);
    return (
        <View style={styles.section}>
            <View style={styles.sectionHeader}>
                <Text style={styles.sectionIcon}>{icon}</Text>
                <Text style={styles.sectionTitle}>{title}</Text>
            </View>
            <View style={styles.sectionContent}>
                {children}
            </View>
        </View>
    );
};

const FeatureItem = ({ emoji, title, description, colors }) => {
    const styles = getStyles(colors);
    return (
        <View style={styles.featureItem}>
            <Text style={styles.featureEmoji}>{emoji}</Text>
            <View style={styles.featureTextContainer}>
                <Text style={styles.featureTitle}>{title}</Text>
                <Text style={styles.featureDescription}>{description}</Text>
            </View>
        </View>
    );
};

const Step = ({ number, text, colors }) => {
    const styles = getStyles(colors);
    return (
        <View style={styles.stepItem}>
            <View style={styles.stepBadge}>
                <Text style={styles.stepNumber}>{number}</Text>
            </View>
            <Text style={styles.stepText}>{text}</Text>
        </View>
    );
};

export default function AboutScreen() {
    const { colors } = useTheme();
    const styles = getStyles(colors);

    return (
        <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
            {/* App Header */}
            <View style={styles.appHeader}>
                <Text style={styles.appIcon}>🕌</Text>
                <Text style={styles.appName}>Namaz Takip</Text>
                <Text style={styles.appVersion}>Versiyon 1.0.0</Text>
                <Text style={styles.appTagline}>Günlük namazlarınızı kolayca takip edin</Text>
            </View>

            {/* Uygulama Hakkında */}
            <Section icon="📖" title="Uygulama Hakkında" colors={colors}>
                <Text style={styles.paragraph}>
                    Namaz Takip, günlük beş vakit namazınızı kolayca takip etmenizi sağlayan bir uygulamadır.
                    Konumunuza göre otomatik namaz vakitleri hesaplanır, namazlarınızı kılıp kılmadığınızı
                    kayıt altına alabilir, kaza namazlarınızı takip edebilir ve istatistiklerinizi
                    görsel grafiklerle inceleyebilirsiniz.
                </Text>
            </Section>

            {/* Özellikler */}
            <Section icon="⭐" title="Özellikler" colors={colors}>
                <FeatureItem
                    emoji="⏰"
                    title="Otomatik Namaz Vakitleri"
                    description="Konumunuza göre günlük namaz vakitleri otomatik olarak hesaplanır ve gösterilir. Diyanet hesaplama yöntemini kullanır."
                    colors={colors}
                />
                <FeatureItem
                    emoji="⏳"
                    title="Geri Sayım Sayacı"
                    description="Bir sonraki namaz vaktine kalan süreyi anlık olarak gösterir. Vakit girdiğinde otomatik güncellenir."
                    colors={colors}
                />
                <FeatureItem
                    emoji="✅"
                    title="Namaz Takibi"
                    description="Her namaz için kıldınız mı, cemaatle mi kıldınız yoksa kaçırdınız mı kaydedebilirsiniz."
                    colors={colors}
                />
                <FeatureItem
                    emoji="📋"
                    title="Kaza Namazı Takibi"
                    description="Kaçırdığınız namazlar otomatik olarak kaza listesine eklenir. Kaza ettiğinizde işaretleyebilirsiniz."
                    colors={colors}
                />
                <FeatureItem
                    emoji="🔥"
                    title="Seri Takibi & Rozetler"
                    description="Kesintisiz namaz kılma serinizi takip edin. Belirli hedeflere ulaştığınızda rozetler kazanın."
                    colors={colors}
                />
                <FeatureItem
                    emoji="📊"
                    title="İstatistikler"
                    description="Haftalık ve aylık performansınızı grafiklerle görüntüleyin. Geçen haftayla karşılaştırma yapın."
                    colors={colors}
                />
                <FeatureItem
                    emoji="🗓️"
                    title="Isı Haritası"
                    description="Aylık takvim görünümünde hangi günler kaç namaz kıldığınızı renk kodlarıyla görün."
                    colors={colors}
                />
                <FeatureItem
                    emoji="🕸️"
                    title="Radar Grafiği"
                    description="Her namaz vakti için kılma oranınızı radar grafiğinde görselleştirin. Hangi vakit güçlü, hangisinde gelişme gerekiyor anında görün."
                    colors={colors}
                />
                <FeatureItem
                    emoji="🔔"
                    title="Bildirimler"
                    description="Namaz vakitlerinde hatırlatma bildirimi alın. Ayarlardan açıp kapatabilirsiniz."
                    colors={colors}
                />
                <FeatureItem
                    emoji="🎨"
                    title="Tema Seçenekleri"
                    description="5 farklı tema arasından seçim yapın: Varsayılan, Koyu, Okyanus, Gül Kurusu ve Altın. Seçiminiz otomatik kaydedilir."
                    colors={colors}
                />
            </Section>

            {/* Nasıl Kullanılır */}
            <Section icon="📱" title="Nasıl Kullanılır?" colors={colors}>
                <Text style={styles.subHeading}>Ana Ekran</Text>
                <Step number="1" text="Uygulama açıldığında konumunuz otomatik algılanır ve günün namaz vakitleri hesaplanır." colors={colors} />
                <Step number="2" text="Bir sonraki namaz vaktine geri sayım sayacı gösterilir." colors={colors} />
                <Step number="3" text="Her namaz kartına dokunarak namazı kıldığınızı veya kaçırdığınızı belirtin." colors={colors} />
                <Step number="4" text="Cemaatle kılma seçeneğini de işaretleyebilirsiniz." colors={colors} />

                <Text style={[styles.subHeading, { marginTop: 20 }]}>Kaza Namazları</Text>
                <Step number="1" text="Kaçırdığınız namazlar otomatik olarak 'Kaza Namazları' sayfasına eklenir." colors={colors} />
                <Step number="2" text="Tarihe göre gruplandırılmış kaza listesini görebilirsiniz." colors={colors} />
                <Step number="3" text="Bir kaza namazını kıldığınızda 'Kaza Et' butonuna basarak işaretleyin." colors={colors} />

                <Text style={[styles.subHeading, { marginTop: 20 }]}>İstatistikler</Text>
                <Step number="1" text="Sol menüden 'İstatistikler' sekmesine gidin." colors={colors} />
                <Step number="2" text="Performans: Radar grafiğiyle her vakit için kılma oranınızı görün." colors={colors} />
                <Step number="3" text="Isı Haritası: Aylık takvimde hangi günler ne kadar namaz kıldığınızı kontrol edin." colors={colors} />
                <Step number="4" text="Karşılaştırma: Bu hafta ile geçen haftanızı karşılaştırın ve gelişiminizi takip edin." colors={colors} />

                <Text style={[styles.subHeading, { marginTop: 20 }]}>Rozetler & Seri</Text>
                <Step number="1" text="Her gün tüm namazlarınızı kılarak kesintisiz seri oluşturun." colors={colors} />
                <Step number="2" text="Belirli hedeflere ulaştığınızda rozetler kazanın (örn: 7 günlük seri, 30 günlük seri)." colors={colors} />

                <Text style={[styles.subHeading, { marginTop: 20 }]}>Tema Değiştirme</Text>
                <Step number="1" text="Sol menüden 'Ayarlar' sayfasına gidin." colors={colors} />
                <Step number="2" text="Tema Seçimi bölümünden istediğiniz temaya dokunun." colors={colors} />
                <Step number="3" text="Tema anında uygulanır ve otomatik kaydedilir." colors={colors} />
            </Section>

            {/* İpuçları */}
            <Section icon="💡" title="İpuçları" colors={colors}>
                <View style={styles.tipCard}>
                    <Text style={styles.tipText}>📌 Ana ekranı aşağı çekerek namaz vakitlerini yenileyebilirsiniz.</Text>
                </View>
                <View style={styles.tipCard}>
                    <Text style={styles.tipText}>📌 Güneş vakti bilgi amaçlıdır, dokunarak işaretleyemezsiniz.</Text>
                </View>
                <View style={styles.tipCard}>
                    <Text style={styles.tipText}>📌 Bildirimleri Ayarlar'dan açarak namaz vakitlerinde hatırlatma alabilirsiniz.</Text>
                </View>
                <View style={styles.tipCard}>
                    <Text style={styles.tipText}>📌 Isı haritasında ay değiştirmek için ok butonlarını kullanın.</Text>
                </View>
            </Section>

            {/* Footer */}
            <View style={styles.footer}>
                <Text style={styles.footerText}>Geliştirici: MYY</Text>
                <Text style={styles.footerText}>Namaz Takip © 2026</Text>
                <Text style={styles.footerDua}>🤲 Allah kabul etsin</Text>
            </View>
        </ScrollView>
    );
}

const getStyles = (colors) => StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: colors.background,
    },
    appHeader: {
        backgroundColor: colors.primary,
        paddingTop: 30,
        paddingBottom: 30,
        alignItems: 'center',
        borderBottomLeftRadius: 30,
        borderBottomRightRadius: 30,
        elevation: 5,
        shadowColor: colors.dark,
        shadowOffset: { width: 0, height: 4 },
        shadowOpacity: 0.3,
        shadowRadius: 8,
    },
    appIcon: {
        fontSize: 50,
        marginBottom: 10,
    },
    appName: {
        fontSize: 28,
        fontWeight: 'bold',
        color: colors.white,
    },
    appVersion: {
        fontSize: 14,
        color: colors.white + 'CC',
        marginTop: 4,
    },
    appTagline: {
        fontSize: 15,
        color: colors.white + 'DD',
        marginTop: 8,
        fontStyle: 'italic',
    },
    section: {
        marginHorizontal: 16,
        marginTop: 20,
        backgroundColor: colors.white,
        borderRadius: 16,
        padding: 16,
        elevation: 2,
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 1 },
        shadowOpacity: 0.1,
        shadowRadius: 3,
    },
    sectionHeader: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 12,
        borderBottomWidth: 1,
        borderBottomColor: colors.dark + '15',
        paddingBottom: 10,
    },
    sectionIcon: {
        fontSize: 22,
        marginRight: 10,
    },
    sectionTitle: {
        fontSize: 20,
        fontWeight: 'bold',
        color: colors.primary,
    },
    sectionContent: {},
    paragraph: {
        fontSize: 15,
        color: colors.text,
        lineHeight: 24,
    },
    subHeading: {
        fontSize: 16,
        fontWeight: 'bold',
        color: colors.dark,
        marginBottom: 10,
        marginTop: 5,
    },
    featureItem: {
        flexDirection: 'row',
        alignItems: 'flex-start',
        marginBottom: 14,
    },
    featureEmoji: {
        fontSize: 24,
        marginRight: 12,
        marginTop: 2,
    },
    featureTextContainer: {
        flex: 1,
    },
    featureTitle: {
        fontSize: 16,
        fontWeight: '600',
        color: colors.text,
        marginBottom: 2,
    },
    featureDescription: {
        fontSize: 13,
        color: colors.textLight,
        lineHeight: 20,
    },
    stepItem: {
        flexDirection: 'row',
        alignItems: 'flex-start',
        marginBottom: 12,
    },
    stepBadge: {
        width: 28,
        height: 28,
        borderRadius: 14,
        backgroundColor: colors.primary,
        justifyContent: 'center',
        alignItems: 'center',
        marginRight: 12,
        marginTop: 1,
    },
    stepNumber: {
        color: colors.white,
        fontWeight: 'bold',
        fontSize: 14,
    },
    stepText: {
        flex: 1,
        fontSize: 14,
        color: colors.text,
        lineHeight: 22,
    },
    tipCard: {
        backgroundColor: colors.accent + '60',
        borderRadius: 10,
        padding: 12,
        marginBottom: 8,
    },
    tipText: {
        fontSize: 14,
        color: colors.text,
        lineHeight: 20,
    },
    footer: {
        alignItems: 'center',
        marginVertical: 30,
        paddingTop: 20,
    },
    footerText: {
        fontSize: 13,
        color: colors.textLight,
        marginBottom: 4,
    },
    footerDua: {
        fontSize: 16,
        color: colors.primary,
        marginTop: 10,
        fontWeight: '600',
    },
});
