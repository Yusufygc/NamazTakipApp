import 'dates.dart';

class StreakStats {
  const StreakStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.totalFullDays,
  });

  final int currentStreak;
  final int bestStreak;
  final int totalFullDays;

  static const empty = StreakStats(currentStreak: 0, bestStreak: 0, totalFullDays: 0);
}

/// [fullDays]: beş vaktin de kılındığı günler (sırasız, tekrarsız olabilir).
/// Güncel seri; son tam gün bugün veya dünse devam eder.
StreakStats computeStreaks(Iterable<DateTime> fullDays, DateTime today) {
  final days = fullDays.map(dateOnly).toSet().toList()
    ..sort((a, b) => b.compareTo(a)); // yeniden eskiye
  if (days.isEmpty) return StreakStats.empty;

  var best = 1;
  var run = 1;
  for (var i = 0; i < days.length - 1; i++) {
    if (addDays(days[i + 1], 1) == days[i]) {
      run++;
    } else {
      run = 1;
    }
    if (run > best) best = run;
  }

  var current = 0;
  final gap = daysDiff(today, days.first);
  if (gap <= 1) {
    current = 1;
    for (var i = 0; i < days.length - 1; i++) {
      if (addDays(days[i + 1], 1) == days[i]) {
        current++;
      } else {
        break;
      }
    }
  }

  return StreakStats(
    currentStreak: current,
    bestStreak: best,
    totalFullDays: days.length,
  );
}
