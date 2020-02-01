//
//  Date+Ext.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 01/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

extension Date {
    
    func convertToMonthYearFormat() -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MMM yyyy"
        
        return dateFormater.string(from: self)
    }
}
