//
//  CustomWebView.swift
//  fancertification
//
//  Created by 유지상 on 2022/05/05.
//

import SwiftUI
import WebKit

struct CustomWebView: UIViewRepresentable {
    var url: String
    
    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: self.url) else {
            return WKWebView()
        }
        
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<CustomWebView>) {
    }
}

struct CustomWebView_Previews: PreviewProvider {
    static var previews: some View {
        CustomWebView(url: "https://www.naver.com")
    }
}
