import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/namaz_backend.dart';
import 'package:namaz_backend/src/data/app_database.dart';
import 'package:namaz_backend/src/data/dhikr_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('extractDhikrDraft (Instagram / Sosyal Medya Zikir Kazıyıcı)', () {
    test('Instagram reel paylaşımından Esma, hedef sayı, vakit ve bağlantıyı çıkarır', () {
      const sharedText =
          '15K likes, 210 comments - huzur_vakti on Instagram: '
          '"Sabah namazından sonra 308 defa Ya Rezzak okuyan kimse rızık darlığı çekmez inşallah. #zikir #esmaulhusna" '
          'https://www.instagram.com/reel/C9abcDEF123/';

      final draft = extractDhikrDraft(sharedText);

      expect(draft.title, 'Yâ Rezzâk');
      expect(draft.arabic, 'يَا رَزَّاقُ');
      expect(draft.targetCount, 308);
      expect(draft.prayerTime, PrayerType.fajr);
      expect(draft.groupName, DhikrGroups.rizik);
      expect(draft.sourceUrl, 'https://www.instagram.com/reel/C9abcDEF123/');
    });

    test('Yunus Peygamber duasını, 41 kez hedefini ve yatsı vaktini tanır', () {
      const sharedText =
          'Sıkıntı ve hastalık anında yatsı namazından sonra 41 kez '
          'La ilahe illa ente sübhaneke inni küntü minez zalimin okuyun.';

      final draft = extractDhikrDraft(sharedText);

      expect(draft.title, 'Yunus Peygamber Duası (Lâ İlâhe İllâ Ente)');
      expect(draft.targetCount, 41);
      expect(draft.prayerTime, PrayerType.isha);
      expect(draft.groupName, DhikrGroups.sifa);
    });

    test('Sözlükte olmayan Ya <Esma> kalıbını ve Arapça metni yakalar', () {
      const sharedText =
          'İkindi namazından sonra x100 Ya Mubarek يَا مُبَارَكُ zikri.';

      final draft = extractDhikrDraft(sharedText);

      // Mübarek, 99 Esmaül Hüsna'da değildir; genel "Ya <Esma>" kalıbı çalışır.
      expect(draft.title, 'Ya Mubarek');
      expect(draft.arabic, 'يَا مُبَارَكُ');
      expect(draft.targetCount, 100);
      expect(draft.prayerTime, PrayerType.asr);
    });
  });

  group('Hicri Takvim, Kerahat, Kıble Pusulası ve Kaza Planlayıcı', () {
    test('HijriDate.fromGregorian ve detectSpecialDay doğru çalışır', () {
      final friday = DateTime(2026, 10, 23); // Cuma
      final hijri = HijriDate.fromGregorian(friday);
      expect(hijri.year, greaterThanOrEqualTo(1448));
      expect(hijri.month, inInclusiveRange(1, 12));
      expect(hijri.day, inInclusiveRange(1, 30));
      expect(detectSpecialDay(friday, hijri), SpecialDayId.friday);
    });

    test('detectKerahat güneş doğuşu, istiva ve akşam öncesi kerahati bulur', () {
      final day = DateTime(2026, 10, 26);
      final times = DayTimes(
        date: day,
        fajr: DateTime(2026, 10, 26, 5, 45),
        sunrise: DateTime(2026, 10, 26, 7, 15),
        dhuhr: DateTime(2026, 10, 26, 12, 55),
        asr: DateTime(2026, 10, 26, 15, 50),
        maghrib: DateTime(2026, 10, 26, 18, 15),
        isha: DateTime(2026, 10, 26, 19, 35),
      );

      final israk = detectKerahat(times, DateTime(2026, 10, 26, 7, 30));
      expect(israk?.type, KerahatType.sunrise);

      final istiva = detectKerahat(times, DateTime(2026, 10, 26, 12, 30));
      expect(istiva?.type, KerahatType.istiva);

      final isfirar = detectKerahat(times, DateTime(2026, 10, 26, 17, 45));
      expect(isfirar?.type, KerahatType.sunset);

      final normal = detectKerahat(times, DateTime(2026, 10, 26, 14, 0));
      expect(normal, isNull);
    });

    test('computeQibla İstanbul için Kâbe açısını ve mesafesini hesaplar', () {
      const istanbul = AppLocation(
        latitude: 41.0082,
        longitude: 28.9784,
        city: 'İstanbul',
      );
      final qibla = computeQibla(istanbul);
      expect(qibla.bearingDegrees, closeTo(151.6, 1.5));
      expect(qibla.distanceKm, closeTo(2400, 50));
    });

    test('QazaDebtPlan toplam borcu ve tahmini bitiş tarihini hesaplar', () {
      const plan = QazaDebtPlan(
        backlogByPrayer: {
          PrayerType.fajr: 10,
          PrayerType.dhuhr: 10,
        },
        dailyTarget: 5,
      );
      expect(plan.totalBacklog, 20);
      expect(plan.grandTotal(5), 25);
      expect(plan.estimatedDaysToFinish(5), 5);
      expect(
        plan.estimatedCompletionDate(5, DateTime(2026, 10, 26)),
        DateTime(2026, 10, 31),
      );
    });

    test('buildHomeWidgetSnapshot telefon ana ekran widget verisini doğru üretir', () {
      const istanbul = AppLocation(
        latitude: 41.0082,
        longitude: 28.9784,
        city: 'İstanbul',
      );
      final day = DateTime(2026, 10, 26);
      final times = DayTimes(
        date: day,
        fajr: DateTime(2026, 10, 26, 5, 45),
        sunrise: DateTime(2026, 10, 26, 7, 15),
        dhuhr: DateTime(2026, 10, 26, 12, 55),
        asr: DateTime(2026, 10, 26, 15, 50),
        maghrib: DateTime(2026, 10, 26, 18, 15),
        isha: DateTime(2026, 10, 26, 19, 35),
      );
      final records = <PrayerType, PrayerRecord>{
        PrayerType.fajr: PrayerRecord(
          date: day,
          prayer: PrayerType.fajr,
          status: PrayerStatus.performed,
          isCongregation: false,
        ),
        PrayerType.dhuhr: PrayerRecord(
          date: day,
          prayer: PrayerType.dhuhr,
          status: PrayerStatus.performed,
          isCongregation: true,
        ),
      };

      final snapshot = buildHomeWidgetSnapshot(
        now: DateTime(2026, 10, 26, 14, 0),
        location: istanbul,
        todayTimes: times,
        upcomingDays: [times],
        todayRecords: records,
      );

      expect(snapshot, isNotNull);
      expect(snapshot!.city, 'İstanbul');
      expect(snapshot.nextPrayer, PrayerType.asr);
      expect(snapshot.nextPrayerTime, '15:50');
      expect(snapshot.completedCount, 2);
      expect(snapshot.isPerformed(PrayerType.fajr), isTrue);
      expect(snapshot.isPerformed(PrayerType.dhuhr), isTrue);
      expect(snapshot.isPerformed(PrayerType.asr), isFalse);
      expect(snapshot.toMap()['nextPrayerLabel'], 'İkindi');
    });
  });

  group('DhikrRepository (SQLite CRUD ve Zikirmatik Sayacı)', () {
    late AppDatabase db;
    late DhikrRepository repo;

    setUp(() async {
      db = await AppDatabase.openInMemory();
      repo = DhikrRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('seedDefaultsIfEmpty başlangıç zikirlerini bir kez ekler', () async {
      await repo.seedDefaultsIfEmpty();
      final first = await repo.allItems();
      expect(first.length, 6);

      await repo.seedDefaultsIfEmpty();
      final second = await repo.allItems();
      expect(second.length, 6);
    });

    test('taslak ekleme, sayaç artırma, hedef tamamlama, sıfırlama ve silme', () async {
      final created = await repo.insertDraft(
        const DhikrDraft(
          title: 'Yâ Fettâh',
          arabic: 'يَا فَتَّاحُ',
          transliteration: 'Yâ Fettâh',
          meaning: 'Hayır kapılarını açan.',
          targetCount: 3,
          groupName: DhikrGroups.rizik,
          prayerTime: PrayerType.fajr,
          sourceUrl: 'https://www.instagram.com/reel/test/',
        ),
      );

      expect(created.title, 'Yâ Fettâh');
      expect(created.currentCount, 0);
      expect(created.totalCompleted, 0);

      final step1 = await repo.incrementCount(created.id);
      expect(step1!.currentCount, 1);
      expect(step1.isCompleted, isFalse);

      await repo.incrementCount(created.id);
      final step3 = await repo.incrementCount(created.id);
      expect(step3!.currentCount, 3);
      expect(step3.isCompleted, isTrue);
      expect(step3.totalCompleted, 1);

      final reset = await repo.resetCount(created.id);
      expect(reset!.currentCount, 0);
      expect(reset.totalCompleted, 1);

      await repo.update(reset.copyWith(title: 'Yâ Fettâh (Güncel)', isFavorite: true));
      final updated = await repo.byId(created.id);
      expect(updated!.title, 'Yâ Fettâh (Güncel)');
      expect(updated.isFavorite, isTrue);

      await repo.delete(created.id);
      expect(await repo.byId(created.id), isNull);
    });
  });
}
