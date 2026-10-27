package com.namaztakip.namaz_takip

import java.util.Calendar
import java.util.TimeZone
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class WidgetScheduleTest {
    private val tz = TimeZone.getTimeZone("Europe/Istanbul")

    private fun at(y: Int, m: Int, d: Int, h: Int, min: Int): Long =
        Calendar.getInstance(tz).apply {
            clear()
            set(y, m - 1, d, h, min, 0)
        }.timeInMillis

    /** İstanbul, 26-28 Ekim 2026 yaklaşık vakitleri. */
    private fun day(d: Int) = DaySchedule(
        fajr = at(2026, 10, d, 5, 45),
        sunrise = at(2026, 10, d, 7, 15),
        dhuhr = at(2026, 10, d, 12, 55),
        asr = at(2026, 10, d, 15, 50),
        maghrib = at(2026, 10, d, 18, 15),
        isha = at(2026, 10, d, 19, 35),
    )

    private val days = listOf(day(26), day(27), day(28))

    @Test
    fun sabahtanOnceSiradakiSabah() {
        val s = WidgetSchedule.compute(at(2026, 10, 27, 3, 0), days, tz)
        assertEquals(0, s.nextIndex)
        assertEquals(at(2026, 10, 27, 5, 45), s.nextTimeMs)
    }

    @Test
    fun ogleIleIkindiArasindaSiradakiIkindi() {
        val s = WidgetSchedule.compute(at(2026, 10, 27, 14, 0), days, tz)
        assertEquals(2, s.nextIndex)
        assertEquals(at(2026, 10, 27, 15, 50), s.nextTimeMs)
    }

    @Test
    fun siradakiVakitGectigindeDegisirUygulamaAcilmadan() {
        // Aynı program, iki farklı an: ikindi geçince sıradaki Akşam olur.
        val before = WidgetSchedule.compute(at(2026, 10, 27, 15, 49), days, tz)
        val after = WidgetSchedule.compute(at(2026, 10, 27, 15, 51), days, tz)
        assertEquals(2, before.nextIndex)
        assertEquals(3, after.nextIndex)
    }

    @Test
    fun yatsidanSonraSiradakiYarininSabahi() {
        val s = WidgetSchedule.compute(at(2026, 10, 27, 21, 0), days, tz)
        assertEquals(0, s.nextIndex)
        assertEquals(at(2026, 10, 28, 5, 45), s.nextTimeMs)
    }

    @Test
    fun gunDegisinceBugununSaatleriYenilenir() {
        val s = WidgetSchedule.compute(at(2026, 10, 28, 1, 0), days, tz)
        assertNotNull(s.today)
        assertEquals(at(2026, 10, 28, 5, 45), s.today!!.fajr)
    }

    @Test
    fun programBitinceSiradakiYokBugunYok() {
        val s = WidgetSchedule.compute(at(2026, 11, 5, 12, 0), days, tz)
        assertEquals(-1, s.nextIndex)
        assertNull(s.today)
    }

    @Test
    fun takipGunuSinirindanOnceDunkuGundur() {
        // Sabah 05:45 > 04:00 olduğu için sınır 04:00.
        val gece = WidgetSchedule.compute(at(2026, 10, 27, 2, 0), days, tz)
        assertEquals("2026-10-26", gece.trackingDateKey)
        val sabah = WidgetSchedule.compute(at(2026, 10, 27, 4, 1), days, tz)
        assertEquals("2026-10-27", sabah.trackingDateKey)
    }

    @Test
    fun sabahDahaErkenseSinirSabahtir() {
        // Yaz: Sabah 03:24 → gün 03:24'te değişir.
        val yaz = listOf(
            DaySchedule(
                fajr = at(2026, 6, 21, 3, 24),
                sunrise = at(2026, 6, 21, 5, 20),
                dhuhr = at(2026, 6, 21, 13, 10),
                asr = at(2026, 6, 21, 17, 10),
                maghrib = at(2026, 6, 21, 20, 50),
                isha = at(2026, 6, 21, 22, 30),
            )
        )
        val oncesi = WidgetSchedule.compute(at(2026, 6, 21, 3, 20), yaz, tz)
        val sonrasi = WidgetSchedule.compute(at(2026, 6, 21, 3, 30), yaz, tz)
        assertEquals("2026-06-20", oncesi.trackingDateKey)
        assertEquals("2026-06-21", sonrasi.trackingDateKey)
    }

    @Test
    fun yenilemeSiradakiVakitteVeyaGeceYarisindan() {
        val ogle = WidgetSchedule.compute(at(2026, 10, 27, 14, 0), days, tz)
        assertEquals(at(2026, 10, 27, 15, 50), ogle.nextRefreshMs)
        // Program bitmişse gece yarısı: widget en geç gün değişiminde yenilenir.
        val bos = WidgetSchedule.compute(at(2026, 11, 5, 12, 0), days, tz)
        assertEquals(at(2026, 11, 6, 0, 0), bos.nextRefreshMs)
        assertTrue(bos.nextRefreshMs > at(2026, 11, 5, 12, 0))
    }

    @Test
    fun ayristirmaBozukSatirlariAtlar() {
        val d = day(26)
        val line = listOf(d.fajr, d.sunrise, d.dhuhr, d.asr, d.maghrib, d.isha).joinToString(",")
        val parsed = WidgetSchedule.parse("$line\nbozuk,satir\n1,2,3\n\n$line")
        assertEquals(2, parsed.size)
        assertEquals(d.fajr, parsed[0].fajr)
        assertTrue(WidgetSchedule.parse(null).isEmpty())
        assertTrue(WidgetSchedule.parse("  ").isEmpty())
    }
}
