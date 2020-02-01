//
//  FGSecondaryTitleLabel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 01/02/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class FGSecondaryTitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
     }
    
     required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
     }
    
     init(fontSize : CGFloat) {
        super.init(frame: .zero)
        font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        configure()
     }
    
     private func configure(){
         textColor = .secondaryLabel
         adjustsFontSizeToFitWidth = true
         minimumScaleFactor = 0.90
         lineBreakMode = .byTruncatingTail
         translatesAutoresizingMaskIntoConstraints = false
     }
}
