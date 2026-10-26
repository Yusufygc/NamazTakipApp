# Karar Kayıtları

Mimari ve ürün kararlarının gerekçeli kaydı (ADR). Her karar `kararlar/` klasöründe ayrı bir sayfadır; numara sırası alınma sırasıdır. Bir karar değişirse eski kayıt silinmez; durumu "Değiştirildi" yapılır ve yeni kayda bağlanır.

## Yeni karar kaydı şablonu

```
# NNN — Başlık
Durum: Kabul edildi | Değiştirildi (→ [[yeni-karar]]) | Reddedildi
Tarih: YYYY-AA-GG

## Bağlam
## Karar
## Sonuçlar
## İlgili sayfalar
```

## Liste

| No | Karar | Durum |
|---|---|---|
| [[001-flutter-gecisi]] | React Native/Expo yerine Flutter | Kabul edildi |
| [[002-vakitler-cihazda-hesaplanir]] | Vakitler API yerine cihazda hesaplanır | Kabul edildi |
| [[003-iso-tarih-formati]] | Tarihler `yyyy-MM-dd` saklanır | Kabul edildi |
| [[004-sabit-bildirim-kimlikleri]] | Bildirim kimlikleri tarih ve vakitten türetilir | Kabul edildi |
| [[005-kaza-turetilir]] | Kaza listesi türetilir, ayrı tabloda tutulmaz | Kabul edildi |
| [[006-riverpod-durum-yonetimi]] | Durum yönetimi için Riverpod | Kabul edildi |
| [[007-sqflite-secimi]] | Depolama için `sqflite` | Kabul edildi |
| [[008-merkezi-ikon-ve-metin]] | Merkezi ikon ve modüler metin sistemi | Kabul edildi |
| [[009-konum-yedek-zinciri]] | Konum: medium → high → son bilinen | Kabul edildi |
| [[010-wiki-sistemi]] | Proje bilgisi `docs/wiki/` içinde tutulur | Kabul edildi |

## İlgili sayfalar

[[index]] · [[wiki-kullanim]] · [[mimari-genel]]
