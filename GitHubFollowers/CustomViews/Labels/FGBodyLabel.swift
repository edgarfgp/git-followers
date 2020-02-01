//
//  FGBodyLabel.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 28/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class FGBodyLabel: UILabel {

    override init(frame: CGRect) {
       super.init(frame: frame)
       configure()
    }
   
    required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
   
    init(textAligment: NSTextAlignment, numberOfLines: Int = 1) {
        super.init(frame: .zero)
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        
       configure()
    }
   
    private func configure(){
        textColor = .secondaryLabel
        font = UIFont.preferredFont(forTextStyle: .body)
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.75
        lineBreakMode = .byWordWrapping
        translatesAutoresizingMaskIntoConstraints = false
    }

}
