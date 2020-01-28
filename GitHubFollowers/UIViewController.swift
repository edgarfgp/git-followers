//
//  UIViewController.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 28/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentFGAlertOnMainThread(title: String, message: String, buttonTilte: String){
        DispatchQueue.main.async {
            let alertVC = GFAlertVC(title: title, message: message, buttonTitle: buttonTilte)
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            self.present(alertVC, animated: true)
        }
    }
}
