import 'package:flutter/material.dart';

import '../../core/icons/app_icons.dart';
import '../../core/strings/strings.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/islamic_pattern.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    Widget feature(IconData icon, String title, String text) => ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: p.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: p.primary),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            text,
            style: TextStyle(color: p.textLight, fontSize: 13),
          ),
        );

    Widget tip(String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(AppIcons.tip, size: 16, color: p.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(color: p.textLight, fontSize: 13),
                ),
              ),
            ],
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Center(
          child: SeljukMedallion(
            size: 84,
            fillColor: p.primary.withValues(alpha: p.isDark ? 0.24 : 0.10),
            borderColor: p.secondary,
            child: Icon(AppIcons.app, size: 38, color: p.primary),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            CommonStrings.appName,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
        ),
        Center(
          child: Text(
            CommonStrings.versionLabel,
            style: TextStyle(color: p.textLight, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            CommonStrings.tagline,
            style: TextStyle(color: p.textLight),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: p.card,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                feature(
                  AppIcons.aboutLocation,
                  AboutStrings.featureLocationTitle,
                  AboutStrings.featureLocationText,
                ),
                feature(
                  AppIcons.aboutTracking,
                  AboutStrings.featureTrackingTitle,
                  AboutStrings.featureTrackingText,
                ),
                feature(
                  AppIcons.aboutQaza,
                  AboutStrings.featureQazaTitle,
                  AboutStrings.featureQazaText,
                ),
                feature(
                  AppIcons.aboutStats,
                  AboutStrings.featureStatsTitle,
                  AboutStrings.featureStatsText,
                ),
                feature(
                  AppIcons.aboutBadges,
                  AboutStrings.featureBadgesTitle,
                  AboutStrings.featureBadgesText,
                ),
                feature(
                  AppIcons.aboutThemes,
                  AboutStrings.featureThemesTitle,
                  AboutStrings.featureThemesText,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: p.card,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                tip(AboutStrings.tipRefresh),
                tip(AboutStrings.tipHeatmap),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            CommonStrings.developer,
            style: TextStyle(color: p.textLight, fontSize: 13),
          ),
        ),
        Center(
          child: Text(
            CommonStrings.copyright,
            style: TextStyle(color: p.textLight, fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: p.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.dua, size: 18, color: p.primary),
                const SizedBox(width: 6),
                Text(
                  AboutStrings.dua,
                  style: TextStyle(
                    color: p.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
