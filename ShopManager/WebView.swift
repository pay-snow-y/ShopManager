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
    
    // 내부 Coordinator 클래스
    class Coordinator: NSObject, WKNavigationDelegate {
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
    
    // 공통 생성 로직
    private func createWebView(coordinator: Coordinator) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "ShopManagerApp/1.0"
        
        // 캐시 무시 (항상 최신 버전 로드)
        // config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = coordinator
        
        // 요청에 헤더 추가
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
