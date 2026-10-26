import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:namaz_backend/namaz_backend.dart';

import '../../core/format/time_format.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../widgets/corrupted_database_card.dart';
import '../widgets/countdown_card.dart';
import '../widgets/notification_health_card.dart';
import '../widgets/prayer_card.dart';
import '../widgets/prayer_dialog.dart';
import 'city_picker_screen.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';

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
      await notifier.markPerformed(date, prayer, congregation: result.congregation);
    } else {
      await notifier.markMissed(date, prayer);
    }
  }

  String _locationText(AsyncValue<AppLocation?> refresh, AppSettings s) {
    if (s.location != null) return s.location!.label;
    return refresh.isLoading ? LocationStrings.loading : LocationStrings.notFound;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final settings = ref.watch(settingsProvider);
    final refresh = ref.watch(locationRefreshProvider);
    final times = ref.watch(todayTimesProvider);
    final records = ref.watch(todayRecordsProvider).value ?? const {};
    final day = ref.watch(trackingDayProvider);

    final failure = refresh.error is LocationException
        ? (refresh.error as LocationException).failure
        : null;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(locationRefreshProvider);
        await ref.read(locationRefreshProvider.future).catchError((_) => null);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.location, size: 18, color: p.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _locationText(refresh, settings),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const CorruptedDatabaseCard(),
          const NotificationHealthCard(),
          if (times == null)
            _NoLocationCard(failure: failure, loading: refresh.isLoading)
          else ...[
            CountdownCard(onNextChanged: (t) => setState(() => _next = t)),
            const SizedBox(height: 16),
            Text(
              HomeStrings.todaysPrayers(DateStrings.long(day)),
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                  color: p.textLight),
            ),
            const SizedBox(height: 6),
            _card(PrayerType.fajr, times, records),
            PrayerCard(
              name: PrayerStrings.sunrise,
              time: formatTime(times.sunrise),
              isDisplayOnly: true,
            ),
            _card(PrayerType.dhuhr, times, records),
            _card(PrayerType.asr, times, records),
            _card(PrayerType.maghrib, times, records),
            _card(PrayerType.isha, times, records),
          ],
        ],
      ),
    );
  }

  Widget _card(PrayerType type, DayTimes times, Map<PrayerType, PrayerRecord> records) {
    final status = records[type]?.status;
    return PrayerCard(
      name: type.label,
      time: formatTime(times.timeOf(type)),
      isPerformed: status == PrayerStatus.performed || status == PrayerStatus.compensated,
      isMissed: status == PrayerStatus.missed,
      isNext: _next == type,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (loading)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: CircularProgressIndicator(),
              ),
            Text(_message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => ref.invalidate(locationRefreshProvider),
                  icon: const Icon(AppIcons.locationDetect),
                  label: const Text(CommonStrings.retry),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const CityPickerScreen()),
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
