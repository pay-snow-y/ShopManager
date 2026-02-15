//
//  WebView.swift
//  ShopManager
//
//  Created by ShopManager Generator.
//

import SwiftUI
import WebKit

#if os(iOS)
    import UIKit
    typealias WebViewRepresentable = UIViewRepresentable
#elseif os(macOS)
    import AppKit
    typealias WebViewRepresentable = NSViewRepresentable
#endif

// iOS/macOS 공통 웹뷰
struct WebView: WebViewRepresentable {
    let url: URL
    let authHeaderValue: String
    let authHeaderKey = "X-Shop-Manager-Auth"
    let authCookieName = "shop-manager-auth"

    // 내부 Coordinator 클래스
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Page loaded successfully")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // 공통 생성 로직: 쿠키 설정을 추가하여 WebSocket 연결 시에도 인증 정보 전달
    private func createWebView(coordinator: Coordinator) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "ShopManagerApp/1.0"
        
        let webView = WKWebView(frame: .zero, configuration: config)
        
        // 중요: 쿠키 주입 (비동기라 로드 직전에 설정 시도)
        if let host = url.host {
            let cookieProperties: [HTTPCookiePropertyKey: Any] = [
                .name: authCookieName,
                .value: authHeaderValue,
                .domain: host,
                .path: "/",
                .secure: "TRUE",
                .expires: Date(timeIntervalSinceNow: 31536000) // 1년
            ]
            
            if let cookie = HTTPCookie(properties: cookieProperties) {
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
        }
        
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator

        // 초기 HTTP 요청에는 헤더도 함께 추가 (이중 보완)
        var request = URLRequest(url: url)
        request.setValue(authHeaderValue, forHTTPHeaderField: authHeaderKey)

        webView.load(request)
        return webView
    }

    #if os(iOS)
    func makeUIView(context: Context) -> WKWebView {
        return createWebView(coordinator: context.coordinator)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
    #endif

    #if os(macOS)
    func makeNSView(context: Context) -> WKWebView {
        return createWebView(coordinator: context.coordinator)
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {}
    #endif
}
