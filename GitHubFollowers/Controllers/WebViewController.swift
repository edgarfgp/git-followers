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
    let webView: WebView = WebView()
    
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
        guard let url = targetURL else {
            return
        }
        let req = URLRequest(url: url)
        DispatchQueue.main.async {
            self.webView.load(req)
        }
    }
    
    fileprivate func configureWebView() {
        webView.frame = UIScreen.main.bounds
        webView.frame = view.bounds
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

