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
          'İkindi namazından sonra x100 Ya Kerim يَا كَرِيمُ zikri.';

      final draft = extractDhikrDraft(sharedText);

      expect(draft.title, 'Ya Kerim');
      expect(draft.arabic, 'يَا كَرِيمُ');
      expect(draft.targetCount, 100);
      expect(draft.prayerTime, PrayerType.asr);
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
