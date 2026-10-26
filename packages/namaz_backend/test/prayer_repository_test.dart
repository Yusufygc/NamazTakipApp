import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/src/domain/prayer.dart';
import 'package:namaz_backend/src/data/app_database.dart';
import 'package:namaz_backend/src/data/prayer_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDatabase db;
  late PrayerRepository repo;

  setUp(() async {
    db = await AppDatabase.openInMemory();
    repo = PrayerRepository(db);
  });
  tearDown(() => db.close());

  final today = DateTime(2026, 1, 10);

  test('aynı vakit tekrar işaretlenince tek kayıt kalır', () async {
    await repo.markMissed(today, PrayerType.dhuhr);
    await repo.markMissed(today, PrayerType.dhuhr);
    await repo.markMissed(today, PrayerType.dhuhr);
    final rec = await repo.recordsForDate(today);
    expect(rec.length, 1);
    final items = await repo.qazaItems(firstDay: today, today: today);
    expect(items.length, 1);
  });

  test('kılındı işareti kazadan çıkarır, kılmadım geri alınabilir', () async {
    await repo.markMissed(today, PrayerType.asr);
    await repo.markPerformed(today, PrayerType.asr, congregation: true);
    expect((await repo.qazaItems(firstDay: today, today: today)), isEmpty);
    final rec = await repo.recordsForDate(today);
    expect(rec[PrayerType.asr]!.isCongregation, isTrue);
  });

  test('bugün bekleyen vakit kaza değildir', () async {
    expect(await repo.qazaItems(firstDay: today, today: today), isEmpty);
  });

  test('işaretlenmeyen geçmiş günler otomatik kaza sayılır', () async {
    final first = DateTime(2026, 1, 8);
    final items = await repo.qazaItems(firstDay: first, today: today);
    // 8 ve 9 Ocak: 2 gün x 5 vakit
    expect(items.length, 10);
    expect(items.every((i) => i.isAutoDetected), isTrue);
    expect(items.first.date, DateTime(2026, 1, 9)); // en yeni önce
  });

  test('o gün 5 vakit kılınmışsa kaza listesinden çıkar', () async {
    final first = DateTime(2026, 1, 9);
    for (final p in PrayerType.values) {
      await repo.markPerformed(first, p);
    }
    expect(await repo.qazaItems(firstDay: first, today: today), isEmpty);
  });

  test('kaza edilen vakit listeden çıkar', () async {
    final first = DateTime(2026, 1, 9);
    await repo.markCompensated(first, PrayerType.fajr);
    final items = await repo.qazaItems(firstDay: first, today: today);
    expect(items.length, 4);
    expect(items.any((i) => i.prayer == PrayerType.fajr), isFalse);
  });

  test('dailyCounts sıfır günleri de döner ve yalnız kılınanı sayar', () async {
    await repo.markPerformed(DateTime(2026, 1, 9), PrayerType.fajr);
    await repo.markPerformed(DateTime(2026, 1, 9), PrayerType.dhuhr);
    await repo.markMissed(DateTime(2026, 1, 9), PrayerType.asr);
    final c = await repo.dailyCounts(DateTime(2026, 1, 8), DateTime(2026, 1, 10));
    expect(c.map((e) => e.performed), [0, 2, 0]);
  });

  test('fullDays yalnız 5/5 olan günleri verir', () async {
    for (final p in PrayerType.values) {
      await repo.markPerformed(DateTime(2026, 1, 9), p);
    }
    await repo.markPerformed(DateTime(2026, 1, 8), PrayerType.fajr);
    final days = await repo.fullDays();
    expect(days, [DateTime(2026, 1, 9)]);
  });

  test('performedByPrayer 5 vakti de döner', () async {
    await repo.markPerformed(today, PrayerType.fajr);
    final m = await repo.performedByPrayer(today, today);
    expect(m[PrayerType.fajr], 1);
    expect(m[PrayerType.isha], 0);
    expect(m.length, 5);
  });
}
