//
//  WebViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez on 28/09/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import OAuthSwift
import UIKit
import WebKit
typealias WebView = WKWebView

class WebViewController: OAuthWebViewController {
    var targetURL: URL?
    
    private let webView: WebView = {
        let preferences = WKWebpagePreferences()
        if #available(iOS 14.0, *) {
            preferences.allowsContentJavaScript = true
        }

        let configutation = WKWebViewConfiguration()
        configutation.defaultWebpagePreferences = preferences
        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: configutation)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWebView()
        loadAddressURL()
    }
    
    override func handle(_ url: URL) {
        targetURL = url
        super.handle(url)
        loadAddressURL()
    }
    
    func loadAddressURL() {
        guard let url = targetURL else { return }
        let req = URLRequest(url: url)
        DispatchQueue.main.async {
            self.webView.load(req)
        }
    }
    
    fileprivate func configureWebView() {
        webView.navigationDelegate = self
        view.addSubview(webView)
    }
}

extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url , url.scheme == AppConfig.callbackUrlString  {
            AppDelegate.sharedInstance.applicationHandle(url: url)
            decisionHandler(.cancel)
            
            dismissWebViewController()
            return
        }
        
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        dismissWebViewController()
    }
}
