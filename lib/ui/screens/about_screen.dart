import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget feature(IconData icon, String title, String text) => ListTile(
          leading: Icon(icon, size: 28, color: p.primary),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(text),
        );

    Widget tip(String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(AppIcons.tip, size: 16, color: p.textLight),
              const SizedBox(width: 8),
              Expanded(child: Text(text, style: TextStyle(color: p.textLight))),
            ],
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Center(child: Icon(AppIcons.app, size: 64, color: p.primary)),
        const Center(
          child: Text(CommonStrings.appName,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        ),
        Center(
          child: Text(CommonStrings.versionLabel,
              style: TextStyle(color: p.textLight)),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(CommonStrings.tagline, style: TextStyle(color: p.textLight)),
        ),
        const SizedBox(height: 16),
        Card(
          color: p.card,
          child: Column(
            children: [
              feature(AppIcons.aboutLocation, AboutStrings.featureLocationTitle,
                  AboutStrings.featureLocationText),
              feature(AppIcons.aboutTracking, AboutStrings.featureTrackingTitle,
                  AboutStrings.featureTrackingText),
              feature(AppIcons.aboutQaza, AboutStrings.featureQazaTitle,
                  AboutStrings.featureQazaText),
              feature(AppIcons.aboutStats, AboutStrings.featureStatsTitle,
                  AboutStrings.featureStatsText),
              feature(AppIcons.aboutBadges, AboutStrings.featureBadgesTitle,
                  AboutStrings.featureBadgesText),
              feature(AppIcons.aboutThemes, AboutStrings.featureThemesTitle,
                  AboutStrings.featureThemesText),
            ],
          ),
        ),
        const SizedBox(height: 16),
        tip(AboutStrings.tipRefresh),
        tip(AboutStrings.tipHeatmap),
        const SizedBox(height: 24),
        Center(child: Text(CommonStrings.developer, style: TextStyle(color: p.textLight))),
        Center(child: Text(CommonStrings.copyright, style: TextStyle(color: p.textLight))),
        const SizedBox(height: 10),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.dua, size: 20, color: p.primary),
              const SizedBox(width: 6),
              const Text(AboutStrings.dua),
            ],
          ),
        ),
      ],
    );
  }
}
