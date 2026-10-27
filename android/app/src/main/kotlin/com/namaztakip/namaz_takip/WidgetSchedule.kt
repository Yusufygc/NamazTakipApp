package com.namaztakip.namaz_takip

import java.util.Calendar
import java.util.TimeZone

/** Bir günün vakitleri (epoch milisaniye). */
class DaySchedule(
    val fajr: Long,
    val sunrise: Long,
    val dhuhr: Long,
    val asr: Long,
    val maghrib: Long,
    val isha: Long,
) {
    /** Güneş hariç beş vakit, Sabah..Yatsı sırasıyla. */
    val prayers: LongArray get() = longArrayOf(fajr, dhuhr, asr, maghrib, isha)
}

/** Widget'ın o anda göstereceği durum. */
class WidgetState(
    /** Sıradaki vakit: 0 Sabah .. 4 Yatsı; programda yoksa -1. */
    val nextIndex: Int,
    val nextTimeMs: Long,
    /** Takvim bugününün vakitleri; programda yoksa null. */
    val today: DaySchedule?,
    /** Bugünkü kılınma sayısının ait olduğu takip günü (`yyyy-MM-dd`). */
    val trackingDateKey: String,
    /** Widget'ın bir sonraki kendiliğinden yenileneceği an (epoch ms). */
    val nextRefreshMs: Long,
)

/**
 * Widget'ın gün programı mantığı. Android API'sine bağlı değildir, böylece birim
 * testle denenebilir. Uygulama açılmasa da "sıradaki vakit" doğru kalsın diye
 * widget, saklanan program üzerinden kendisi hesaplar.
 */
object WidgetSchedule {
    val LABELS = arrayOf("Sabah", "Öğle", "İkindi", "Akşam", "Yatsı")

    /** Dart'ın gönderdiği `schedule` metnini ayrıştırır; bozuk satırlar atlanır. */
    fun parse(raw: String?): List<DaySchedule> {
        if (raw.isNullOrBlank()) return emptyList()
        return raw.lines().mapNotNull { line ->
            val parts = line.trim().split(',').mapNotNull { it.trim().toLongOrNull() }
            if (parts.size == 6) {
                DaySchedule(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5])
            } else {
                null
            }
        }
    }

    fun dateKey(ms: Long, tz: TimeZone): String {
        val c = Calendar.getInstance(tz).apply { timeInMillis = ms }
        return "%04d-%02d-%02d".format(
            c.get(Calendar.YEAR),
            c.get(Calendar.MONTH) + 1,
            c.get(Calendar.DAY_OF_MONTH),
        )
    }

    fun compute(nowMs: Long, days: List<DaySchedule>, tz: TimeZone): WidgetState {
        val todayKey = dateKey(nowMs, tz)
        val today = days.firstOrNull { dateKey(it.fajr, tz) == todayKey }

        var nextIndex = -1
        var nextTime = Long.MAX_VALUE
        for (day in days.sortedBy { it.fajr }) {
            val times = day.prayers
            for (i in times.indices) {
                if (times[i] > nowMs && times[i] < nextTime) {
                    nextIndex = i
                    nextTime = times[i]
                }
            }
        }

        // Takip günü: gün sınırı `min(04:00, Sabah)`; sınırdan önce hâlâ dünkü gün.
        val cal = Calendar.getInstance(tz).apply { timeInMillis = nowMs }
        cal.set(Calendar.HOUR_OF_DAY, 4)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        var boundary = cal.timeInMillis
        if (today != null && today.fajr < boundary) boundary = today.fajr
        val trackingKey = if (nowMs < boundary) {
            val yesterday = Calendar.getInstance(tz).apply {
                timeInMillis = nowMs
                add(Calendar.DAY_OF_MONTH, -1)
            }
            dateKey(yesterday.timeInMillis, tz)
        } else {
            todayKey
        }

        // Bir sonraki yenileme: sıradaki vakit veya gece yarısı, hangisi önceyse.
        val midnight = Calendar.getInstance(tz).apply {
            timeInMillis = nowMs
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            add(Calendar.DAY_OF_MONTH, 1)
        }.timeInMillis
        val nextRefresh = if (nextIndex >= 0) minOf(nextTime, midnight) else midnight

        return WidgetState(
            nextIndex = nextIndex,
            nextTimeMs = if (nextIndex >= 0) nextTime else 0L,
            today = today,
            trackingDateKey = trackingKey,
            nextRefreshMs = nextRefresh,
        )
    }
}
