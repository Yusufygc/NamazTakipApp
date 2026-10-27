package com.namaztakip.namaz_takip

import org.junit.Assert.assertEquals
import org.junit.Test

class CompassMathTest {
    private val eps = 1e-9

    @Test
    fun dogudakiSapmaEklenir() {
        // Türkiye'de sapma yaklaşık +5: manyetik 100 derece, gerçek 105 derece.
        assertEquals(105.0, CompassMath.trueHeading(100.0, 5.0), eps)
    }

    @Test
    fun batidakiSapmaCikarilir() {
        assertEquals(95.0, CompassMath.trueHeading(100.0, -5.0), eps)
    }

    @Test
    fun sifirSapmaAcilariDegistirmez() {
        assertEquals(151.6, CompassMath.trueHeading(151.6, 0.0), eps)
    }

    @Test
    fun sonucHerZaman0Ile360Arasindadir() {
        // 358 + 5 = 363 -> 3; 2 - 5 = -3 -> 357
        assertEquals(3.0, CompassMath.trueHeading(358.0, 5.0), eps)
        assertEquals(357.0, CompassMath.trueHeading(2.0, -5.0), eps)
        assertEquals(0.0, CompassMath.trueHeading(355.0, 5.0), eps)
        assertEquals(0.0, CompassMath.trueHeading(-10.0, 10.0), eps)
    }

    @Test
    fun negatifManyetikAciDaDogruCevrilir() {
        // getOrientation -180..180 verir; -90 manyetik = 270, +5 sapma = 275.
        assertEquals(275.0, CompassMath.trueHeading(-90.0, 5.0), eps)
    }
}
