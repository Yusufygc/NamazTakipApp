import UIKit
import UniformTypeIdentifiers

/// iOS paylaşım menüsünde (Instagram, TikTok, Safari, YouTube Shorts vb.)
/// "Zikir Yakala (Namaz Takip)" seçildiğinde paylaşılan URL ve açıklamayı alıp
/// ana uygulamayı (`namaztakip://share?text=...`) açan Share Extension.
class ShareViewController: UIViewController {
  private let appGroupId = "group.com.namaztakip.app"
  private let sharedKey = "shared_text"

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    extractSharedContent { [weak self] combinedText in
      guard let self = self else { return }
      if let text = combinedText, !text.isEmpty {
        self.saveAndOpenHostApp(text: text)
      } else {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
      }
    }
  }

  private func extractSharedContent(completion: @escaping (String?) -> Void) {
    guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
      completion(nil)
      return
    }

    let group = DispatchGroup()
    var collectedParts: [String] = []
    let lock = NSLock()

    let urlType = UTType.url.identifier
    let textType = UTType.plainText.identifier

    for item in extensionItems {
      if let attributed = item.attributedContentText?.string
        .trimmingCharacters(in: .whitespacesAndNewlines),
        !attributed.isEmpty
      {
        lock.lock()
        collectedParts.append(attributed)
        lock.unlock()
      }

      guard let attachments = item.attachments else { continue }
      for provider in attachments {
        if provider.hasItemConformingToTypeIdentifier(urlType) {
          group.enter()
          provider.loadItem(forTypeIdentifier: urlType, options: nil) { data, _ in
            defer { group.leave() }
            if let url = data as? URL {
              lock.lock()
              collectedParts.append(url.absoluteString)
              lock.unlock()
            } else if let str = data as? String {
              lock.lock()
              collectedParts.append(str)
              lock.unlock()
            }
          }
        } else if provider.hasItemConformingToTypeIdentifier(textType) {
          group.enter()
          provider.loadItem(forTypeIdentifier: textType, options: nil) { data, _ in
            defer { group.leave() }
            if let text = data as? String {
              lock.lock()
              collectedParts.append(text)
              lock.unlock()
            }
          }
        }
      }
    }

    group.notify(queue: .main) {
      let joined = collectedParts
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
        .joined(separator: "\n")
      completion(joined.isEmpty ? nil : joined)
    }
  }

  private func saveAndOpenHostApp(text: String) {
    if let defaults = UserDefaults(suiteName: appGroupId) {
      defaults.set(text, forKey: sharedKey)
      defaults.synchronize()
    }

    var components = URLComponents()
    components.scheme = "namaztakip"
    components.host = "share"
    components.queryItems = [URLQueryItem(name: "text", value: text)]

    if let targetUrl = components.url {
      openURLInHostApp(targetUrl)
    }

    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
  }

  @objc private func openURLInHostApp(_ url: URL) {
    var responder: UIResponder? = self
    let selector = sel_registerName("openURL:")
    while let current = responder {
      if current.responds(to: selector) {
        current.perform(selector, with: url)
        break
      }
      responder = current.next
    }
  }
}
