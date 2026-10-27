import SwiftUI
import UIKit
import WebKit

// Địa chỉ trò chơi. Có thể đổi URL tại đây.
private let gameAddress = "https://play.thanhthan.info/"

final class GameState: ObservableObject {
    @Published var loading = true
    @Published var failure: String? = nil
    weak var webView: WKWebView?

    func retry() {
        failure = nil
        loading = true
        guard let url = URL(string: gameAddress) else {
            failure = "Đường dẫn game không hợp lệ."
            loading = false
            return
        }
        webView?.load(URLRequest(url: url, cachePolicy: .useProtocolCachePolicy))
    }
}

struct GameScreen: View {
    @StateObject private var state = GameState()

    var body: some View {
        ZStack {
            Color.black
            WebGameView(state: state)

            if state.loading && state.failure == nil {
                VStack(spacing: 14) {
                    ProgressView().tint(.white).scaleEffect(1.2)
                    Text("Đang mở game…")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
                .padding(24)
                .background(.black.opacity(0.75), in: RoundedRectangle(cornerRadius: 14))
            }

            if let error = state.failure {
                VStack(spacing: 18) {
                    Image(systemName: "wifi.exclamationmark")
                        .font(.system(size: 34))
                    Text("Không tải được game")
                        .font(.headline)
                    Text(error)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                    Button("Thử lại") { state.retry() }
                        .buttonStyle(.borderedProminent)
                }
                .foregroundStyle(.white)
                .padding(24)
                .frame(maxWidth: 330)
                .background(Color(white: 0.12), in: RoundedRectangle(cornerRadius: 20))
            }
        }
        .ignoresSafeArea()
    }
}

struct WebGameView: UIViewRepresentable {
    @ObservedObject var state: GameState

    func makeCoordinator() -> Coordinator { Coordinator(state: state) }

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true

        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = preferences
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .default()
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        let view = WKWebView(frame: .zero, configuration: config)
        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator
        view.scrollView.bounces = false
        view.scrollView.contentInsetAdjustmentBehavior = .never
        view.isOpaque = false
        view.backgroundColor = .black
        view.scrollView.backgroundColor = .black
        view.allowsBackForwardNavigationGestures = false
        if #available(iOS 16.4, *) {
            #if DEBUG
            view.isInspectable = true
            #endif
        }

        state.webView = view
        if let url = URL(string: gameAddress) {
            view.load(URLRequest(url: url))
        } else {
            state.failure = "Đường dẫn game không hợp lệ."
            state.loading = false
        }
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // WKWebView quản lý nội dung; không tải lại theo mỗi lần SwiftUI cập nhật.
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let state: GameState
        init(state: GameState) { self.state = state }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            state.loading = true
            state.failure = nil
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            state.loading = false
            state.failure = nil
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            show(error)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            show(error)
        }

        private func show(_ error: Error) {
            let nsError = error as NSError
            if nsError.code == NSURLErrorCancelled { return }
            state.loading = false
            state.failure = "Kiểm tra kết nối Internet và thử truy cập play.thanhthan.info trong Safari. Chi tiết: \(error.localizedDescription)"
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               let scheme = url.scheme?.lowercased(),
               ["tel", "mailto", "sms"].contains(scheme) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        // Để cửa sổ mới (target=_blank) không bị mất trong ứng dụng.
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
