//
//  String+Ext.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 01/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

extension String {
    
    func convertToDate () -> Date? {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormater.locale = Locale(identifier: "en_US_POSIX")
        dateFormater.timeZone = .current
        
        return dateFormater.date(from: self)
    }
    
    func convertToDisplayFormat () -> String {
        guard let data = self.convertToDate() else { return "N/A" }
        return data.convertToMonthYearFormat()
    }
}
