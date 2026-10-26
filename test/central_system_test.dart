import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:namaz_takip/core/achievements.dart';
import 'package:namaz_takip/core/app_theme.dart';
import 'package:namaz_takip/core/icons/app_icons.dart';
import 'package:namaz_takip/core/prayer.dart';
import 'package:namaz_takip/core/strings/strings.dart';
import 'package:namaz_takip/core/text_utils.dart';
import 'package:namaz_takip/services/prayer_time_service.dart';

/// Emoji ve sembol aralıkları (ikon sistemi bunların yerine geçti).
final _emoji = RegExp('[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B50}\u{2B1B}\u{FE0F}]',
    unicode: true);

List<File> _dartFiles(String dir) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

void main() {
  group('turkishUpper', () {
    test('i/ı Türkçe kurallarına göre büyür', () {
      expect(turkishUpper('İkindi'), 'İKİNDİ');
      expect(turkishUpper('Yatsı'), 'YATSI');
      expect(turkishUpper('Öğle'), 'ÖĞLE');
      expect(turkishUpper('Akşam'), 'AKŞAM');
      expect(turkishUpper('Sabah'), 'SABAH');
    });
    test('diyalog başlığı İkindi için doğru', () {
      expect(PrayerDialogStrings.title(PrayerType.asr.label), 'İKİNDİ NAMAZINI');
    });
  });

  group('foldTurkish', () {
    test('Türkçe harf ve büyük/küçük farkını yok sayar', () {
      expect(foldTurkish('İstanbul'), foldTurkish('istanbul'));
      expect(foldTurkish('Şanlıurfa'), 'sanliurfa');
      expect(foldTurkish('IĞDIR'), 'igdir');
      expect(foldTurkish('Çanakkale').contains(foldTurkish('cana')), isTrue);
    });
  });

  group('metin sistemi', () {
    test('her vaktin, yöntemin ve rozetin metni dolu', () {
      for (final t in PrayerType.values) {
        expect(t.label.trim(), isNotEmpty);
      }
      for (final m in CalcMethod.values) {
        expect(m.label.trim(), isNotEmpty);
      }
      for (final id in AchievementId.values) {
        expect(GamificationStrings.achievementTitle(id).trim(), isNotEmpty);
        expect(GamificationStrings.achievementDescription(id).trim(), isNotEmpty);
      }
      for (final t in kThemes) {
        expect(SettingsStrings.themeName(t.key).trim(), isNotEmpty);
      }
    });

    test('vakit adları beklenen Türkçe karşılıklar', () {
      expect(PrayerType.values.map((t) => t.label),
          ['Sabah', 'Öğle', 'İkindi', 'Akşam', 'Yatsı']);
    });

    test('tarih biçimleri', () {
      expect(DateStrings.long(DateTime(2026, 1, 5)), '5 Ocak 2026');
      expect(DateStrings.monthAndYear(DateTime(2026, 12, 1)), 'Aralık 2026');
      expect(DateStrings.short(DateTime(2026, 3, 9)), '9/3');
      expect(DateStrings.months.length, 12);
      expect(DateStrings.weekdaysShort.length, 7);
    });

    test('parametreli metinler', () {
      expect(QazaStrings.summary(3, 2), 'Toplam 3 kaza namazı • 2 gün');
      expect(StatsStrings.progressValue(2), '+2 Vakit');
      expect(StatsStrings.progressValue(-1), '-1 Vakit');
      expect(StatsStrings.progressValue(0), '0 Vakit');
      expect(NotificationStrings.adhanTitle('Yatsı'), 'Yatsı Vakti');
    });

    test('bildirim metinlerinde emoji yok', () {
      final samples = [
        NotificationStrings.adhanTitle('Sabah'),
        NotificationStrings.adhanBody('Sabah'),
        NotificationStrings.adhanAskBody('Sabah', 'Yatsı'),
        NotificationStrings.reminderTitle('Sabah'),
        NotificationStrings.reminderBody,
      ];
      for (final s in samples) {
        expect(_emoji.hasMatch(s), isFalse, reason: s);
      }
    });
  });

  group('ikon sistemi', () {
    test('her rozet ve tema için ikon var', () {
      for (final id in AchievementId.values) {
        expect(AppIcons.achievement(id).codePoint, greaterThan(0));
      }
      for (final t in kThemes) {
        expect(AppIcons.theme(t.key).codePoint, greaterThan(0));
      }
    });
  });

  group('merkezileştirme kuralları', () {
    test('lib içinde emoji kullanılmaz', () {
      final offenders = <String>[];
      for (final f in _dartFiles('lib')) {
        if (_emoji.hasMatch(f.readAsStringSync())) offenders.add(f.path);
      }
      expect(offenders, isEmpty, reason: 'Emoji yerine AppIcons kullanın: $offenders');
    });

    test('Icons.xxx yalnızca app_icons.dart içinde geçer', () {
      final offenders = <String>[];
      final usage = RegExp(r'\bIcons\.[a-z]');
      for (final f in _dartFiles('lib')) {
        final p = f.path.replaceAll('\\', '/');
        if (p.endsWith('core/icons/app_icons.dart')) continue;
        if (usage.hasMatch(f.readAsStringSync())) offenders.add(p);
      }
      expect(offenders, isEmpty, reason: 'AppIcons üzerinden kullanın: $offenders');
    });

    test('ui katmanında Türkçe sabit metin kalmaz', () {
      // Türkçe harf içeren tek tırnaklı sabitler yalnızca strings modülünde olmalı.
      final turkish = RegExp(r"'[^'\n]*[ÇĞİÖŞÜçğıöşü][^'\n]*'");
      final offenders = <String>[];
      for (final f in _dartFiles('lib/ui')) {
        final p = f.path.replaceAll('\\', '/');
        for (final line in f.readAsLinesSync()) {
          final t = line.trim();
          if (t.startsWith('//') || t.startsWith('///')) continue;
          if (turkish.hasMatch(line)) offenders.add('$p: $t');
        }
      }
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });
  });
}
