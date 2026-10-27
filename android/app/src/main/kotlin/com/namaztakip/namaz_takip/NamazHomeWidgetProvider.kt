package com.namaztakip.namaz_takip

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeZone

/**
 * Ana ekran widget'ı. Uygulama bir program (yedi günlük vakitler) yazar; widget
 * "sıradaki vakit", günün saatleri ve kılınma sayısını her çizimde bu programdan
 * hesaplar. Böylece uygulama açılmasa da bir vakit geçince, gün değişince ve saat
 * veya saat dilimi değişince doğru kalır. Bir sonraki vakitte AlarmManager ile
 * yenilenir.
 */
class NamazHomeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
        scheduleNextRefresh(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_REFRESH,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_BOOT_COMPLETED -> refreshAll(context)
        }
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        cancelRefresh(context)
    }

    companion object {
        private const val PREFS_NAME = "namaz_home_widget"
        const val ACTION_REFRESH = "com.namaztakip.app.WIDGET_REFRESH"

        fun saveSnapshotAndRefresh(context: Context, args: Map<*, *>) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().apply {
                putString("city", args["city"] as? String ?: "")
                putString("schedule", args["schedule"] as? String ?: "")
                // Metinler Dart'tan gelir (metin ve dil kararı ön yüzdedir).
                putString("prayerLabels", args["prayerLabels"] as? String ?: "")
                putString("sunriseLabel", args["sunriseLabel"] as? String ?: "")
                putString("nextTag", args["nextTag"] as? String ?: "")
                putString("headerTemplate", args["headerTemplate"] as? String ?: "")
                putString("doneBadges", args["doneBadges"] as? String ?: "")
                putString("doneDate", args["doneDate"] as? String ?: "")
                putInt("completedCount", (args["completedCount"] as? Number)?.toInt() ?: 0)
                // Program yoksa (eski veri) gösterilecek son bilinen değerler.
                putString("nextPrayerLabel", args["nextPrayerLabel"] as? String ?: "")
                putString("nextPrayerTime", args["nextPrayerTime"] as? String ?: "--:--")
                putString("fajrTime", args["fajrTime"] as? String ?: "--:--")
                putString("sunriseTime", args["sunriseTime"] as? String ?: "--:--")
                putString("dhuhrTime", args["dhuhrTime"] as? String ?: "--:--")
                putString("asrTime", args["asrTime"] as? String ?: "--:--")
                putString("maghribTime", args["maghribTime"] as? String ?: "--:--")
                putString("ishaTime", args["ishaTime"] as? String ?: "--:--")
                apply()
            }
            refreshAll(context)
        }

        fun refreshAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, NamazHomeWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            if (ids == null || ids.isEmpty()) {
                cancelRefresh(context)
                return
            }
            for (id in ids) {
                updateAppWidget(context, manager, id)
            }
            scheduleNextRefresh(context)
        }

        fun requestPin(context: Context): Boolean {
            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
            val manager = AppWidgetManager.getInstance(context)
            if (!manager.isRequestPinAppWidgetSupported) return false
            val provider = ComponentName(context, NamazHomeWidgetProvider::class.java)
            return manager.requestPinAppWidget(provider, null, null)
        }

        private fun refreshIntent(context: Context): PendingIntent {
            val intent = Intent(context, NamazHomeWidgetProvider::class.java).apply {
                action = ACTION_REFRESH
            }
            return PendingIntent.getBroadcast(
                context,
                1,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        }

        private fun cancelRefresh(context: Context) {
            val alarms = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            alarms?.cancel(refreshIntent(context))
        }

        /** Sıradaki vakitte veya gece yarısında (hangisi önceyse) widget'ı yeniler. */
        private fun scheduleNextRefresh(context: Context) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val days = WidgetSchedule.parse(prefs.getString("schedule", ""))
            val state = WidgetSchedule.compute(System.currentTimeMillis(), days, TimeZone.getDefault())
            val alarms = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
            // Tam zamanlı alarm izni gerekmeyen, Doze'da da çalışan yaklaşık alarm.
            alarms.setAndAllowWhileIdle(
                AlarmManager.RTC,
                state.nextRefreshMs + 1000L,
                refreshIntent(context)
            )
        }

        private fun formatHm(ms: Long, tz: TimeZone): String {
            val fmt = SimpleDateFormat("HH:mm", Locale.US)
            fmt.timeZone = tz
            return fmt.format(ms)
        }

        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val tz = TimeZone.getDefault()
            val city = prefs.getString("city", "") ?: ""
            // Vakit adları, başlık şablonu ve rozetler Dart'tan gelir; Kotlin metin üretmez.
            val labels = (prefs.getString("prayerLabels", "") ?: "").split('\n')
            val doneBadges = (prefs.getString("doneBadges", "") ?: "").split('\n')
            val headerTemplate = prefs.getString("headerTemplate", "") ?: ""
            val days = WidgetSchedule.parse(prefs.getString("schedule", ""))

            val nextName: String
            val nextTime: String
            val fajr: String
            val sunrise: String
            val dhuhr: String
            val asr: String
            val maghrib: String
            val isha: String
            var done = 0

            if (days.isNotEmpty()) {
                val state = WidgetSchedule.compute(System.currentTimeMillis(), days, tz)
                nextName = if (state.nextIndex >= 0) labels.getOrElse(state.nextIndex) { "" } else "--"
                nextTime = if (state.nextIndex >= 0) formatHm(state.nextTimeMs, tz) else "--:--"
                val today = state.today
                fajr = today?.let { formatHm(it.fajr, tz) } ?: "--:--"
                sunrise = today?.let { formatHm(it.sunrise, tz) } ?: "--:--"
                dhuhr = today?.let { formatHm(it.dhuhr, tz) } ?: "--:--"
                asr = today?.let { formatHm(it.asr, tz) } ?: "--:--"
                maghrib = today?.let { formatHm(it.maghrib, tz) } ?: "--:--"
                isha = today?.let { formatHm(it.isha, tz) } ?: "--:--"
                // Kılınma sayısı yalnızca ait olduğu takip günü için geçerlidir.
                if (prefs.getString("doneDate", "") == state.trackingDateKey) {
                    done = prefs.getInt("completedCount", 0)
                }
            } else {
                nextName = prefs.getString("nextPrayerLabel", "") ?: ""
                nextTime = prefs.getString("nextPrayerTime", "--:--") ?: "--:--"
                fajr = prefs.getString("fajrTime", "--:--") ?: "--:--"
                sunrise = prefs.getString("sunriseTime", "--:--") ?: "--:--"
                dhuhr = prefs.getString("dhuhrTime", "--:--") ?: "--:--"
                asr = prefs.getString("asrTime", "--:--") ?: "--:--"
                maghrib = prefs.getString("maghribTime", "--:--") ?: "--:--"
                isha = prefs.getString("ishaTime", "--:--") ?: "--:--"
                done = prefs.getInt("completedCount", 0)
            }

            val views = RemoteViews(context.packageName, R.layout.namaz_home_widget)
            views.setTextViewText(R.id.widget_city, headerTemplate.replace("{city}", city))
            views.setTextViewText(R.id.widget_done_badge, doneBadges.getOrElse(done) { "" })
            views.setTextViewText(R.id.widget_next_tag, prefs.getString("nextTag", "") ?: "")
            views.setTextViewText(R.id.widget_label_fajr, labels.getOrElse(0) { "" })
            views.setTextViewText(R.id.widget_label_sunrise, prefs.getString("sunriseLabel", "") ?: "")
            views.setTextViewText(R.id.widget_label_dhuhr, labels.getOrElse(1) { "" })
            views.setTextViewText(R.id.widget_label_asr, labels.getOrElse(2) { "" })
            views.setTextViewText(R.id.widget_label_maghrib, labels.getOrElse(3) { "" })
            views.setTextViewText(R.id.widget_label_isha, labels.getOrElse(4) { "" })
            views.setTextViewText(R.id.widget_next_name, nextName)
            views.setTextViewText(R.id.widget_next_time, nextTime)
            views.setTextViewText(R.id.widget_time_fajr, fajr)
            views.setTextViewText(R.id.widget_time_sunrise, sunrise)
            views.setTextViewText(R.id.widget_time_dhuhr, dhuhr)
            views.setTextViewText(R.id.widget_time_asr, asr)
            views.setTextViewText(R.id.widget_time_maghrib, maghrib)
            views.setTextViewText(R.id.widget_time_isha, isha)

            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
