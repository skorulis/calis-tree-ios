// Created by Alex Skorulis on 15/5/2026.

import SwiftUI
import WebKit

struct YouTubeEmbedView: View {
    let videoURL: String

    var body: some View {
        Group {
            if let videoID = Self.videoID(from: videoURL) {
                YouTubeWebView(videoID: videoID)
                    .aspectRatio(16 / 9, contentMode: .fit)
            } else if let url = URL(string: videoURL) {
                Link(destination: url) {
                    Label("Watch video", systemImage: "play.rectangle")
                }
            }
        }
    }

    static func videoID(from urlString: String) -> String? {
        guard let url = URL(string: urlString),
              let host = url.host?.lowercased() else {
            return nil
        }

        if host == "youtu.be" || host.hasSuffix(".youtu.be") {
            let id = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            return validated(id)
        }

        guard host.contains("youtube.com") else { return nil }

        if url.path == "/watch" || url.path.hasPrefix("/watch") {
            let raw = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "v" })?
                .value
            return validated(raw)
        }

        if url.path.hasPrefix("/embed/") {
            let trimmed = String(url.path.dropFirst("/embed/".count))
            let id = trimmed.split(separator: "/").first.map(String.init)
            return validated(id)
        }

        if url.path.hasPrefix("/shorts/") {
            let trimmed = String(url.path.dropFirst("/shorts/".count))
            let id = trimmed.split(separator: "/").first.map(String.init)
            return validated(id)
        }

        return nil
    }

    private static func validated(_ raw: String?) -> String? {
        guard let raw, !raw.isEmpty else { return nil }
        guard raw.range(of: #"^[a-zA-Z0-9_-]{6,}$"#, options: .regularExpression) != nil else { return nil }
        return raw
    }
}

private struct YouTubeWebView: UIViewRepresentable {
    let videoID: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        context.coordinator.load(videoID: videoID, into: webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if context.coordinator.loadedVideoID != videoID {
            context.coordinator.load(videoID: videoID, into: webView)
        }
    }

    final class Coordinator {
        var loadedVideoID: String?

        func load(videoID: String, into webView: WKWebView) {
            loadedVideoID = videoID
            let embed = "https://www.youtube.com/embed/\(videoID)?playsinline=1"
            let html = """
            <!DOCTYPE html>
            <html>
            <head>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
            <style>
              html, body { margin:0; padding:0; height:100%; background:#000; }
              .wrap { position:absolute; inset:0; }
              iframe { width:100%; height:100%; border:0; }
            </style>
            </head>
            <body>
            <div class="wrap">
              <iframe src="\(embed)"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                allowfullscreen>
              </iframe>
            </div>
            </body>
            </html>
            """
            webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube-nocookie.com"))
        }
    }
}

#Preview("Embed") {
    YouTubeEmbedView(videoURL: "https://www.youtube.com/watch?v=TB4gWro3XaY")
        .padding()
}

#Preview("Fallback link") {
    YouTubeEmbedView(videoURL: "https://example.com/not-youtube")
        .padding()
}
