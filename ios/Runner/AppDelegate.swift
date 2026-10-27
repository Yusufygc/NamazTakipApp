import CoreLocation
import Flutter
import UIKit
import UserNotifications
#if canImport(WidgetKit)
import WidgetKit
#endif

/// iOS Kıble pusulası için CLHeading sensör akışı.
final class CompassStreamHandler: NSObject, FlutterStreamHandler, CLLocationManagerDelegate {
  private var locationManager: CLLocationManager?
  private var eventSink: FlutterEventSink?

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    // Sensör yoksa sessiz kalma: Dart tarafı açık uyarı gösterir.
    guard CLLocationManager.headingAvailable() else {
      return FlutterError(
        code: "NO_SENSOR",
        message: "Cihazda yön (pusula) sensörü yok",
        details: nil
      )
    }
    self.eventSink = events
    let manager = CLLocationManager()
    manager.headingFilter = 1.0
    manager.delegate = self
    manager.startUpdatingHeading()
    self.locationManager = manager
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    locationManager?.stopUpdatingHeading()
    locationManager = nil
    eventSink = nil
    return nil
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    let heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    if heading >= 0 {
      eventSink?(heading)
    }
  }
}

/// iOS Share Extension ve özel URL şeması (`namaztakip://share?text=...`) ile
/// Flutter `com.namaztakip.app/share` MethodChannel arasındaki köprü.
final class ShareChannelBridge {
  static let shared = ShareChannelBridge()

  static let channelName = "com.namaztakip.app/share"
  static let compassChannelName = "com.namaztakip.app/compass"
  static let homeWidgetChannelName = "com.namaztakip.app/home_widget"
  static let appGroupId = "group.com.namaztakip.app"
  static let sharedKey = "shared_text"
  static let homeWidgetKey = "home_widget_snapshot"

  private var channel: FlutterMethodChannel?
  private var compassChannel: FlutterEventChannel?
  private var homeWidgetChannel: FlutterMethodChannel?
  private let compassHandler = CompassStreamHandler()
  private var pendingSharedText: String?

  private init() {}

  func register(with messenger: FlutterBinaryMessenger) {
    let methodChannel = FlutterMethodChannel(
      name: Self.channelName,
      binaryMessenger: messenger
    )
    self.channel = methodChannel

    let eventChannel = FlutterEventChannel(
      name: Self.compassChannelName,
      binaryMessenger: messenger
    )
    eventChannel.setStreamHandler(compassHandler)
    self.compassChannel = eventChannel

    let widgetChannel = FlutterMethodChannel(
      name: Self.homeWidgetChannelName,
      binaryMessenger: messenger
    )
    self.homeWidgetChannel = widgetChannel
    widgetChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "updateWidget":
        guard
          let args = call.arguments as? [String: Any],
          let defaults = UserDefaults(suiteName: Self.appGroupId)
        else {
          result(false)
          return
        }
        defaults.set(args, forKey: Self.homeWidgetKey)
        defaults.synchronize()
        #if canImport(WidgetKit)
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        #endif
        result(true)
      case "requestPinWidget":
        #if canImport(WidgetKit)
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
          result(true)
          return
        }
        #endif
        result(false)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    methodChannel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }
      switch call.method {
      case "takeInitialSharedText":
        self.pullFromAppGroupIfAvailable()
        let value = self.pendingSharedText
        self.pendingSharedText = nil
        result(value)

      case "openUrl":
        guard
          let args = call.arguments as? [String: Any],
          let rawUrl = args["url"] as? String,
          let url = URL(string: rawUrl.trimmingCharacters(in: .whitespacesAndNewlines))
        else {
          result(false)
          return
        }
        UIApplication.shared.open(url, options: [:]) { success in
          result(success)
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// App Group (`group.com.namaztakip.app`) içerisine Share Extension tarafından
  /// bırakılan metin varsa alır ve temizler.
  func pullFromAppGroupIfAvailable() {
    guard let defaults = UserDefaults(suiteName: Self.appGroupId) else { return }
    if let text = defaults.string(forKey: Self.sharedKey)?
      .trimmingCharacters(in: .whitespacesAndNewlines),
      !text.isEmpty
    {
      defaults.removeObject(forKey: Self.sharedKey)
      defaults.synchronize()
      deliver(sharedText: text)
    }
  }

  /// `namaztakip://share?text=...` URL şemasını çözümler.
  @discardableResult
  func handleIncoming(url: URL) -> Bool {
    guard url.scheme?.lowercased() == "namaztakip" else { return false }
    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let text = components.queryItems?.first(where: { $0.name == "text" })?.value?
        .trimmingCharacters(in: .whitespacesAndNewlines),
      !text.isEmpty
    {
      deliver(sharedText: text)
      return true
    }
    pullFromAppGroupIfAvailable()
    return true
  }

  func deliver(sharedText: String) {
    let trimmed = sharedText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return }
    if let channel = channel {
      channel.invokeMethod("onSharedText", arguments: trimmed)
    } else {
      pendingSharedText = trimmed
    }
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Uygulama açıkken de yerel bildirimlerin gösterilmesi için gerekli.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    if let url = launchOptions?[.url] as? URL {
      ShareChannelBridge.shared.handleIncoming(url: url)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    ShareChannelBridge.shared.register(
      with: engineBridge.applicationRegistrar.messenger()
    )
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if ShareChannelBridge.shared.handleIncoming(url: url) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
