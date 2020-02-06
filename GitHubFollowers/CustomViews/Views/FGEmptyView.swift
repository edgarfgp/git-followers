//
//  FGEmptyView.swift
//  GitHubFollowers
//
//  Created by Edgar Gonzalez Pena on 31/01/2020.
//  Copyright © 2020 Edgar Gonzalez Pena. All rights reserved.
//

import UIKit

class FGEmptyView: UIView {
    
    let messagelabel = FGTitleLabel(textAligment: .center, fontSize: 28)
    let logoImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    convenience init(message : String){
        self.init(frame: .zero)
        messagelabel.text = message
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func configure() {
        
        configureMessageLabel()
        
        configureLogoImageView()
    }
    
    private func configureMessageLabel() {
        addSubviews(messagelabel, logoImageView)
        messagelabel.numberOfLines = 3
        messagelabel.textColor = .secondaryLabel
        
        let messagelabelCenterYConstraintConstant: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? -100 : -150
        
        NSLayoutConstraint.activate([
            messagelabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: messagelabelCenterYConstraintConstant),
            messagelabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            messagelabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            messagelabel.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func configureLogoImageView() {
        logoImageView.image = Images.emptyStateLogo
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let logoImageViewBottomConstraintConstant: CGFloat = DeviceTypes.isiPhoneSE || DeviceTypes.isiPhone8Zoomed ? 80 : 40
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.3),
            logoImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.3),
            logoImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 170),
            logoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: logoImageViewBottomConstraintConstant),
        ])
    }
}
