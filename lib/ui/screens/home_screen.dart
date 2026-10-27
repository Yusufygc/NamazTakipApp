import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/format/time_format.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../widgets/classic_tesbihat_sheet.dart';
import '../widgets/corrupted_database_card.dart';
import '../widgets/countdown_card.dart';
import '../widgets/islamic_pattern.dart';
import '../widgets/notification_health_card.dart';
import '../widgets/prayer_card.dart';
import '../widgets/prayer_dialog.dart';
import 'city_picker_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  StreamSubscription<PrayerPrompt>? _promptSub;
  PrayerType? _next;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final backend = ref.read(backendProvider);
    _promptSub = backend.notificationPrompts.listen(_askPrompt);
    final launch = backend.takeLaunchPrompt();
    if (launch != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _askPrompt(launch));
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestPermissions());
  }

  /// Önce konum, sonra bildirim izni: iki sistem penceresi çakışmasın.
  Future<void> _requestPermissions() async {
    try {
      await ref.read(locationRefreshProvider.future);
    } catch (_) {
      // Konum verilmediyse ana ekran kendi mesajını gösterir.
    }
    if (!mounted) return;
    if (ref.read(settingsProvider).notificationsEnabled) {
      final backend = ref.read(backendProvider);
      await backend.requestNotificationPermission();
      if (mounted) await backend.rescheduleNotifications();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _promptSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(trackingDayProvider.notifier).sync();
      ref.invalidate(locationRefreshProvider);
      ref.invalidate(todayRecordsProvider);
      ref.invalidate(notificationHealthProvider);
    }
  }

  Future<void> _askPrompt(PrayerPrompt prompt) async {
    if (!mounted) return;
    await _ask(prompt.prayer, prompt.date);
  }

  Future<void> _ask(PrayerType prayer, DateTime date) async {
    final result = await showPrayerDialog(context, prayer: prayer, date: date);
    if (result == null || !mounted) return;
    final notifier = ref.read(todayRecordsProvider.notifier);
    if (result.answer == PrayerAnswer.performed) {
      await notifier.markPerformed(
        date,
        prayer,
        congregation: result.congregation,
      );
      if (mounted) _suggestPostPrayerDhikr(prayer);
    } else {
      await notifier.markMissed(date, prayer);
    }
  }

  void _suggestPostPrayerDhikr(PrayerType prayer) {
    final dhikrs = ref.read(dhikrProvider).value;
    if (dhikrs == null || dhikrs.isEmpty) return;
    final match = dhikrs.firstWhere(
      (d) => d.prayerTime == prayer,
      orElse: () => dhikrs.firstWhere(
        (d) => d.groupName == DhikrGroups.prayerTesbihat,
        orElse: () => dhikrs.first,
      ),
    );
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        content: Text(DhikrStrings.postPrayerPrompt(prayer.label, match.title)),
        action: SnackBarAction(
          label: DhikrStrings.postPrayerAction,
          onPressed: () {
            if (mounted) showClassicTesbihatSheet(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final refresh = ref.watch(locationRefreshProvider);
    final times = ref.watch(todayTimesProvider);
    final records = ref.watch(todayRecordsProvider).value ?? const {};
    final day = ref.watch(trackingDayProvider);

    final failure = refresh.error is LocationException
        ? (refresh.error as LocationException).failure
        : null;

    final hasBanner = ref.watch(corruptedDbBackupProvider) != null ||
        (ref.watch(settingsProvider.select((s) => s.notificationsEnabled)) &&
            ref.watch(notificationHealthProvider).value?.isHealthy == false);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(locationRefreshProvider);
        await ref.read(locationRefreshProvider.future).catchError((_) => null);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Uyarı kartı yokken ve normal ekran yüksekliğinde tüm bileşenler
          // kaydırma gerektirmeden tam ekrana yayılır.
          final fitScreen =
              times != null && !hasBanner && constraints.maxHeight >= 560;
          if (!fitScreen) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const CorruptedDatabaseCard(),
                const NotificationHealthCard(),
                if (times == null)
                  _NoLocationCard(failure: failure, loading: refresh.isLoading)
                else ...[
                  CountdownCard(onNextChanged: (t) => setState(() => _next = t)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(
                      HomeStrings.todaysPrayers(DateStrings.long(day)),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: p.textLight,
                      ),
                    ),
                  ),
                  _card(PrayerType.fajr, times, records, isFirst: true),
                  PrayerCard(
                    name: PrayerStrings.sunrise,
                    time: formatTime(times.sunrise),
                    isDisplayOnly: true,
                  ),
                  _card(PrayerType.dhuhr, times, records),
                  _card(PrayerType.asr, times, records),
                  _card(PrayerType.maghrib, times, records),
                  _card(PrayerType.isha, times, records, isLast: true),
                ],
              ],
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: math.max(constraints.maxHeight, 560),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CountdownCard(
                      onNextChanged: (t) => setState(() => _next = t),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Text(
                        HomeStrings.todaysPrayers(DateStrings.long(day)),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: p.textLight,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _card(
                        PrayerType.fajr,
                        times,
                        records,
                        isFirst: true,
                      ),
                    ),
                    Expanded(
                      child: PrayerCard(
                        name: PrayerStrings.sunrise,
                        time: formatTime(times.sunrise),
                        isDisplayOnly: true,
                      ),
                    ),
                    Expanded(
                      child: _card(PrayerType.dhuhr, times, records),
                    ),
                    Expanded(
                      child: _card(PrayerType.asr, times, records),
                    ),
                    Expanded(
                      child: _card(PrayerType.maghrib, times, records),
                    ),
                    Expanded(
                      child: _card(
                        PrayerType.isha,
                        times,
                        records,
                        isLast: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _card(
    PrayerType type,
    DayTimes times,
    Map<PrayerType, PrayerRecord> records, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    final rec = records[type];
    final status = rec?.status;
    return PrayerCard(
      name: type.label,
      time: formatTime(times.timeOf(type)),
      prayerType: type,
      isPerformed:
          status == PrayerStatus.performed || status == PrayerStatus.compensated,
      isMissed: status == PrayerStatus.missed,
      isCongregation: rec?.isCongregation ?? false,
      isNext: _next == type,
      isFirst: isFirst,
      isLast: isLast,
      onTap: () => _ask(type, ref.read(trackingDayProvider)),
    );
  }
}

class _NoLocationCard extends ConsumerWidget {
  const _NoLocationCard({required this.failure, required this.loading});

  final LocationFailure? failure;
  final bool loading;

  String get _message {
    switch (failure) {
      case LocationFailure.serviceDisabled:
        return LocationStrings.serviceDisabled;
      case LocationFailure.denied:
        return LocationStrings.denied;
      case LocationFailure.deniedForever:
        return LocationStrings.deniedForever;
      case LocationFailure.unavailable:
        return LocationStrings.unavailable;
      case null:
        return LocationStrings.needed;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    return Card(
      color: p.card,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SeljukMedallion(
              size: 64,
              fillColor: p.primary.withValues(alpha: 0.12),
              borderColor: p.secondary,
              child: loading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: p.primary,
                      ),
                    )
                  : Icon(AppIcons.location, size: 28, color: p.primary),
            ),
            const SizedBox(height: 16),
            Text(
              loading ? LocationStrings.loading : LocationStrings.notFound,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(color: p.textLight),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => ref.invalidate(locationRefreshProvider),
                  icon: const Icon(AppIcons.locationDetect),
                  label: const Text(CommonStrings.retry),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CityPickerScreen(),
                    ),
                  ),
                  icon: const Icon(AppIcons.city),
                  label: const Text(LocationStrings.chooseCity),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
