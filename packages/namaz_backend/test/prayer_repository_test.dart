import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_backend/src/domain/prayer.dart';
import 'package:namaz_backend/src/data/app_database.dart';
import 'package:namaz_backend/src/data/prayer_repository.dart';
import 'package:path/path.dart' as p;
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

  group('bozuk veritabanı kurtarma', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('namaz_db_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('rastgele baytlı bozuk dosyayı silmeden önce yedekler ve temiz açar',
        () async {
      final dbPath = p.join(tempDir.path, AppDatabase.fileName);
      final corruptBytes = Uint8List.fromList(
        List<int>.generate(256, (i) => (i * 73 + 19) & 0xff),
      );
      await File(dbPath).writeAsBytes(corruptBytes, flush: true);

      // Yeni yedek alınırken varsa önceki .bozuk-* yedeği silinir, yer kaplamaz.
      final oldBackup = File('$dbPath.bozuk-20260101-000000');
      await oldBackup.writeAsBytes([1, 2, 3], flush: true);

      final fixedNow = DateTime(2026, 10, 26, 21, 30, 45);
      final recovered = await AppDatabase.open(path: dbPath, now: fixedNow);
      addTearDown(recovered.close);

      final expectedBackup = '$dbPath.bozuk-20261026-213045';
      expect(recovered.corruptedBackupPath, expectedBackup);
      expect(await oldBackup.exists(), isFalse);
      expect(await File(expectedBackup).exists(), isTrue);
      expect(await File(expectedBackup).readAsBytes(), corruptBytes);

      // Yeni açılan veritabanı sağlam ve yazılabilir olmalıdır.
      final recoveredRepo = PrayerRepository(recovered);
      await recoveredRepo.markPerformed(today, PrayerType.fajr,
          congregation: true);
      final records = await recoveredRepo.recordsForDate(today);
      expect(records[PrayerType.fajr]?.status, PrayerStatus.performed);
    });

    test('SQLite başlığı geçerli ama şeması/sayfası bozuk dosyayı da yedekler',
        () async {
      final dbPath = p.join(tempDir.path, AppDatabase.fileName);
      final headerAndGarbage = Uint8List.fromList([
        ...'SQLite format 3\x00'.codeUnits,
        ...List<int>.generate(200, (i) => (i * 41 + 7) & 0xff),
      ]);
      await File(dbPath).writeAsBytes(headerAndGarbage, flush: true);

      final fixedNow = DateTime(2026, 10, 26, 21, 31, 0);
      final recovered = await AppDatabase.open(path: dbPath, now: fixedNow);
      addTearDown(recovered.close);

      final expectedBackup = '$dbPath.bozuk-20261026-213100';
      expect(recovered.corruptedBackupPath, expectedBackup);
      expect(await File(expectedBackup).readAsBytes(), headerAndGarbage);

      final recoveredRepo = PrayerRepository(recovered);
      await recoveredRepo.markMissed(today, PrayerType.isha);
      final records = await recoveredRepo.recordsForDate(today);
      expect(records[PrayerType.isha]?.status, PrayerStatus.missed);
    });

    test('sağlam veritabanı yeniden açıldığında yedeklenmez ve veriler korunur',
        () async {
      final dbPath = p.join(tempDir.path, AppDatabase.fileName);
      final first = await AppDatabase.open(path: dbPath);
      expect(first.corruptedBackupPath, isNull);
      await PrayerRepository(first).markPerformed(today, PrayerType.dhuhr);
      await first.close();

      final reopened = await AppDatabase.open(path: dbPath);
      addTearDown(reopened.close);
      expect(reopened.corruptedBackupPath, isNull);

      final backups = tempDir
          .listSync()
          .where((e) => e.path.contains('.bozuk-'))
          .toList();
      expect(backups, isEmpty);

      final records = await PrayerRepository(reopened).recordsForDate(today);
      expect(records[PrayerType.dhuhr]?.status, PrayerStatus.performed);
    });
  });
}
