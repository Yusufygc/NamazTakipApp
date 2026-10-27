package com.namaztakip.namaz_takip

/**
 * Pusula açısı hesapları. Android API'sine bağlı değildir, birim testle denenir.
 *
 * Cihaz sensörü **manyetik** kuzeye göre yön verir. Kıble açısı ise gerçek (coğrafi)
 * kuzeye göredir. Aradaki fark manyetik sapmadır (declination); Türkiye'de yaklaşık
 * 5 derece doğuya. Sapma, konuma göre `GeomagneticField.declination` ile bulunur
 * ve burada eklenir.
 */
object CompassMath {
    /**
     * Manyetik kuzeye göre [magneticDegrees] açısını gerçek kuzeye göre açıya çevirir.
     * [declinationDegrees] doğuya pozitiftir. Sonuç 0 (dahil) ile 360 (hariç) arasındadır.
     */
    fun trueHeading(magneticDegrees: Double, declinationDegrees: Double): Double =
        ((magneticDegrees + declinationDegrees) % 360.0 + 360.0) % 360.0
}
