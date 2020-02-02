//
//  UIViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 28/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit
import SafariServices

fileprivate var contentView : UIView!

extension UIViewController {
    
    func presentFGAlertOnMainThread(title: String, message: String, buttonTilte: String){
        DispatchQueue.main.async {
            let alertVC = FGAlertVC(title: title, message: message, buttonTitle: buttonTilte)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            self.present(alertVC, animated: true)
        }
    }
    
    func showLoadingView() {
        contentView = UIView(frame: view.bounds)
        view.addSubview(contentView)
        
        contentView.backgroundColor = .systemBackground
        contentView.alpha = 0
        
        UIView.animate(withDuration: 0.25) { contentView.alpha = 0.8 }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        contentView.addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dissmissLoadingView(){
        DispatchQueue.main.async {
            contentView.removeFromSuperview()
            contentView = nil
        }
    }
    
    func showEmptySatteView(with message: String, in view: UIView){
        let emptyStateView = FGEmptyView(message: message)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
    
    func presentSafariVC(with url: URL){
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemGreen
        present(safariVC, animated: true)
    }
}
