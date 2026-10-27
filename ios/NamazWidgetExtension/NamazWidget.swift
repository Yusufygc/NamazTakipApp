import SwiftUI
import WidgetKit

struct NamazWidgetEntry: TimelineEntry {
  let date: Date
  let city: String
  let nextPrayerLabel: String
  let nextPrayerTime: String
  let completedCount: Int
  let fajrTime: String
  let sunriseTime: String
  let dhuhrTime: String
  let asrTime: String
  let maghribTime: String
  let ishaTime: String
}

struct NamazWidgetProvider: TimelineProvider {
  private let appGroupId = "group.com.namaztakip.app"
  private let snapshotKey = "home_widget_snapshot"

  func placeholder(in context: Context) -> NamazWidgetEntry {
    loadEntry()
  }

  func getSnapshot(in context: Context, completion: @escaping (NamazWidgetEntry) -> Void) {
    completion(loadEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<NamazWidgetEntry>) -> Void) {
    let entry = loadEntry()
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
    completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
  }

  private func loadEntry() -> NamazWidgetEntry {
    let defaults = UserDefaults(suiteName: appGroupId)
    let dict = defaults?.dictionary(forKey: snapshotKey) ?? [:]
    return NamazWidgetEntry(
      date: Date(),
      city: dict["city"] as? String ?? "Namaz Takip",
      nextPrayerLabel: dict["nextPrayerLabel"] as? String ?? "Sabah",
      nextPrayerTime: dict["nextPrayerTime"] as? String ?? "05:50",
      completedCount: dict["completedCount"] as? Int ?? 0,
      fajrTime: dict["fajrTime"] as? String ?? "--:--",
      sunriseTime: dict["sunriseTime"] as? String ?? "--:--",
      dhuhrTime: dict["dhuhrTime"] as? String ?? "--:--",
      asrTime: dict["asrTime"] as? String ?? "--:--",
      maghribTime: dict["maghribTime"] as? String ?? "--:--",
      ishaTime: dict["ishaTime"] as? String ?? "--:--"
    )
  }
}

struct NamazWidgetEntryView: View {
  var entry: NamazWidgetProvider.Entry
  @Environment(\.widgetFamily) var family

  private let emeraldStart = Color(red: 0.086, green: 0.220, blue: 0.169)
  private let emeraldEnd = Color(red: 0.059, green: 0.149, blue: 0.114)
  private let goldColor = Color(red: 0.898, green: 0.788, blue: 0.545)

  var body: some View {
    ZStack {
      LinearGradient(
        gradient: Gradient(colors: [emeraldStart, emeraldEnd]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      VStack(alignment: .leading, spacing: 6) {
        HStack {
          Text(entry.city)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .lineLimit(1)
          Spacer()
          Text("\(entry.completedCount)/5")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(goldColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.white.opacity(0.12))
            .cornerRadius(8)
        }
        Spacer()
        HStack(alignment: .lastTextBaseline) {
          VStack(alignment: .leading, spacing: 2) {
            Text("SIRADAKİ VAKİT")
              .font(.system(size: 9, weight: .bold))
              .foregroundColor(goldColor)
            Text(entry.nextPrayerLabel)
              .font(.system(size: 18, weight: .heavy))
              .foregroundColor(.white)
          }
          Spacer()
          Text(entry.nextPrayerTime)
            .font(.system(size: 24, weight: .heavy))
            .foregroundColor(goldColor)
        }
        if family != .systemSmall {
          Spacer()
          HStack(spacing: 4) {
            prayerColumn("Sabah", entry.fajrTime)
            prayerColumn("Güneş", entry.sunriseTime)
            prayerColumn("Öğle", entry.dhuhrTime)
            prayerColumn("İkindi", entry.asrTime)
            prayerColumn("Akşam", entry.maghribTime)
            prayerColumn("Yatsı", entry.ishaTime)
          }
          .padding(.vertical, 5)
          .background(Color.white.opacity(0.10))
          .cornerRadius(10)
        }
      }
      .padding(12)
    }
  }

  private func prayerColumn(_ label: String, _ time: String) -> some View {
    VStack(spacing: 2) {
      Text(label)
        .font(.system(size: 9, weight: .medium))
        .foregroundColor(Color.white.opacity(0.8))
      Text(time)
        .font(.system(size: 10, weight: .bold))
        .foregroundColor(.white)
    }
    .frame(maxWidth: .infinity)
  }
}

@main
struct NamazWidget: Widget {
  let kind: String = "NamazWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: NamazWidgetProvider()) { entry in
      NamazWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Namaz Vakitleri")
    .description("Sıradaki namaz vaktini ve günün vakitlerini ana ekranda gösterir.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
