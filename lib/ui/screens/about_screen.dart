import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget feature(String emoji, String title, String text) => ListTile(
          leading: Text(emoji, style: const TextStyle(fontSize: 26)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(text),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        const Center(child: Text('🕌', style: TextStyle(fontSize: 56))),
        const Center(
          child: Text('Namaz Takip',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        ),
        Center(child: Text('Versiyon 1.0.0', style: TextStyle(color: p.textLight))),
        const SizedBox(height: 4),
        Center(
          child: Text('Günlük namazlarınızı kolayca takip edin',
              style: TextStyle(color: p.textLight)),
        ),
        const SizedBox(height: 16),
        Card(
          color: p.card,
          child: Column(
            children: [
              feature('📍', 'Konuma göre vakitler',
                  'Vakitler cihazda hesaplanır; internet gerekmez. Güneş vakti bilgi amaçlıdır.'),
              feature('✅', 'Namaz takibi',
                  'Bir vakte dokunup kıldığınızı, cemaatle kılıp kılmadığınızı veya kılmadığınızı işaretleyin.'),
              feature('📋', 'Kaza namazları',
                  'İşaretlemeyi unuttuğunuz günler de kaza listesinde görünür. Günlere dokunarak vakitleri görün.'),
              feature('📊', 'Süreç',
                  'Performans, ısı haritası ve haftalık/aylık karşılaştırmalar.'),
              feature('🏅', 'Rozetler ve seri',
                  'Üst üste tam günlerle seri oluşturun, rozetleri açın.'),
              feature('🎨', 'Temalar', 'Ayarlar\'dan beş temadan birini seçin.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('📌 Ana ekranı aşağı çekerek konumu yenileyebilirsiniz.',
            style: TextStyle(color: p.textLight)),
        const SizedBox(height: 6),
        Text('📌 Isı haritasında ay değiştirmek için ok butonlarını kullanın.',
            style: TextStyle(color: p.textLight)),
        const SizedBox(height: 24),
        Center(child: Text('Geliştirici: MYY', style: TextStyle(color: p.textLight))),
        Center(child: Text('Namaz Takip © 2026', style: TextStyle(color: p.textLight))),
        const SizedBox(height: 6),
        const Center(child: Text('🤲 Allah kabul etsin')),
      ],
    );
  }
}
