//
//  UITableView.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 06/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

extension UITableView {
    
    func reloadDataOnMainThread() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    func removeExcessCell() {
        tableFooterView = UIView(frame: .zero)
    }
}
