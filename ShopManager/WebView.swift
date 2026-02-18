import SwiftUI
import WebKit

#if os(iOS)
import UIKit
typealias WebViewRepresentable = UIViewRepresentable
#elseif os(macOS)
import AppKit
typealias WebViewRepresentable = NSViewRepresentable
#endif

struct WebView: WebViewRepresentable {
    let url: URL
    let authHeaderValue: String
    private let authHeaderKey = "X-Shop-Manager-Auth"

    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView
        init(_ parent: WebView) { self.parent = parent }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Page loaded successfully")
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    private func createWebView(coordinator: Coordinator) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "ShopManagerApp/1.0"
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator

        bootstrapSessionAndLoad(webView)
        return webView
    }

    private func bootstrapSessionAndLoad(_ webView: WKWebView) {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        components.path = "/api/auth/bootstrap"
        components.query = nil
        guard let bootstrapURL = components.url else { return }

        var request = URLRequest(url: bootstrapURL)
        request.httpMethod = "POST"
        request.setValue(authHeaderValue, forHTTPHeaderField: authHeaderKey)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data("{}".utf8)

        let session = URLSession(configuration: .default)
        session.dataTask(with: request) { _, response, error in
            if let error = error {
                print("bootstrap failed: \(error)")
            } else if let http = response as? HTTPURLResponse {
                print("bootstrap status: \(http.statusCode)")
            }

            DispatchQueue.main.async {
                var pageReq = URLRequest(url: self.url)
                pageReq.setValue(self.authHeaderValue, forHTTPHeaderField: self.authHeaderKey) // 첫 진입 헤더
                webView.load(pageReq)
            }
        }.resume()
    }

    #if os(iOS)
    func makeUIView(context: Context) -> WKWebView { createWebView(coordinator: context.coordinator) }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    #endif

    #if os(macOS)
    func makeNSView(context: Context) -> WKWebView { createWebView(coordinator: context.coordinator) }
    func updateNSView(_ nsView: WKWebView, context: Context) {}
    #endif
}
