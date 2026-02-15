//
//  ContentView.swift
//  ShopManager
//
//  Created by ShopManager Generator.
//

import SwiftUI

struct ContentView: View {
    // ⚠️ 보안 키 설정: 서버의 .env 파일에 설정한 APP_SECRET_HEADER 값과 정확히 일치해야 합니다.
    // 예: "my-secure-access-key-12345"
    let authSecretKey = "Dk*k1!kdslA1982#dkjss@#$ddk"
    
    // 접속할 URL
    let targetUrlString = "https://shop.play-anything.net/"

    var body: some View {
        // WebView를 화면 전체에 표시
        WebView(url: URL(string: targetUrlString)!, authHeaderValue: authSecretKey)
            .edgesIgnoringSafeArea(.all) // 상태바 영역까지 꽉 채우기
    }
}

#Preview {
    ContentView()
}
