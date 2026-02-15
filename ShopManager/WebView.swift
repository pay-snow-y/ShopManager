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
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        // 탐색 허용 여부 결정 (모든 요청에 헤더 추가 보장)
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // 이미 헤더가 포함된 요청이면 허용
            if let headers = navigationAction.request.allHTTPHeaderFields,
               headers[parent.authHeaderKey] == parent.authHeaderValue {
                decisionHandler(.allow)
                return
            }

            // 헤더가 없는 경우, 재요청하여 헤더 추가
            // (주의: 무한 루프 방지를 위해 URL이 동일한 경우에만 적용하거나, 특정 조건 확인 필요)
            // 여기서는 초기 로드 외의 링크 이동 등에서도 헤더를 유지하기 위해
            // 새 요청을 생성하고 헤더를 붙여서 로드하도록 처리

            if let url = navigationAction.request.url {
                // 외부 링크 등은 제외하고, 앱 도메인 내부 이동만 처리
                if url.host == parent.url.host {
                    var newRequest = navigationAction.request
                    newRequest.setValue(parent.authHeaderValue, forHTTPHeaderField: parent.authHeaderKey)

                    // 기존 요청을 취소하고 새 요청 로드
                    webView.load(newRequest)
                    decisionHandler(.cancel)
                    return
                }
            }

            decisionHandler(.allow)
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
        webView.uiDelegate = coordinator

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
